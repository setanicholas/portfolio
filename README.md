
# Nick Seta - Finance & Technology Professional

**Location**: Exeter, NH  
**Email**: [seta.nicholas@gmail.com](mailto:seta.nicholas@gmail.com)  
**GitHub**: [github.com/NicholasSeta](https://github.com/setanicholas)  
**LinkedIn**: [linkedin.com/in/nicholasseta](https://www.linkedin.com/in/nicholasseta)



---



## 🚀 Professional Summary

Dynamic senior financial systems manager with a strong blend of financial acumen and technical expertise. Proven track record in leveraging advanced applications **(NetSuite, Salesforce, Concur, Snowflake)**, integration platforms **(Boomi, Celigo)**, and technical skills **(SuiteScript, Python, SQL, Power BI)** to streamline operations and drive measurable business growth. Helped sucessfully lead financial systems teams through **8 complex M&A integrations**, **6 enterprise application implementations**, and **3 data warehouse/BI initiatives**, delivering significant efficiency gains and enhanced reporting capabilities.


---


## 💻 Featured Code: 


**The code provided below is my original work and has been reviewed to ensure all sensitive information and proprietary content have been removed.**


**SuiteScript (2.x) Tax Calculations in NetSuite**

**File**: [`disable_tax_calculations.js`](https://github.com/setanicholas/portfolio/blob/main/assets/suitescript/disable_tax_calculations.js)

This NetSuite User Event script automatically controls the activation of tax calculations on records based on creation status, field changes, and posting period conditions. Its value lies in streamlining tax processing, reducing manual effort, preventing calculation errors, and enhancing compliance and auditability through clear logging and automation.

This NetSuite User Event script automates control of tax calculation on records by setting a custom field (custbody_ava_disable_tax_calculation) based on specific business logic. When a record is newly created, it allows tax calculation by default. For edited records, the script checks if the posting period is open, and whether relevant fields (total amount or istaxable status) have changed; if so, it enables tax calculation. Detailed debug logs throughout provide transparency into its decision-making, ensuring accuracy and traceability in financial processing.

---

**SuiteScript (2.x) Search RESTLet**

**File**: [`search_restlet.js`](https://github.com/setanicholas/portfolio/blob/main/assets/suitescript/search_restlet.js)

This NetSuite RESTlet efficiently retrieves and transforms complex financial data by dynamically executing a predefined saved search and aggregating the results into a structured JSON format. By implementing error handling and pagination, it ensures scalability, reliability, and seamless integration with external systems or reporting tools.

---

**SQL - Recreated NetSuite Balance Sheet Leveraging Data Warehouse** 

**File**: [`balance_sheet_recreate.sql`](https://github.com/setanicholas/portfolio/blob/main/assets/sql/BALANCE_SHEET.sql)

The provided **stored procedure** (USP_BALANCESHEET) automates the creation of a comprehensive balance sheet summary by aggregating and standardizing financial data from NetSuite tables, including handling currency conversions and specific account types such as retained earnings. It calculates net income and retained earnings separately, integrating results through union operations to support detailed financial analysis across subsidiaries and fiscal periods. Additionally, it utilizes a **JavaScript** function (GetFiscalYear) to accurately determine fiscal years beginning in April, making it ideal for managing global financial portfolios within ERP systems.

---

**Python - NetSuite Data Extraction Reporting**

**File**: [`netsuite_data_extraction_reporting.py`](https://github.com/setanicholas/portfolio/blob/main/assets/python/netsuite_data_extraction_reporting.py)

One recent contributions includes the development of a highly optimized python script used to streamline and automate tax reporting and team processes. I leveraged NetSuite **RESTLets** to gather real time data from NetSuite necessary for this project. 

This project automates data extraction from NetSuite using OAuth-authenticated REST APIs, transforms and analyzes the retrieved financial data using Pandas and SQL queries, and systematically generates Excel and CSV reports. It includes detailed exception handling and data validation, ensuring accurate reporting for investment portfolios and tax documentation.

---

**Python - Mass PDF Encryption**

**File**: [`pdf_encryption.py`](https://github.com/setanicholas/portfolio/blob/main/assets/python/encryption.py)

This Python script automates the secure handling of PDF documents. Specifically, it processes zipped folders containing multiple PDFs, decrypts and re-encrypts each PDF using individualized passwords sourced from an Excel spreadsheet, and renames the files accordingly for clarity and organization. The script leverages pandas for Excel file handling, PyPDF2 for PDF manipulation, and standard Python libraries for file management. It's particularly designed to preserve data integrity, manage sensitive information securely, and facilitate efficient bulk processing in document-heavy workflows.

---
---

## 🛠️ Core Competencies

- **Financial Systems & ERP**
  NetSuite Architecture & Optimization, System Integration, Data Governance & Compliance

- **Analytics & Business Intelligence**
  Snowflake, Power BI, Python, SQL, JavaScript, Financial Modeling & Analysis

- **Strategic Leadership**
  Cross-functional Team Leadership, IT & Financial Governance, Organizational Change Management

- **Project & Program Management**
  Budgeting & Forecasting, Vendor Negotiation & Management, Stakeholder Communication

- **Cloud Infrastructure & Automation**
  AWS Architecture, Data Lakes & Warehousing, Process Automation, Scalable Solutions

---


## 🔥 About Nick: Data, Finance, and Life in the Granite State

I absolutely love my job. I cannot believe I get to wake up everyday and use technology to help make businesses more efficent. I'm passionate about using data and technology to automate decision-making and tackle tricky financial and operational challenges. When I’m not working, I enjoy spending time playing soccer or exploring the mountains and coastline of my home state, New Hampshire. I love hanging out with my golden retriever, spending quality time with family and friends, and I'm always eager to chat about cars. I'm also excited to be getting married soon!

---

## 📫 Get in Touch

*Please contact me through phone (603-770-9722) or email ([seta.nicholas@gmail.com](mailto:seta.nicholas@gmail.com)) for additional details regarding my portfolio and references.*
