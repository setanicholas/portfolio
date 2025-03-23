import time
import math
import random
import urllib.parse
import hashlib
import hmac
import base64
import pandas as pd
import requests
##import streamlit as st
from pandasql import sqldf
from dotenv import load_dotenv
import os
from io import BytesIO
from datetime import datetime

# ----------------------------------------------------------------------------
# 1. Load Environment Variables
# ----------------------------------------------------------------------------
load_dotenv()

ACCOUNT_ID = os.getenv("ACCOUNT_ID")
CONSUMER_KEY = os.getenv("CONSUMER_KEY")
CONSUMER_SECRET = os.getenv("CONSUMER_SECRET")
TOKEN_ID = os.getenv("TOKEN_ID")
TOKEN_SECRET = os.getenv("TOKEN_SECRET")

NETSUITE_REALM = ACCOUNT_ID
NETSUITE_DEPLOY_ID = '1'
SIGN_METHOD = 'HMAC-SHA256'
OAUTH_VERSION = '1.0'
BASE_URL = f'https://{ACCOUNT_ID}.restlets.api.netsuite.com/app/site/hosting/restlet.nl'
HTTP_METHOD = 'GET'

NETSUITE_SCRIPT_IDS = {
    "demo_main": "0001",
    "demo_k1s": "0002",
    "demo_entities": "0003"
}

# ----------------------------------------------------------------------------
# 2. Helper Functions for OAuth Signing
# ----------------------------------------------------------------------------

def get_auth_nonce(length=11):
    return ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', k=length))

def generate_signature(base_url, http_method, oauth_nonce, oauth_timestamp, script_id):
    data = (
        f"deploy={NETSUITE_DEPLOY_ID}"
        f"&oauth_consumer_key={CONSUMER_KEY}"
        f"&oauth_nonce={oauth_nonce}"
        f"&oauth_signature_method={SIGN_METHOD}"
        f"&oauth_timestamp={oauth_timestamp}"
        f"&oauth_token={TOKEN_ID}"
        f"&oauth_version={OAUTH_VERSION}"
        f"&script={script_id}"
    )

    encoded_url = urllib.parse.quote(base_url, safe='~()*!.\'')
    encoded_data = urllib.parse.quote(data, safe='~()*!.\'')
    signature_base_string = f"{http_method}&{encoded_url}&{encoded_data}"

    signing_key = f"{urllib.parse.quote(CONSUMER_SECRET, safe='~()*!.')}&{urllib.parse.quote(TOKEN_SECRET, safe='~()*!.')}"
    
    signature_bytes = hmac.new(
        signing_key.encode('utf-8'),
        signature_base_string.encode('utf-8'),
        hashlib.sha256
    ).digest()

    return urllib.parse.quote(base64.b64encode(signature_bytes).decode('utf-8'), safe='~()*!.\'')

def build_oauth_header(script_id):
    oauth_nonce = get_auth_nonce()
    oauth_timestamp = int(time.time())

    oauth_signature = generate_signature(BASE_URL, HTTP_METHOD, oauth_nonce, oauth_timestamp, script_id)

    return (
        f'OAuth realm="{NETSUITE_REALM}",'
        f'oauth_token="{TOKEN_ID}",'
        f'oauth_consumer_key="{CONSUMER_KEY}",'
        f'oauth_nonce="{oauth_nonce}",'
        f'oauth_timestamp="{oauth_timestamp}",'
        f'oauth_signature_method="{SIGN_METHOD}",'
        f'oauth_version="{OAUTH_VERSION}",'
        f'oauth_signature="{oauth_signature}"'
    )

# ----------------------------------------------------------------------------
# 3. Fetch Data from NetSuite API
# ----------------------------------------------------------------------------

@st.cache_data
def fetch_saved_search_results(script_id):
    query_params = f"script={script_id}&deploy={NETSUITE_DEPLOY_ID}"
    url = f"{BASE_URL}?{query_params}"
    headers = {
        'Authorization': build_oauth_header(script_id),
        'Content-Type': 'application/json'
    }

    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return pd.DataFrame(response.json())

# ----------------------------------------------------------------------------
# 4. Load Data from API Calls
# ----------------------------------------------------------------------------

st.title("K1 Processing App")

progress_bar = st.progress(10)
status_text = st.empty()

status_text.text("🔄 Fetching data from NetSuite... This may take a few minutes.")

try:
    demo_main = fetch_saved_search_results(NETSUITE_SCRIPT_IDS["script1"])
    demo_k1s = fetch_saved_search_results(NETSUITE_SCRIPT_IDS["script1"])
    demo_entities = fetch_saved_search_results(NETSUITE_SCRIPT_IDS["script1"])
except Exception as e:
    st.error(f"❌ Error fetching NetSuite data: {e}")
    st.stop()

progress_bar.progress(40)
status_text.text("🛠️ Processing data and applying SQL transformations...")

# ----------------------------------------------------------------------------
# 5. SQL Query Processing
# ----------------------------------------------------------------------------

pysqldf = lambda q: sqldf(q, globals())


query1 = """
SELECT 
    *
FROM demo_file d
LEFT JOIN k1s_file k 
    ON d."K1 KEY" = k."NEW EXTERNAL ID" 
LEFT JOIN entities_file e 
    ON e."ID" = d."Transfer In From"
"""

result_df1 = pysqldf(query1)

# Format the "Zip" column to ensure leading zeros are preserved for numeric values
def format_zip(zip_value):
    if pd.isnull(zip_value):
        return zip_value  # Keep null values as is
    try:
        return f"{int(zip_value):05}"  # Format numeric zip codes with leading zeros
    except ValueError:
        return zip_value  # Return the original value if it's not numeric

result_df1["Zip"] = result_df1["Zip"].apply(format_zip)

# Debugging: Display intermediate DataFrame
print("Result of Query 1:")
print(result_df1.head())
print(result_df1.info())

# Python filtering for Query 2 logic
exclude_statuses = ['Final1', 'Final2', 'Do not Issue', 'Never Issued']
result_df2 = result_df1[
    (~result_df1["Fund Status"].str.lower().isin([s.lower() for s in exclude_statuses])) &  # Exclude specific statuses
    (result_df1["Assignment"] != "Final") & # Additional condition
    (result_df1["KEY"] != "Total")  # Additional condition

]

# Python filtering for the inverse of Query 2 logic
include_statuses = ['Final', 'Final', 'Do not Issue', 'Never Issued']
inverse_result_df2 = result_df1[
    (result_df1["Fund Status"].str.lower().isin([s.lower() for s in include_statuses])) |  # Include specific statuses
    (result_df1["Assignment"] == "Final in prior year") |  # Include this condition
    (result_df1["KEY"] == "Overall Total")  # Include this condition
]




## Export

# Replace "- None -" with None in the DataFrames
result_df2.replace("- None -", None, inplace=True)
inverse_result_df2.replace("- None -", None, inplace=True)

# Generate timestamp for today's date and time
timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

# Define the directory and file name with timestamp
directory = "/Users/nicholasseta/Desktop/Demo File/Final Demo Files"
file_name = f"{timestamp}_demo_file_details.xlsx"
output_file_path = os.path.join(directory, file_name)

# Ensure the directory exists
if not os.path.exists(directory):
    os.makedirs(directory)

# Save the DataFrames to an Excel file with two sheets
with pd.ExcelWriter(output_file_path, engine="xlsxwriter") as writer:
    result_df2.to_excel(writer, sheet_name="full_demo_file", index=False)
    inverse_result_df2.to_excel(writer, sheet_name="removed", index=False)

print(f"File saved to: {output_file_path}")


#################################################################
##K1 Import

# Python filtering for Query 2 logic
exclude_statuses = ['Final 2022', 'Final 2023', 'Do not Issue K-1', 'Never Issued K-1']
result_df_k1_import = result_df1[
    (~result_df1["Fund Status"].str.lower().isin([s.lower() for s in exclude_statuses])) &  # Exclude specific statuses
    (result_df1["K1 Assignment"] != "Final in prior year") & # Additional condition
    (result_df1["K1 KEY"] != "Overall Total") & # Additional condition
    (pd.isnull(result_df1["K1 Identifier"]))  # Check for null values in 'K1 Identifier'


]



# Debugging: Display final filtered DataFrame
print("Result of Python Filtering:")
print(result_df2.head())
print(result_df2.info())




# Define the directory and file name with timestamp
directory = "/Users/nicholasseta/Desktop/Demo File/K1 Import"
file_name = f"{timestamp}_K1_Import_File.csv"
output_file_path2 = os.path.join(directory, file_name)

# Ensure the directory exists
if not os.path.exists(directory):
    os.makedirs(directory)

# Save the DataFrame (assuming result_df2 is defined)
result_df_k1_import.to_csv(output_file_path2, index=False)

print(f"File saved to: {output_file_path2}")

###########################################################################


# Condition to check for "- None -" and other null-like values
none_values_condition = (
    result_df2["Address 1"].str.contains("- None -", na=False) |
    result_df2["Category"].str.contains("- None -", na=False) |
    result_df2["Foreign-Domestic"].str.contains("- None -", na=False) |
    result_df2["Address 1"].isnull() |
    result_df2["Category"].isnull() |
    result_df2["Foreign-Domestic"].isnull()
)

# Filter the DataFrame based on the exception condition
exceptions_df = result_df2[none_values_condition].copy()

# Function to identify specific issues in each row
def identify_issues(row):
    issues = []
    if pd.isnull(row["Address 1"]) or row["Address 1"] == "" or "- None -" in str(row["Address 1"]):
        issues.append("Address 1 is Blank or Invalid")
    if pd.isnull(row["Category"]) or row["Category"] == "" or "- None -" in str(row["Category"]):
        issues.append("Category is Blank or Invalid")
    if pd.isnull(row["Foreign-Domestic"]) or row["Foreign-Domestic"] == "" or "- None -" in str(row["Foreign-Domestic"]):
        issues.append("Foreign-Domestic is Blank or Invalid")
    return ", ".join(issues)

# Apply the identify_issues function row by row
exceptions_df["Issues"] = exceptions_df.apply(identify_issues, axis=1)

# Reorder the columns to place "Issues" at the beginning
exceptions_df = exceptions_df[["Issues"] + [col for col in exceptions_df.columns if col != "Issues"]]

# Export the exceptions DataFrame
timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
directory = "/Users/nicholasseta/Desktop/Demo File/Exception Reports"
file_name = f"{timestamp}_Exception_Report.csv"
output_file_path = os.path.join(directory, file_name)

# Ensure the directory exists
os.makedirs(directory, exist_ok=True)

# Save the DataFrame to a CSV file
exceptions_df.to_csv(output_file_path, index=False)

print(f"Exceptions file saved to: {output_file_path}")

