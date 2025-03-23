#!/usr/bin/env python3
import os
import zipfile
import io
import pandas as pd
from PyPDF2 import PdfReader, PdfWriter

# Define paths
zip_folder = "/path_to_pdf_folder_holding_zips"
output_folder = "/path_to_output_folder"
xlsx_path = "/path_to_folder_containing_passwords"

# Ensure the output folder exists
os.makedirs(output_folder, exist_ok=True)

# Load XLSX file with explicit dtype to preserve leading zeros
df = pd.read_excel(
    xlsx_path,
    dtype={
        "K1 Identifier": str,
        "K1 Tax ID": str,
        "Password SSN (without hyphens)": str  # Read password as string to preserve leading 0s
    }
)

# Optionally print out all Excel column names to verify headers
print("Excel Columns:", list(df.columns))

# Build a mapping:
# Key: normalized K1 Identifier (from Excel Column "K1 Identifier")
# Value: Tuple (PDF password from column "Password SSN (without hyphens)", new filename prefix from column "K-1 Investor")
mapping = {}
for index, row in df.iterrows():
    # Normalize by stripping whitespace and converting to lowercase
    k1_identifier = str(row["AAR File Name"]).strip().lower() # /////////////////////////////////////////////////////////////////////////////////////////////
    # Directly use the string, ensuring any leading zeros are kept
    password = str(row["Password SSN (without hyphens)"]).strip() # /////////////////////////////////////////////////////////////////////////////////////////
    col_j = str(row["K-1 Investor"]).strip()       # Prefix for the new filename  # /////////////////////////////////////////////////////////////////////////
    
    mapping[k1_identifier] = (password, col_j)

# Debug: Print all keys and passwords from the Excel mapping
print("\nMapping dictionary contents:")
for key, (password, col_j) in mapping.items():
    print(f"  Identifier: '{key}' | Password: '{password}' | Prefix: '{col_j}'")

# Process each zip file in the specified folder
for file_name in os.listdir(zip_folder):
    if file_name.lower().endswith('.zip'):
        zip_path = os.path.join(zip_folder, file_name)
        print(f"\nProcessing zip file: {zip_path}")
        with zipfile.ZipFile(zip_path, 'r') as zf:
            # Process each file within the zip
            for member in zf.namelist():
                if member.lower().endswith('.pdf'):
                    print(f"  Processing PDF: {member}")
                    
                    # Extract the K1 Identifier from the PDF file name.
                    # Expected naming: "<K1 Identifier>_2024.pdf"
                    base_name = os.path.basename(member)
                    if base_name.endswith("_2024.pdf"):
                        k1_id = base_name[:-len("_2024.pdf")]
                    else:
                        # Fallback: assume identifier is before the first underscore
                        parts = base_name.split('_')
                        k1_id = parts[0] if parts else None
                    
                    if not k1_id:
                        print(f"    Could not determine K1 Identifier for {member}. Skipping.")
                        continue

                    # Normalize the extracted identifier for matching
                    k1_id_normalized = k1_id.strip().lower()
                    # Remove trailing '.0' if it exists (if identifier was stored as a number in Excel)
                    if k1_id_normalized.endswith('.0'):
                        k1_id_normalized = k1_id_normalized[:-2]
                    print(f"    Extracted K1 Identifier: '{k1_id_normalized}'")
                    
                    # Look up the corresponding password and new name prefix using the normalized K1 Identifier
                    if k1_id_normalized not in mapping:
                        print(f"    K1 Identifier '{k1_id_normalized}' not found in Excel mapping. Skipping {member}.")
                        continue
                    password, col_j = mapping[k1_id_normalized]

                    # Debug: Confirm password before encrypting
                    print(f"    Using password: '{password}' for encryption.")
                    
                    # Read the PDF from the zip archive into memory
                    with zf.open(member) as pdf_file:
                        pdf_bytes = pdf_file.read()
                        pdf_stream = io.BytesIO(pdf_bytes)
                    
                    try:
                        # Open the PDF, copy its pages, and encrypt using the password
                        reader = PdfReader(pdf_stream)
                        writer = PdfWriter()
                        for page in reader.pages:
                            writer.add_page(page)
                        writer.encrypt(password)
                        
                        # Build new file name using the cleaned K1 Identifier: "<Portal ID>_<K1 Identifier>_2024.pdf"
                        new_file_name = f"{k1_id_normalized}_{col_j}.pdf"
                        output_path = os.path.join(output_folder, new_file_name)
                        
                        # Save the encrypted PDF to the output folder
                        with open(output_path, "wb") as f_out:
                            writer.write(f_out)
                        print(f"    Saved encrypted PDF to: {output_path}")
                    except Exception as e:
                        print(f"    Error processing {member}: {e}")
