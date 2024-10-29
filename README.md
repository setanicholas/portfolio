
# Nicholas Seta - Finance & Technology Professional

**Location**: Exeter, NH  
**Email**: [seta.nicholas@gmail.com](mailto:seta.nicholas@gmail.com)  
**GitHub**: [github.com/NicholasSeta](https://github.com/setanicholas)  
**LinkedIn**: [LinkedIn](https://www.linkedin.com/in/nicholasseta)

---

## 🚀 Professional Summary

Nick has helped build and transform the Finance and IT functions three times, leveraging approaches refined over five years of experience in finance and technology. His experience spans companies ranging from a $1 million privately owned construction company to a $500 million-plus private equity-backed software company. Nick specializes in implementing processes that increase the capacity of IT and Finance to deliver cost-optimized solutions that enhance company valuation. His achievements include leading a team through 8 separate M&A integrations involving 2,000 employees and 20,000 customer accounts, reducing consultant spend by over $500,000 per year, configuring 2 data warehouses, and supporting the implementation of over 10 enterprise applications. Known for his technical expertise in both computer science and finance, Nick excels at creating financial systems that empower companies and deliver long-term value to stakeholders.

---

## 💻 Featured Code: 

**Balance Sheet** 

**File**: [`Balance_Sheet.sql`](https://github.com/setanicholas/portfolio/blob/main/assets/sql/BALANCE_SHEET.sql)

The provided code creates a stored procedure (USP_BALANCESHEET) that generates a balance sheet summary by creating a table called T_BALANCESHEET. The table aggregates financial data from several NetSuite data tables, including TRANSACTIONACCOUNTINGLINE, ACCOUNT, and TRANSACTION. The procedure performs the following key functions:

Data Aggregation for Balance Sheet Accounts:

Queries and aggregates information about all accounts (AllAccounts) including general ledger amounts (GLAmount), account details, subsidiary, currency, and transaction metadata.
Includes data for specific transaction types and account hierarchies, considering exchange rates when converting amounts to USD.
Handling Retained Earnings:

Separately calculates retained earnings (RetainedEarnings) as they are handled differently from other account types.
Net Income and Retained Earnings for Specific Periods:

Defines placeholder views (PeriodAccountsNetIncome and PeriodAccountsRetainedEarnings) to account for net income and retained earnings for specific fiscal periods and subsidiaries.
Combining Results:

Combines the data from all defined subqueries into a comprehensive balance sheet table using a union (UNION ALL) operation.
Fiscal Year Calculation Function:

Defines a JavaScript function (GetFiscalYear) to determine the fiscal year based on the date, specifically considering that the fiscal year starts in April.
The overall purpose of this procedure is to create a comprehensive balance sheet that aggregates and standardizes financial data for various periods, accounts, and subsidiaries, allowing for detailed financial analysis for the ERP system. 

This process is suitable for automating balance sheet generation for different fiscal years and subsidiaries, making it highly relevant for managing financial portfolios across a company's global operations.


---

## 💻 Featured Code: 

**Revenue Planning**

One of my notable contributions includes the development of a highly optimized SQL script for **Revenue Planning** used to streamline and automate financial forecasting processes across multiple entities. You can check out the file in my portfolio:

**File**: [`REV_PLAN_VIEW.sql`](https://github.com/setanicholas/portfolio/blob/main/assets/sql/T_COLLECTIONS_AT_RISK.sql)

This SQL view was designed to handle complex revenue forecasts, incorporating multi-currency, multi-subsidiary data from over 100 entities. It's a core component of our automated financial reporting infrastructure.

---

## 💼 Experience

### **ERP Team Lead**  
*insightsoftware* | SaaS & Professional Services | Private Equity-backed  
**September 2023 – Present**

- **Orchestrated a scalable financial systems architecture** by eliminating technical debt, optimizing ERP integrations, and aligning them with long-term growth objectives.
- **Spearheaded a cutting-edge data analytics pipeline** leveraging **Snowflake, Power BI**, and **Python** to deliver critical insights that empowered C-suite executives to make informed business decisions.
- Develop ERP integration playbook for **8 M&A acquisitions**. These companies integrated into a NetSuite instance consisting of over 100 subsidiaries with multi-currency transactions across 20 foreign entities.
- Championed **IT Governance best practices**, ensuring a balance between operational flexibility and data security.

### **NetSuite Administrator**  
*Insightsoftware*  
**February 2022 – September 2023**

- Rapidly gained mastery over a broad technology stack, including **Salesforce, Boomi**, and **OpenAir**, leading to **$500k+ in annual cost savings** by reducing external technical consultant dependency.
- Enhanced internal systems, fostering a 40% improvement in project delivery timelines by optimizing workflows and prioritizing key projects in change control meetings.

### **Financial Analyst & NetSuite Administrator**  
*Infinity Massage Chairs* | Wholesale Distribution  
**May 2017 – February 2022**

- Reported directly to the CFO, implementing and automating critical financial and operational processes through **SQL, Excel Macros**, and **Power BI**.
- Drove the company-wide **NetSuite implementation**, enhancing efficiency and delivering comprehensive business intelligence to support executive decision-making.

---

## 🎓 Education

### **MSc in Finance**  
The University of Edinburgh | Edinburgh, Scotland  
*Graduated with Honors*

- **QS Top World University Ranking**
- Varsity Soccer Player

### **BSBA in Finance and Management**  
Saint Joseph’s College of Maine | Standish, Maine  
*Graduated with Honors*

- 4-Year Varsity Soccer Player  
- Recipient of the **Unsung Hero Award**, later renamed in my honor

---

## 🛠️ Core Competencies

- **Financial Systems Architecture**  
  ERP Optimization, M&A Integrations, Data Governance
- **Advanced Analytics & BI**  
  Snowflake, Power BI, Python, SQL, JavaScript
- **Leadership & Strategic Management**  
  Cross-functional Leadership, IT Governance, Change Management
- **Project Management**  
  Budgeting & Forecasting, Vendor Management, Stakeholder Alignment
- **Cloud & Data Infrastructure**  
  AWS, Azure, Data Lakes, Automation, Scalability

---

## 🔥 Passion Projects

I am passionate about leveraging data to drive decision-making at scale and using technology to solve complex financial and operational problems. In my free time, I contribute to open-source projects and mentor young professionals in the field of data analytics and ERP systems.

---

## 📫 Get in Touch

*Please contact me through my professional email for additional details regarding my portfolio and references.*

---

### **Disclaimer**  
For privacy reasons, some personal details have been intentionally withheld. Full professional background and additional references are available upon request.
"""
