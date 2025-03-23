import time
import math
import random
import urllib.parse
import hashlib
import hmac
import base64
import pandas as pd
import requests
from pandasql import sqldf
from dotenv import load_dotenv
import os
from io import BytesIO
from datetime import datetime

# ----------------------------------------------------------------------------
# 1. Load Environment Variables (Ensure your .env file is excluded via .gitignore)
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
    "demo_main": "1054",
    "demo_k1s": "1055",
    "demo_entities": "1057"
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
# 4. Load Data from API Calls (Replaced Streamlit UI with print statements)
# ----------------------------------------------------------------------------

print("K1 Processing App")
print("🔄 Fetching data from NetSuite... This may take a few minutes.")

try:
    demo_main = fetch_saved_search_results(NETSUITE_SCRIPT_IDS["demo_main"])
    demo_k1s = fetch_saved_search_results(NETSUITE_SCRIPT_IDS["demo_k1s"])
    demo_entities = fetch_saved_search_results(NETSUITE_SCRIPT_IDS["demo_entities"])
except Exception as e:
    print(f"❌ Error fetching NetSuite data: {e}")
    exit(1)

print("🛠️ Processing data and applying SQL transformations...")

# ----------------------------------------------------------------------------
# 5. SQL Query Processing
# ----------------------------------------------------------------------------

pysqldf = lambda q: sqldf(q, globals())

query1 = """
SELECT DISTINCT
    d."K1 KEY" AS "K1 KEY",
    k."INVESTOR K1 ID" AS "K1 Identifier",
    d."Assignment" AS "Demo Assignment",
    d."Review for Transfer" AS "Review for Transfer",
    d."Review for JTWROS" AS "Review for JTWROS",
    d."Date Investment Criteria Complete" AS "Date Investment Criteria Complete",
    d."Date of Fund Transfer" AS "Date of Fund Transfer",
    d."Date of Subscription Agreement" AS "Date of Subscription Agreement",
    d."Investment Accreditation Date" AS "Investment Accreditation Date",
    d."Portal ID" AS "Portal ID",
    d."IE Internal ID" AS "IE Internal ID",
    d."Email" AS "Email",
    d."Hubspot ID" AS "Hubspot ID",
    d."First Name" AS "First Name",
    d."MI" AS "MI",
    d."Last Name" AS "Last Name",
    d."Company Name" AS "Company Name",
    d."Entity Name (37)" AS "Entity Name (37)",
    d."Entity Name (cont)" AS "Entity Name (cont)",
    d."Entity Type" AS "Entity Type",
    d."Individual Sub Type" AS "Individual Sub Type",
    d."Tax ID Country of Origin" AS "Tax ID Country of Origin",
    d."Attention" AS "Attention",
    d."Address 1" AS "Address 1",
    d."Address 2" AS "Address 2",
    d."City" AS "City",
    d."State" AS "State",
    d."Zip" AS "Zip",
    d."Country" AS "Country",
    d."Residential State" AS "Residential State",
    d."Business Sub Type" AS "Business Sub Type",
    d."Via Global Fund" AS "Via Global Fund",
    d."Category" AS "Category",
    d."Entity Code" AS "Entity Code",
    d."K1 Tax ID" AS "K1 Tax ID",
    d."Non-US Tax ID (Legacy)" AS "Non-US Tax ID (Legacy)",
    d."Foreign-Domestic" AS "Foreign-Domestic",
    d."Industry" AS "Industry",
    d."Amount" AS "Amount",
    d."Fund" AS "Fund",
    k."Fund Legal Name" AS "Fund Legal Name",
    d."Fund Name" AS "Fund Name",
    d."Fund (No Hierarchy)" AS "Fund (No Hierarchy)",
    d."Fund ID" AS "Fund ID",
    k."Fund Start Date" AS "Fund Start Date",
    d."Transfer In Date" AS "Transfer In Date",
    e."Name" AS "Transfer In From Name",
    d."Transfer In From" AS "Transfer In From",
    d."Transfer Out Date" AS "Transfer Out Date",
    d."Disregarded Entity" AS "Disregarded Entity",
    d."Ultimate Owner Investor Name" AS "Ultimate Owner Investor Name",
    d."Ultimate Owner SSN" AS "Ultimate Owner SSN",
    k."K1 Assignment" AS "K1 Assignment",
    k."Fund Status" AS "Fund Status"
FROM demo_file d
LEFT JOIN k1s_file k 
    ON d."K1 KEY" = k."NEW EXTERNAL ID" 
LEFT JOIN entities_file e 
    ON e."ID" = d."Transfer In From"
"""

result_df1 = pysqldf(query1)

def format_zip(zip_value):
    if pd.isnull(zip_value):
        return zip_value
    try:
        return f"{int(zip_value):05}"
    except ValueError:
        return zip_value

result_df1["Zip"] = result_df1["Zip"].apply(format_zip)

print("Result of Query 1:")
print(result_df1.head())
print(result_df1.info())

exclude_statuses = ['Final 2022', 'Final 2023', 'Do not Issue K-1', 'Never Issued K-1']
result_df2 = result_df1[
    (~result_df1["Fund Status"].str.lower().isin([s.lower() for s in exclude_statuses])) &
    (result_df1["K1 Assignment"] != "Final in prior year") &
    (result_df1["K1 KEY"] != "Overall Total")
]

include_statuses = ['Final 2022', 'Final 2023', 'Do not Issue K-1', 'Never Issued K-1']
inverse_result_df2 = result_df1[
    (result_df1["Fund Status"].str.lower().isin([s.lower() for s in include_statuses])) |
    (result_df1["K1 Assignment"] == "Final in prior year") |
    (result_df1["K1 KEY"] == "Overall Total")
]

result_df2.replace("- None -", None, inplace=True)
inverse_result_df2.replace("- None -", None, inplace=True)

timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

# ----------------------------------------------------------------------------
# 6. Export Results (Using relative file paths)
# ----------------------------------------------------------------------------

output_dir1 = os.path.join(".", "output", "FinalDemoFiles")
os.makedirs(output_dir1, exist_ok=True)
file_name = f"{timestamp}_demo_file_details.xlsx"
output_file_path = os.path.join(output_dir1, file_name)

with pd.ExcelWriter(output_file_path, engine="xlsxwriter") as writer:
    result_df2.to_excel(writer, sheet_name="full_demo_file", index=False)
    inverse_result_df2.to_excel(writer, sheet_name="removed", index=False)

print(f"File saved to: {output_file_path}")

# ----------------------------------------------------------------------------
# K1 Import Section
# ----------------------------------------------------------------------------

result_df_k1_import = result_df1[
    (~result_df1["Fund Status"].str.lower().isin([s.lower() for s in exclude_statuses])) &
    (result_df1["K1 Assignment"] != "Final in prior year") &
    (result_df1["K1 KEY"] != "Overall Total") &
    (pd.isnull(result_df1["K1 Identifier"]))
]

print("Result of K1 Import Filtering:")
print(result_df_k1_import.head())
print(result_df_k1_import.info())

output_dir2 = os.path.join(".", "output", "K1Import")
os.makedirs(output_dir2, exist_ok=True)
file_name = f"{timestamp}_K1_Import_File.csv"
output_file_path2 = os.path.join(output_dir2, file_name)

result_df_k1_import.to_csv(output_file_path2, index=False)
print(f"File saved to: {output_file_path2}")

none_values_condition = (
    result_df2["Address 1"].str.contains("- None -", na=False) |
    result_df2["Category"].str.contains("- None -", na=False) |
    result_df2["Foreign-Domestic"].str.contains("- None -", na=False) |
    result_df2["Address 1"].isnull() |
    result_df2["Category"].isnull() |
    result_df2["Foreign-Domestic"].isnull()
)

exceptions_df = result_df2[none_values_condition].copy()

def identify_issues(row):
    issues = []
    if pd.isnull(row["Address 1"]) or row["Address 1"] == "" or "- None -" in str(row["Address 1"]):
        issues.append("Address 1 is Blank or Invalid")
    if pd.isnull(row["Category"]) or row["Category"] == "" or "- None -" in str(row["Category"]):
        issues.append("Category is Blank or Invalid")
    if pd.isnull(row["Foreign-Domestic"]) or row["Foreign-Domestic"] == "" or "- None -" in str(row["Foreign-Domestic"]):
        issues.append("Foreign-Domestic is Blank or Invalid")
    return ", ".join(issues)

exceptions_df["Issues"] = exceptions_df.apply(identify_issues, axis=1)
exceptions_df = exceptions_df[["Issues"] + [col for col in exceptions_df.columns if col != "Issues"]]

output_dir3 = os.path.join(".", "output", "ExceptionReports")
os.makedirs(output_dir3, exist_ok=True)
file_name = f"{timestamp}_Exception_Report.csv"
output_file_path3 = os.path.join(output_dir3, file_name)

exceptions_df.to_csv(output_file_path3, index=False)
print(f"Exceptions file saved to: {output_file_path3}")
