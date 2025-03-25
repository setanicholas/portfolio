--#region Portfolio Example - USD Conversion
/*
Fields to add:
- document number
- memo
- posting period
- hyperlink
- customer
- subsidiary
- business unit
*/

CREATE OR REPLACE PROCEDURE PUBLIC.USP_BALANCESHEET_PORTFOLIO()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

CREATE OR REPLACE TABLE PUBLIC.T_BALANCESHEET_PORTFOLIO AS 
WITH AllAccounts AS (
    SELECT DISTINCT 
        SUM(tal.amount) AS GLAmount, 
        A.acctnumber AS AccountNumber, 
        A.fullname AS AccountName,
        TL.department AS Department,
        TL.class AS Class,
        TL.location AS Location,
        ap.startdate AS PostingPeriodStartDate,
        tl.subsidiary AS Subsidiary,
        c.name AS Currency,
        a.parent AS SubAccountOf,
        a.accttype AS AccountType,
        sal.fullname AS SubAccountName,
        t.type AS TransactionType,
        t.id AS TransactionID,
        tal.accountingbook AS AccountingBook,
        a.displaynamewithhierarchy AS AccountNameHierarchy,
        (CASE 
            WHEN SUM(tal.amount * cer.currentrate) IS NULL OR SUM(cer.currentrate) = 0 THEN SUM(tal.amount)
            ELSE SUM(tal.amount * cer.currentrate)
        END) AS GLAmountUSD,
        s.name AS SubsidiaryName,
        cer.currentrate AS ExchangeRate,
        YEAR(ap.startdate) AS USFiscalYear,
        MONTH(ap.startdate) AS TransactionMonth,
        GetFiscalYear(ap.startdate) AS FiscalYear,
        t.tranid AS DocumentNumber,
        tl.id AS LineID,
        CONCAT(tl.subsidiary, CONCAT(t.postingperiod, c.name)) AS SubPeriodCurrency,
        t.memo AS Memo,
        tl.createdfrom AS CreatedFrom,
        tl.memo AS TranLineMemo,
        CASE 
            WHEN tl.memo = 'Rev Rec Source' OR tl.memo = 'Rev Rec Destination' 
            THEN 'Filter Out Journal Lines with Rev Rec Indicator' 
            ELSE 'Keep Journal Lines with Rev Rec Indicator'
        END AS RevRecSource
    FROM SOURCE_DB.TRANSACTIONACCOUNTINGLINE tal 
    LEFT JOIN SOURCE_DB.TRANSACTION T
        ON T.id = tal.transaction
    LEFT JOIN SOURCE_DB.ACCOUNT A 
        ON tal.account = A.id
    LEFT JOIN SOURCE_DB.TRANSACTIONLINE TL
        ON CONCAT(TL.transaction, tl.id) = CONCAT(tal.transaction, tal.transactionline)
    FULL JOIN SOURCE_DB.ACCOUNTINGPERIOD AP
        ON T.postingperiod = AP.id
    LEFT JOIN SOURCE_DB.SUBSIDIARY S
        ON S.id = TL.subsidiary
    LEFT JOIN SOURCE_DB.CURRENCY C
        ON S.currency = C.id
    LEFT JOIN SOURCE_DB.ACCOUNT sal
        ON A.parent = sal.id
    LEFT JOIN SOURCE_DB.CONSOLIDATEDEXCHANGERATE cer 
        ON cer.fromcurrency = C.id 
           AND cer.postingperiod = AP.id 
           AND cer.fromsubsidiary = S.id 
           AND cer.tosubsidiary = 1 
           AND cer.accountingbook = 1
    WHERE tal.posting = 'T'
      AND TL.id = tal.transactionline
      AND A.acctnumber <> '<RETAINED_EARNINGS_ACCOUNT>'
    GROUP BY A.acctnumber,
             A.fullname,
             TL.department,
             TL.class,
             TL.location,
             ap.startdate,
             tl.subsidiary,
             C.name,
             A.parent,
             A.accttype,
             sal.fullname,
             t.type,
             t.id,
             tal.accountingbook,
             a.displaynamewithhierarchy,
             s.name,
             cer.currentrate,
             YEAR(ap.startdate),
             MONTH(ap.startdate),
             GetFiscalYear(ap.startdate),
             t.tranid,
             tl.id,
             CONCAT(tl.subsidiary, CONCAT(t.postingperiod, C.name)),
             t.memo,
             tl.createdfrom,
             tl.memo,
             CASE 
                WHEN tl.memo = 'Rev Rec Source' OR tl.memo = 'Rev Rec Destination' 
                THEN 'Filter Out Journal Lines with Rev Rec Indicator' 
                ELSE 'Keep Journal Lines with Rev Rec Indicator'
             END
    HAVING SUM(tal.amount) <> 0
),
RetainedEarnings AS (
    SELECT DISTINCT
        SUM(-tal.amount) AS GLAmount,
        '<RETAINED_EARNINGS_ACCOUNT>' AS AccountNumber,
        'Retained Earnings' AS AccountName,
        TL.department AS Department,
        TL.class AS Class,
        TL.location AS Location,
        ap.startdate AS PostingPeriodStartDate,
        tl.subsidiary AS Subsidiary,
        C.name AS Currency,
        A.parent AS SubAccountOf,
        A.accttype AS AccountType,
        sal.fullname AS SubAccountName,
        t.type AS TransactionType,
        t.id AS TransactionID,
        tal.accountingbook AS AccountingBook,
        a.displaynamewithhierarchy AS AccountNameHierarchy,
        (CASE 
            WHEN SUM(-tal.amount * cer.currentrate) IS NULL OR SUM(cer.currentrate) = 0 THEN SUM(tal.amount)
            ELSE SUM(-tal.amount * cer.currentrate)
        END) AS GLAmountUSD,
        s.name AS SubsidiaryName,
        cer.currentrate AS ExchangeRate,
        YEAR(ap.startdate) AS USFiscalYear,
        MONTH(ap.startdate) AS TransactionMonth,
        GetFiscalYear(ap.startdate) AS FiscalYear,
        t.tranid AS DocumentNumber,
        tl.id AS LineID,
        CONCAT(tl.subsidiary, CONCAT(t.postingperiod, C.name)) AS SubPeriodCurrency,
        t.memo AS Memo,
        tl.createdfrom AS CreatedFrom,
        tl.memo AS TranLineMemo,
        CASE 
            WHEN tl.memo = 'Rev Rec Source' OR tl.memo = 'Rev Rec Destination' 
            THEN 'Filter Out Journal Lines with Rev Rec Indicator' 
            ELSE 'Keep Journal Lines with Rev Rec Indicator'
        END AS RevRecSource
    FROM SOURCE_DB.TRANSACTIONACCOUNTINGLINE tal 
    LEFT JOIN SOURCE_DB.TRANSACTION T
        ON T.id = tal.transaction
    LEFT JOIN SOURCE_DB.ACCOUNT A 
        ON tal.account = A.id
    LEFT JOIN SOURCE_DB.TRANSACTIONLINE TL
        ON TL.transaction = tal.transaction
    FULL JOIN SOURCE_DB.ACCOUNTINGPERIOD AP
        ON T.postingperiod = AP.id
    LEFT JOIN SOURCE_DB.SUBSIDIARY S
        ON S.id = TL.subsidiary
    LEFT JOIN SOURCE_DB.CURRENCY C
        ON S.currency = C.id
    LEFT JOIN SOURCE_DB.ACCOUNT sal
        ON sal.id = A.parent
    LEFT JOIN SOURCE_DB.CONSOLIDATEDEXCHANGERATE cer 
        ON cer.fromcurrency = C.id 
           AND cer.postingperiod = AP.id 
           AND cer.fromsubsidiary = S.id 
           AND cer.tosubsidiary = 1 
           AND cer.accountingbook = 1
    WHERE tal.posting = 'T'
      AND A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS')
      AND TL.id = tal.transactionline
      AND A.acctnumber <> '<RETAINED_EARNINGS_ACCOUNT>'
    GROUP BY '<RETAINED_EARNINGS_ACCOUNT>',
             'Retained Earnings',
             TL.department,
             TL.class,
             TL.location,
             ap.startdate,
             tl.subsidiary,
             C.name,
             A.parent,
             A.accttype,
             sal.fullname,
             t.type,
             t.id,
             tal.accountingbook,
             a.displaynamewithhierarchy,
             s.name,
             cer.currentrate,
             YEAR(ap.startdate),
             MONTH(ap.startdate),
             GetFiscalYear(ap.startdate),
             t.tranid,
             tl.id,
             CONCAT(tl.subsidiary, CONCAT(t.postingperiod, C.name)),
             t.memo,
             tl.createdfrom,
             tl.memo,
             CASE 
                WHEN tl.memo = 'Rev Rec Source' OR tl.memo = 'Rev Rec Destination' 
                THEN 'Filter Out Journal Lines with Rev Rec Indicator' 
                ELSE 'Keep Journal Lines with Rev Rec Indicator'
             END
    HAVING SUM(tal.amount) <> 0
),
PeriodAccountsNetIncome AS (
    SELECT 
        '0' AS GLAmount,
        A.acctnumber AS AccountNumber,
        A.fullname AS AccountName,
        '0' AS Department,
        '0' AS Class,
        '0' AS Location,
        ap.startdate AS PostingPeriodStartDate,
        '0' AS Subsidiary,
        '0' AS Currency,
        '0' AS SubAccountOf,
        A.accttype AS AccountType,
        '0' AS SubAccountName,
        '0' AS TransactionType,
        '0' AS TransactionID,
        '1' AS AccountingBook,
        '0' AS AccountNameHierarchy,
        '0' AS GLAmountUSD,
        s.name AS SubsidiaryName,
        '0' AS ExchangeRate,
        YEAR(ap.startdate) AS USFiscalYear,
        MONTH(ap.startdate) AS TransactionMonth,
        GetFiscalYear(ap.startdate) AS FiscalYear,
        '0' AS DocumentNumber,
        '0' AS LineID,
        '0' AS SubPeriodCurrency,
        '0' AS Memo,
        '0' AS CreatedFrom,
        '0' AS TranLineMemo,
        '0' AS RevRecSource
    FROM SOURCE_DB.ACCOUNT A
    JOIN SOURCE_DB.ACCOUNTINGPERIOD AP ON 1=1
    JOIN SOURCE_DB.SUBSIDIARY S ON 1=1
    WHERE A.accttype IN ('COGS', 'Expense', 'OthExpense', 'Income', 'OthIncome')
      AND MONTH(ap.startdate) = 4
      AND YEAR(ap.startdate) >= 2023
      AND S.name = 'Generic Company'
),
PeriodAccountsRetainedEarnings AS (
    SELECT 
        '0' AS GLAmount,
        A.acctnumber AS AccountNumber,
        A.fullname AS AccountName,
        '0' AS Department,
        '0' AS Class,
        '0' AS Location,
        ap.startdate AS PostingPeriodStartDate,
        '0' AS Subsidiary,
        '0' AS Currency,
        '0' AS SubAccountOf,
        'RetainedEarnings' AS AccountType,
        '0' AS SubAccountName,
        '0' AS TransactionType,
        '0' AS TransactionID,
        '1' AS AccountingBook,
        '0' AS AccountNameHierarchy,
        '0' AS GLAmountUSD,
        s.name AS SubsidiaryName,
        '0' AS ExchangeRate,
        YEAR(ap.startdate) AS USFiscalYear,
        MONTH(ap.startdate) AS TransactionMonth,
        GetFiscalYear(ap.startdate) AS FiscalYear,
        '0' AS DocumentNumber,
        '0' AS LineID,
        '0' AS SubPeriodCurrency,
        '0' AS Memo,
        '0' AS CreatedFrom,
        '0' AS TranLineMemo,
        '0' AS RevRecSource
    FROM SOURCE_DB.ACCOUNT A 
    JOIN SOURCE_DB.ACCOUNTINGPERIOD AP ON 1=1
    JOIN SOURCE_DB.SUBSIDIARY S ON 1=1
    WHERE A.accttype IN ('COGS', 'Expense', 'OthExpense', 'Income', 'OthIncome')
      AND MONTH(ap.startdate) = 4
      AND YEAR(ap.startdate) >= 2023
      AND S.name = 'Generic Company'
)

SELECT * FROM AllAccounts
UNION ALL
SELECT * FROM RetainedEarnings
UNION ALL 
SELECT * FROM PeriodAccountsNetIncome
UNION ALL 
SELECT * FROM PeriodAccountsRetainedEarnings
;

RETURN 'Table PUBLIC.T_BALANCESHEET_PORTFOLIO created successfully';
END;
$$;

CREATE OR REPLACE FUNCTION GetFiscalYear(start_date DATE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    var date = new Date(start_date);
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    if (month > 3) {
        return (year + '-' + (year + 1).toString());
    } else {
        return ((year - 1) + '-' + year.toString());
    }
$$;
