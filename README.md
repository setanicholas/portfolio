
# Nick Seta - Finance & Technology

**Location**: Exeter, NH  
**Email**: [seta.nicholas@gmail.com](mailto:seta.nicholas@gmail.com)  
**GitHub**: [github.com/NicholasSeta](https://github.com/setanicholas)  
**LinkedIn**: [linkedin.com/in/nicholasseta](https://www.linkedin.com/in/nicholasseta)



---

## 🚀 Professional Summary

Senior financial systems manager with a strong blend of financial acumen, technical expertise, and leadership skills. Proven track record in leveraging advanced applications **(NetSuite, Salesforce, Concur, Snowflake)**, integration platforms **(Boomi, Celigo)**, and technical skills **(SuiteScript, Python, SQL, Power BI)** to drive measurable business growth. I used this blend of skills to sucessfully lead financial systems teams through **8 M&A integrations**, **5 enterprise application implementations**, and **2 data warehouse/BI initiatives**, delivering significant efficiency gains and enhanced reporting capabilities. I'm also proud to have onboarded and **trained the ERP team** at ISW, as well as **chaired the Change Control Board**, which was the primary Business Systems project management tool at ISW. 

While I take great pride in my soft skills—including being approachable, helpful, and consistently striving to learn—I'm equally proud of my technical accomplishments. Below are some examples of technical projects I've completed throughout my career. I'd greatly appreciate your feedback!

---

## 💻 Featured Code: 


**The code provided below is my original work and has been reviewed to ensure all sensitive information and proprietary content have been removed.**


**SuiteScript - User Event - Tax Calculations in NetSuite**

**File**: [`disable_tax_calculations.js`](https://github.com/setanicholas/portfolio/blob/main/assets/suitescript/disable_tax_calculations.js)

This NetSuite User Event script automatically controls the activation of tax calculations on records based on creation status, field changes, and posting period conditions. Its value lies in streamlining tax processing, reducing manual effort, preventing calculation errors, and enhancing compliance and auditability through clear logging and automation.

This NetSuite User Event script automates control of tax calculation on records by setting a custom field (custbody_ava_disable_tax_calculation) based on specific business logic. When a record is newly created, it allows tax calculation by default. For edited records, the script checks if the posting period is open, and whether relevant fields (total amount or istaxable status) have changed; if so, it enables tax calculation. Detailed debug logs throughout provide transparency into its decision-making, ensuring accuracy and traceability in financial processing.

---

**SuiteScript - Scheduled - Monthly Subsidiary Sync**

**File**: [`monthy_sub_sync.js`](https://github.com/setanicholas/portfolio/blob/main/assets/suitescript/monthy_sub_sync.js)

Created a NetSuite Scheduled Script that runs monthly to automatically update customer records with newly added subsidiaries, ensuring consistent data and preventing synchronization errors. Leveraged SuiteScript 2.0 search functionality to identify subsidiaries flagged for updates and systematically applied changes across customer records. 

---

**SuiteScript - RESTlet - Saved Search Aggrigation (To be called by a Python script)**

**File**: [`search_restlet.js`](https://github.com/setanicholas/portfolio/blob/main/assets/suitescript/search_restlet.js)

This NetSuite RESTlet efficiently retrieves and transforms complex financial data by dynamically executing a predefined saved search and aggregating the results into a structured JSON format. By implementing error handling and pagination, it ensures scalability, reliability, and seamless integration with external systems or reporting tools.

---

**SQL - Recreate NetSuite Balance Sheet** 

**File**: [`balance_sheet_recreate.sql`](https://github.com/setanicholas/portfolio/blob/main/assets/sql/balance_sheet.sql)

The provided **stored procedure** (USP_BALANCESHEET) leverages **CTE** to automate the creation of a comprehensive balance sheet summary by aggregating and standardizing financial data from NetSuite tables, including handling currency conversions and specific account types such as retained earnings. It calculates net income and retained earnings separately, integrating results through union operations to support detailed financial analysis across **subsidiaries** and fiscal periods. Additionally, it utilizes a **JavaScript** function (GetFiscalYear) to accurately determine fiscal years beginning in April, as NetSuite was not capable of showing the balance sheet necessary for our India subsidiaries. This was finaly presented in Power BI where our finance team could easily access.

---
**SQL - Salesforce Billing Sub Invoice Line Fix** 

**File**: [`sub_invoice_lines.sql`](https://github.com/setanicholas/portfolio/blob/main/assets/sql/sub_invoice_lines.sql)

This script implements a stored procedure that creates and populates tables to reconcile invoice line data from Salesforce and NetSuite. It extracts, transforms, and merges raw data from both systems, updating fields like invoice amounts, tax details, and statuses to fix discrepancies. The unified reporting table generated by the script improves data accuracy and addresses sub invoice line issues between one of the most complex integrations in the Order to Cash world.

---

**Python - NetSuite Data Extraction for Reporting**

**File**: [`netsuite_data_extraction_reporting.py`](https://github.com/setanicholas/portfolio/blob/main/assets/python/netsuite_data_extraction_reporting.py)

One recent contributions includes the development of a highly optimized python script used to streamline and automate tax reporting and team processes. I leveraged NetSuite **RESTlets** to gather real time data from NetSuite necessary for this project. 

This project automates data extraction from NetSuite using OAuth-authenticated REST APIs, transforms and analyzes the retrieved financial data using Pandas and SQL queries, and systematically generates Excel and CSV reports. It includes detailed exception handling and data validation, ensuring accurate reporting for investment portfolios and tax documentation.

I've been investigating the optimimal way to present this data. I'm stuck between Streamlit and Django. Would love to hear your thoughts! 

---

**Python - Mass PDF Encryption**

**File**: [`pdf_encryption.py`](https://github.com/setanicholas/portfolio/blob/main/assets/python/encryption.py)

This Python script automates the secure handling of PDF documents. Specifically, it processes zipped folders containing multiple PDFs, decrypts and re-encrypts each PDF using individualized passwords sourced from an Excel spreadsheet, and renames the files accordingly for clarity and organization. The script leverages pandas for Excel file handling, PyPDF2 for PDF manipulation, and standard Python libraries for file management. It's particularly designed to preserve data integrity, manage sensitive information securely, and facilitate efficient bulk processing in document-heavy workflows.

---
---

## 🛠️ Core Competencies

- **Financial Systems & ERP**
  NetSuite Architecture & Optimization, Saleforce CPQ & Billing, System Integration

- **Analytics & Business Intelligence**
  Snowflake, Power BI, Python, SQL, JavaScript, Financial Modeling & Analysis

- **Strategic Leadership**
  Cross-functional Team Leadership, Organizational Change Management

---


## 🔥 About Nick: Data, Finance, and Life in the Granite State

I absolutely love what I do. It sounds corny, but can't believe I get to wake up everyday and use technology to help make businesses smoother and more efficent. When I’m not working, I enjoy spending time playing soccer or exploring the mountains and coastline of my home state, New Hampshire. I love hanging out with my golden retriever, spending quality time with family and friends, and I'm always eager to chat about cars. I'm also excited to be getting married soon!

---

## 🤙 Get in Touch

*Please contact me through phone (603-770-9722) or email ([seta.nicholas@gmail.com](mailto:seta.nicholas@gmail.com)) for additional details regarding my portfolio and references.*
