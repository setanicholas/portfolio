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

ACCT_ID = os.getenv("ACCT_ID")
API_CONSUMER_KEY = os.getenv("API_CONSUMER_KEY")
API_CONSUMER_SECRET = os.getenv("API_CONSUMER_SECRET")
AUTH_TOKEN = os.getenv("AUTH_TOKEN")
AUTH_TOKEN_SECRET = os.getenv("AUTH_TOKEN_SECRET")

API_REALM = ACCT_ID
DEPLOY_ID = '1'
SIG_METHOD = 'HMAC-SHA256'
OAUTH_VER = '1.0'
API_URL = f'https://{ACCT_ID}.restlets.api.netsuite.com/app/site/hosting/restlet.nl'
REQ_METHOD = 'GET'

SCRIPT_IDS = {
    "primary_demo": "0000",
    "k1_demo": "0000",
    "entity_demo": "0000"
}

# ----------------------------------------------------------------------------
# 2. Helper Functions for OAuth Signing
# ----------------------------------------------------------------------------

def generate_nonce(length=11):
    return ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', k=length))

def create_signature(api_url, req_method, nonce, timestamp, script_id):
    data = (
        f"deploy={DEPLOY_ID}"
        f"&oauth_consumer_key={API_CONSUMER_KEY}"
        f"&oauth_nonce={nonce}"
        f"&oauth_signature_method={SIG_METHOD}"
        f"&oauth_timestamp={timestamp}"
        f"&oauth_token={AUTH_TOKEN}"
        f"&oauth_version={OAUTH_VER}"
        f"&script={script_id}"
    )

    encoded_url = urllib.parse.quote(api_url, safe='~()*!.\'')
    encoded_data = urllib.parse.quote(data, safe='~()*!.\'')
    signature_base_string = f"{req_method}&{encoded_url}&{encoded_data}"

    signing_key = f"{urllib.parse.quote(API_CONSUMER_SECRET, safe='~()*!.')}&{urllib.parse.quote(AUTH_TOKEN_SECRET, safe='~()*!.')}"
    
    signature_bytes = hmac.new(
        signing_key.encode('utf-8'),
        signature_base_string.encode('utf-8'),
        hashlib.sha256
    ).digest()

    return urllib.parse.quote(base64.b64encode(signature_bytes).decode('utf-8'), safe='~()*!.\'')

def create_auth_header(script_id):
    nonce = generate_nonce()
    timestamp = int(time.time())
    oauth_sig = create_signature(API_URL, REQ_METHOD, nonce, timestamp, script_id)
    
    return (
        f'OAuth realm="{API_REALM}",'
        f'oauth_token="{AUTH_TOKEN}",'
        f'oauth_consumer_key="{API_CONSUMER_KEY}",'
        f'oauth_nonce="{nonce}",'
        f'oauth_timestamp="{timestamp}",'
        f'oauth_signature_method="{SIG_METHOD}",'
        f'oauth_version="{OAUTH_VER}",'
        f'oauth_signature="{oauth_sig}"'
    )

# ----------------------------------------------------------------------------
# 3. Fetch Data from NetSuite API
# ----------------------------------------------------------------------------

def fetch_data(script_id):
    query_params = f"script={script_id}&deploy={DEPLOY_ID}"
    url = f"{API_URL}?{query_params}"
    headers = {
        'Authorization': create_auth_header(script_id),
        'Content-Type': 'application/json'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return pd.DataFrame(response.json())

# ----------------------------------------------------------------------------
# 4. Load Data from API Calls (Using print statements)
# ----------------------------------------------------------------------------

print("K1 Processing App")
print("🔄 Fetching data from API... This may take a few minutes.")

try:
    primary_data = fetch_data(SCRIPT_IDS["primary_demo"])
    k1_data = fetch_data(SCRIPT_IDS["k1_demo"])
    entity_data = fetch_data(SCRIPT_IDS["entity_demo"])
except Exception as e:
    print(f"❌ Error fetching data: {e}")
    exit(1)

print("🛠️ Processing data and applying SQL transformations...")

# ----------------------------------------------------------------------------
# 5. SQL Query Processing
# ----------------------------------------------------------------------------

run_query = lambda q: sqldf(q, globals())

sql_query = """
SELECT DISTINCT
    d."K1 KEY" AS "K1_KEY",
    k."INVESTOR K1 ID" AS "K1_ID",
    d."Assignment" AS "Demo_Assignment",
    d."Review for Transfer" AS "Review_Transfer",
    d."Review for JTWROS" AS "Review_JTWROS",
    d."Date Investment Criteria Complete" AS "Date_Criteria_Complete",
    d."Date of Fund Transfer" AS "Date_Fund_Transfer",
    d."Date of Subscription Agreement" AS "Date_Subscription_Agreement",
    d."Investment Accreditation Date" AS "Investment_Accreditation_Date",
    d."Portal ID" AS "Portal_ID",
    d."IE Internal ID" AS "Internal_ID",
    d."Email" AS "Email",
    d."Hubspot ID" AS "Hubspot_ID",
    d."First Name" AS "First_Name",
    d."MI" AS "Middle_Initial",
    d."Last Name" AS "Last_Name",
    d."Company Name" AS "Company_Name",
    d."Entity Name (37)" AS "Entity_Name_37",
    d."Entity Name (cont)" AS "Entity_Name_Cont",
    d."Entity Type" AS "Entity_Type",
    d."Individual Sub Type" AS "Individual_Sub_Type",
    d."Tax ID Country of Origin" AS "Tax_Country",
    d."Attention" AS "Attention",
    d."Address 1" AS "Address_1",
    d."Address 2" AS "Address_2",
    d."City" AS "City",
    d."State" AS "State",
    d."Zip" AS "Zip_Code",
    d."Country" AS "Country",
    d."Residential State" AS "Residential_State",
    d."Business Sub Type" AS "Business_Sub_Type",
    d."Via Global Fund" AS "Via_Global_Fund",
    d."Category" AS "Category",
    d."Entity Code" AS "Entity_Code",
    d."K1 Tax ID" AS "K1_Tax_ID",
    d."Non-US Tax ID (Legacy)" AS "Legacy_Tax_ID",
    d."Foreign-Domestic" AS "Foreign_Domestic",
    d."Industry" AS "Industry",
    d."Amount" AS "Amount",
    d."Fund" AS "Fund",
    k."Fund Legal Name" AS "Fund_Legal_Name",
    d."Fund Name" AS "Fund_Name",
    d."Fund (No Hierarchy)" AS "Fund_No_Hierarchy",
    d."Fund ID" AS "Fund_ID",
    k."Fund Start Date" AS "Fund_Start_Date",
    d."Transfer In Date" AS "Transfer_In_Date",
    e."Name" AS "Transfer_From_Name",
    d."Transfer In From" AS "Transfer_From",
    d."Transfer Out Date" AS "Transfer_Out_Date",
    d."Disregarded Entity" AS "Disregarded_Entity",
    d."Ultimate Owner Investor Name" AS "Owner_Name",
    d."Ultimate Owner SSN" AS "Owner_SSN",
    k."K1 Assignment" AS "K1_Assignment",
    k."Fund Status" AS "Fund_Status"
FROM demo_file d
LEFT JOIN k1s_file k 
    ON d."K1 KEY" = k."NEW EXTERNAL ID" 
LEFT JOIN entities_file e 
    ON e."ID" = d."Transfer In From"
"""

primary_df = run_query(sql_query)

def zip_formatter(zip_val):
    if pd.isnull(zip_val):
        return zip_val
    try:
        return f"{int(zip_val):05}"
    except ValueError:
        return zip_val

primary_df["Zip_Code"] = primary_df["Zip_Code"].apply(zip_formatter)

print("Result of SQL Query:")
print(primary_df.head())
print(primary_df.info())

exclude_status_list = ['Final 2022', 'Final 2023', 'Do not Issue K-1', 'Never Issued K-1']
filtered_df = primary_df[
    (~primary_df["Fund_Status"].str.lower().isin([s.lower() for s in exclude_status_list])) &
    (primary_df["K1_Assignment"] != "Final in prior year") &
    (primary_df["K1_KEY"] != "Overall Total")
]

include_status_list = ['Final 2022', 'Final 2023', 'Do not Issue K-1', 'Never Issued K-1']
inverse_filtered_df = primary_df[
    (primary_df["Fund_Status"].str.lower().isin([s.lower() for s in include_status_list])) |
    (primary_df["K1_Assignment"] == "Final in prior year") |
    (primary_df["K1_KEY"] == "Overall Total")
]

filtered_df.replace("- None -", None, inplace=True)
inverse_filtered_df.replace("- None -", None, inplace=True)

current_timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

# ----------------------------------------------------------------------------
# 6. Export Results (Using relative file paths)
# ----------------------------------------------------------------------------

export_dir1 = os.path.join(".", "output", "FinalDemoFiles")
os.makedirs(export_dir1, exist_ok=True)
file_name = f"{current_timestamp}_demo_file_details.xlsx"
export_path1 = os.path.join(export_dir1, file_name)

with pd.ExcelWriter(export_path1, engine="xlsxwriter") as writer:
    filtered_df.to_excel(writer, sheet_name="full_demo_file", index=False)
    inverse_filtered_df.to_excel(writer, sheet_name="removed", index=False)

print(f"File saved to: {export_path1}")

# ----------------------------------------------------------------------------
# K1 Import Section
# ----------------------------------------------------------------------------

k1_import_df = primary_df[
    (~primary_df["Fund_Status"].str.lower().isin([s.lower() for s in exclude_status_list])) &
    (primary_df["K1_Assignment"] != "Final in prior year") &
    (primary_df["K1_KEY"] != "Overall Total") &
    (pd.isnull(primary_df["K1_ID"]))
]

print("Result of K1 Import Filtering:")
print(k1_import_df.head())
print(k1_import_df.info())

export_dir2 = os.path.join(".", "output", "K1Import")
os.makedirs(export_dir2, exist_ok=True)
file_name = f"{current_timestamp}_K1_Import_File.csv"
export_path2 = os.path.join(export_dir2, file_name)

k1_import_df.to_csv(export_path2, index=False)
print(f"File saved to: {export_path2}")

issue_condition = (
    filtered_df["Address_1"].str.contains("- None -", na=False) |
    filtered_df["Category"].str.contains("- None -", na=False) |
    filtered_df["Foreign_Domestic"].str.contains("- None -", na=False) |
    filtered_df["Address_1"].isnull() |
    filtered_df["Category"].isnull() |
    filtered_df["Foreign_Domestic"].isnull()
)

issues_df = filtered_df[issue_condition].copy()

def diagnose_issues(row):
    problems = []
    if pd.isnull(row["Address_1"]) or row["Address_1"] == "" or "- None -" in str(row["Address_1"]):
        problems.append("Address 1 is Blank or Invalid")
    if pd.isnull(row["Category"]) or row["Category"] == "" or "- None -" in str(row["Category"]):
        problems.append("Category is Blank or Invalid")
    if pd.isnull(row["Foreign_Domestic"]) or row["Foreign_Domestic"] == "" or "- None -" in str(row["Foreign_Domestic"]):
        problems.append("Foreign/Domestic is Blank or Invalid")
    return ", ".join(problems)

issues_df["Issues"] = issues_df.apply(diagnose_issues, axis=1)
issues_df = issues_df[["Issues"] + [col for col in issues_df.columns if col != "Issues"]]

export_dir3 = os.path.join(".", "output", "ExceptionReports")
os.makedirs(export_dir3, exist_ok=True)
file_name = f"{current_timestamp}_Exception_Report.csv"
export_path3 = os.path.join(export_dir3, file_name)

issues_df.to_csv(export_path3, index=False)
print(f"Exceptions file saved to: {export_path3}")
