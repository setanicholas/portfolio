


--#region HAPPY - POST USD Conversion
/*
Fields to add
- document number
- memo
- posting period
- hyperlink
- customer
- subsidiary
- business unit

*/

// TESTY McTEST FACE
CREATE OR REPLACE PROCEDURE SB_ERPTEAM.PUBLIC.USP_BALANCESHEET()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN


create or replace table SB_ERPTEAM.PUBLIC.T_BALANCESHEET as 
WITH AllAccounts AS (
SELECT distinct 
SUM(tal.amount) AS GLAmount, 
A.acctnumber AS AccountNumber, 
A.fullname AS AccountName,
TL.department AS Department,
TL.class AS Class,
TL.location AS Location,
ap.startdate as PostingPeriodStartDate,
tl.subsidiary as Subsidiary,
c.name as Currency,
a.parent as SubAccountOf,
a.accttype as AccountType,
sal.fullname as SubAccountName,
t.type as TransactionType,
t.id as TransactionID,
tal.accountingbook as AccountingBook,
a.displaynamewithhierarchy as AccountNameHiearchy,
(CASE 
    WHEN SUM(tal.amount * cer.currentrate) IS NULL OR SUM(cer.currentrate) = 0 THEN SUM(tal.amount)
    ELSE SUM(tal.amount * cer.currentrate)
END) AS GLAmountUSD,
s.name as SubsidiaryName,
cer.currentrate as ExchangeRate,
--usd.averagerate as ExchangeRate,
YEAR(ap.startdate) as USFiscalYear,
MONTH(ap.startdate) as TransactionMonth,
GetFiscalYear(ap.startdate) as IndiaFiscalYear,
t.tranid as DocumentNumber,
tl.id as LineID,
CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)) as SubPeriodCurrency,
t.memo as Memo,
tl.createdfrom as CreatedFrom,
tl.memo as TranLineMemo


--,
-- cust.companyname as BillingCustomerName,
-- cust.id as BillingCustomerID,
-- cust.entityid as BillingCustomerEntityID





FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tal 
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T
ON T.id = tal.transaction
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A 
ON tal.account = A.id
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL
ON concat(TL.transaction,tl.id) = concat(tal.transaction,tal.transactionline)
FULL JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
ON T.postingperiod = AP.id
LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
ON S.id = TL.subsidiary
LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C
ON s.currency = c.id
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal
ON a.parent = sal.id
-- LEFT JOIN SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY usd 
-- ON usd.daycurrency = concat(cast(ap.startdate as DATE),s.currency)
left join INBOUND_RAW.NETSUITE.CONSOLIDATEDEXCHANGERATE cer 
ON cer.fromcurrency = c.id AND cer.postingperiod = ap.id AND cer.fromsubsidiary = s.id AND cer.tosubsidiary = 1 AND cer.accountingbook = 1

--   ON cust.id = t.entity

WHERE //TL.subsidiary = '10' AND /*Internal ID of the subsidiary that the report should be generated for*/
tal.posting = 'T'
//(A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
//AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') AND /*20210901 for Aug 2021*/
//AP.startdate > TO_DATE('20230101', 'YYYYMMDD') /*20210331 for April-March Fiscal Calendar 2021*/)
//OR
//(A.accttype NOT IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
//AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') /*20210901 for Aug 2021*/)
//)) 

AND TL.id = tal.transactionline
AND A.acctnumber <> '30020' 

//AND
//A.acctnumber <> '<RetainedEarningsAccountNumber>' /*Account Number of the Retained Earnings Account which is calculated separately.*/
GROUP BY A.acctnumber,
A.fullname,
TL.department,
TL.class,
TL.location,
ap.startdate,
tl.subsidiary,
c.name,
a.parent,
a.accttype,
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
CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)),
t.memo,
tl.createdfrom,
tl.memo 

--,
-- cust.companyname,
-- cust.id,
-- cust.entityid



HAVING SUM(tal.amount) <> 0

),
RetainedEarnings as (
SELECT distinct
SUM(-tal.amount) AS GLAmount,
'30020' AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
'Retained Earnings' AS AccountName,
TL.department AS Department,
TL.class AS Class,
TL.location AS Location,
ap.startdate as PostingPeriodStartDate,
tl.subsidiary as Subsidiary,
c.name as Currency,
a.parent as SubAccountOf,
'RetainedEarnings' as AccountType,
sal.fullname as SubAccountName,
t.type as TransactionType,
t.id as TransactionID,
tal.accountingbook as AccountingBook,
a.displaynamewithhierarchy as AccountNameHiearchy,
(CASE 
    WHEN SUM(-tal.amount * cer.currentrate) IS NULL OR SUM(cer.currentrate) = 0 THEN SUM(tal.amount)
    ELSE SUM(-tal.amount * cer.currentrate)
END)  AS GLAmountUSD,
s.name as SubsidiaryName,
cer.currentrate as ExchangeRate,
--usd.averagerate as ExchangeRate,
YEAR(ap.startdate) as USFiscalYear,
MONTH(ap.startdate) as TransactionMonth,
GetFiscalYear(ap.startdate) as IndiaFiscalYear,
t.tranid as DocumentNumber,
tl.id as LineID,
CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)) as SubPeriodCurrency,
t.memo as Memo,
tl.createdfrom as CreatedFrom,
tl.memo as TranLineMemo

--,
-- cust.companyname as BillingCustomerName,
-- cust.id as BillingCustomerID,
-- cust.entityid as BillingCustomerEntityID



FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tal 
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T
ON T.id = tal.transaction
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A 
ON tal.account = A.id
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL
ON TL.transaction = tal.transaction
FULL JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
ON T.postingperiod = AP.id
LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
ON S.id = TL.subsidiary
LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C
ON s.currency = c.id
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal
ON sal.id = a.parent
-- LEFT JOIN SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY usd 
-- ON usd.daycurrency = concat(cast(ap.startdate as DATE),s.currency)
left join INBOUND_RAW.NETSUITE.CONSOLIDATEDEXCHANGERATE cer 
ON cer.fromcurrency = c.id AND cer.postingperiod = ap.id AND cer.fromsubsidiary = s.id AND cer.tosubsidiary = 1 AND cer.accountingbook = 1
-- LEFT JOIN INBOUND_RAW.NETSUITE.CUSTOMER cust
--   ON cust.id = t.entity

WHERE //TL.subsidiary = '10' AND /*Internal ID of the subsidiary that the report should be generated for*/
tal.posting = 'T'
and (A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') )
--   //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') AND /*20210901 for Aug 2021*/
--   //AP.startdate > TO_DATE('20230101', 'YYYYMMDD') /*20210331 for April-March Fiscal Calendar 2021*/)
--    OR
-- (A.accttype NOT IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
--   //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') /*20210901 for Aug 2021*/
-- )) 
AND TL.id = tal.transactionline
AND A.acctnumber <> '30020' 

//AND
//A.acctnumber <> '<RetainedEarningsAccountNumber>' /*Account Number of the Retained Earnings Account which is calculated separately.*/
GROUP BY '30020', /*Account Number of the Retained Earnings Account which is calculated separately.*/
'Retained Earnings',
TL.department,
TL.class,
TL.location,
ap.startdate,
tl.subsidiary,
c.name,
a.parent,
a.accttype,
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
CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)),
t.memo,
tl.createdfrom,
tl.memo 

--,
-- cust.companyname,
-- cust.id,
-- cust.entityid



HAVING SUM(tal.amount) <> 0
),

PeriodAccountsNetIncome as (


SELECT 
'0' AS GLAmount,
a.acctnumber AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
a.fullname AS AccountName,
'0' AS Department,
'0' AS Class,
'0' AS Location,
ap.startdate AS PostingPeriodStartDate,
'0' AS Subsidiary,
'0' AS Currency,
'0' AS SubAccountOf,
a.accttype AS AccountType,
'0' AS SubAccountName,
'0' AS TransactionType,
'0' AS TransactionID,
'1' AS AccountingBook,
'0' AS AccountNameHierarchy,
'0' AS GLAmountUSD,
s.name AS SubsidiaryName,
'0' AS ExchangeRate,
YEAR(ap.startdate) as USFiscalYear,
MONTH(ap.startdate) as TransactionMonth,
GetFiscalYear(ap.startdate) AS IndiaFiscalYear,
'0' as DocumentNumber,
'0' as LineID,
'0' as SubPeriodCurrency,
'0' as Memo,
'0' as CreatedFrom,
'0' as TranLineMemo

--,
-- '0' as BillingCustomerName,
-- '0' as BillingCustomerID,
-- '0' as BillingCustomerEntityID


FROM  INBOUND_RAW.NETSUITE.ACCOUNT A
JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
where 
((a.accttype = 'COGS'
OR
a.accttype = 'Expense'
OR
a.accttype = 'OthExpense'
OR
a.accttype = 'Income'
OR
a.accttype = 'OthIncome'

)
and MONTH(ap.startdate) = 4
and YEAR(ap.startdate) >= 2023
and s.name = 'Clausion India Private Limited'
)

),


PeriodAccountsRetainedEarnings as (


SELECT 
'0' AS GLAmount,
a.acctnumber AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
a.fullname AS AccountName,
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
YEAR(ap.startdate) as USFiscalYear,
MONTH(ap.startdate) as TransactionMonth,
GetFiscalYear(ap.startdate) AS IndiaFiscalYear,
'0' as DocumentNumber,
'0' as LineID,
'0' as SubPeriodCurrency,
'0' as Memo,
'0' as CreatedFrom,
'0' as TranLineMemo

--,
-- '0' as BillingCustomerName,
-- '0' as BillingCustomerID,
-- '0' as BillingCustomerEntityID

FROM  INBOUND_RAW.NETSUITE.ACCOUNT A 
JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
where 
((a.accttype = 'COGS'
OR
a.accttype = 'Expense'
OR
a.accttype = 'OthExpense'
OR
a.accttype = 'Income'
OR
a.accttype = 'OthIncome'

)
and MONTH(ap.startdate) = 4
and YEAR(ap.startdate) >= 2023
and s.name = 'Clausion India Private Limited'
)

)


SELECT * FROM AllAccounts
UNION ALL
SELECT * FROM RetainedEarnings
UNION ALL 
SELECT * FROM PeriodAccountsNetIncome
UNION ALL 
SELECT * FROM PeriodAccountsRetainedEarnings
;

RETURN 'Table SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY created successfully';
END;
$$;

select 
*
from SB_ERPTEAM.PUBLIC.T_BALANCESHEET b
where b.TransactionID = '9364718'
//where b.currency = 'ZAR'
;

select * from INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tl where tl.transaction = '18561990'

;

select *  from INBOUND_RAW.NETSUITE.REVENUEPLAN where id = '5872617'

;

select *  from INBOUND_RAW.NETSUITE.REVENUEPLANPLANNEDREVENUE where revenueplan = '5872617'

;

/* 
sum of income and expense from start of year through selected end date
*/ 
--#endregion








--#region HAPPY - PRE USD Conversion
/*
Fields to add
- document number
- memo
- posting period
- hyperlink
- customer
- subsidiary
- business unit

 */


CREATE OR REPLACE PROCEDURE USP_BALANCESHEET()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN


create or replace table SB_ERPTEAM.PUBLIC.T_BALANCESHEET as 
WITH AllAccounts AS (
SELECT distinct 
  SUM(tal.amount) AS GLAmount, 
  A.acctnumber AS AccountNumber, 
  A.fullname AS AccountName,
  TL.department AS Department,
  TL.class AS Class,
  TL.location AS Location,
  ap.startdate as PostingPeriodStartDate,
  tl.subsidiary as Subsidiary,
  c.name as Currency,
  a.parent as SubAccountOf,
  a.accttype as AccountType,
  sal.fullname as SubAccountName,
  t.type as TransactionType,
  t.id as TransactionID,
  tal.accountingbook as AccountingBook,
  a.displaynamewithhierarchy as AccountNameHiearchy,
  ifnull(SUM(tal.amount * usd.exchangerate), SUM(tal.amount)) AS GLAmountUSD,
  s.name as SubsidiaryName,
  usd.exchangerate as ExchangeRate,
  --usd.averagerate as ExchangeRate,
  YEAR(ap.startdate) as USFiscalYear,
  MONTH(ap.startdate) as TransactionMonth,
  GetFiscalYear(ap.startdate) as IndiaFiscalYear,
  t.tranid as DocumentNumber,
  tl.id as LineID,
  CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)) as SubPeriodCurrency,
  t.memo as Memo,
  tl.createdfrom as CreatedFrom
  
  
  --,
  -- cust.companyname as BillingCustomerName,
  -- cust.id as BillingCustomerID,
  -- cust.entityid as BillingCustomerEntityID





FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tal 
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T
  ON T.id = tal.transaction
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A 
  ON tal.account = A.id
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL
  ON concat(TL.transaction,tl.id) = concat(tal.transaction,tal.transactionline)
FULL JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
  ON T.postingperiod = AP.id
LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
  ON S.id = TL.subsidiary
LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C
  ON s.currency = c.id
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal
  ON a.parent = sal.id
LEFT JOIN SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY usd 
  ON usd.daycurrency = concat(cast(ap.startdate as DATE),s.currency)
--   ON cust.id = t.entity

WHERE //TL.subsidiary = '10' AND /*Internal ID of the subsidiary that the report should be generated for*/
  tal.posting = 'T'
  //(A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
    //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') AND /*20210901 for Aug 2021*/
    //AP.startdate > TO_DATE('20230101', 'YYYYMMDD') /*20210331 for April-March Fiscal Calendar 2021*/)
   //OR
  //(A.accttype NOT IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
    //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') /*20210901 for Aug 2021*/)
  //)) 
  
  AND TL.id = tal.transactionline
  AND A.acctnumber <> '30020' 

   //AND
  //A.acctnumber <> '<RetainedEarningsAccountNumber>' /*Account Number of the Retained Earnings Account which is calculated separately.*/
GROUP BY A.acctnumber,
  A.fullname,
  TL.department,
  TL.class,
  TL.location,
  ap.startdate,
  tl.subsidiary,
  c.name,
  a.parent,
  a.accttype,
  sal.fullname,
  t.type,
  t.id,
  tal.accountingbook,
  a.displaynamewithhierarchy,
  s.name,
  usd.exchangerate,
  YEAR(ap.startdate),
  MONTH(ap.startdate),
  GetFiscalYear(ap.startdate),
  t.tranid,
  tl.id,
  CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)),
  t.memo,
  tl.createdfrom
--,
  -- cust.companyname,
  -- cust.id,
  -- cust.entityid



HAVING SUM(tal.amount) <> 0

),
 RetainedEarnings as (
 SELECT distinct
   SUM(-tal.amount) AS GLAmount,
  '30020' AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
  'Retained Earnings' AS AccountName,
  TL.department AS Department,
  TL.class AS Class,
  TL.location AS Location,
  ap.startdate as PostingPeriodStartDate,
  tl.subsidiary as Subsidiary,
  c.name as Currency,
  a.parent as SubAccountOf,
  'RetainedEarnings' as AccountType,
  sal.fullname as SubAccountName,
  t.type as TransactionType,
  t.id as TransactionID,
  tal.accountingbook as AccountingBook,
  a.displaynamewithhierarchy as AccountNameHiearchy,
  ifnull(SUM(tal.amount * usd.exchangerate), SUM(tal.amount)) AS GLAmountUSD,
  s.name as SubsidiaryName,
  usd.exchangerate as ExchangeRate,
  --usd.averagerate as ExchangeRate,
  YEAR(ap.startdate) as USFiscalYear,
  MONTH(ap.startdate) as TransactionMonth,
  GetFiscalYear(ap.startdate) as IndiaFiscalYear,
  t.tranid as DocumentNumber,
  tl.id as LineID,
  CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)) as SubPeriodCurrency,
  t.memo as Memo,
  tl.createdfrom as CreatedFrom
--,
  -- cust.companyname as BillingCustomerName,
  -- cust.id as BillingCustomerID,
  -- cust.entityid as BillingCustomerEntityID



FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tal 
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T
  ON T.id = tal.transaction
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A 
  ON tal.account = A.id
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL
  ON TL.transaction = tal.transaction
FULL JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
  ON T.postingperiod = AP.id
LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
  ON S.id = TL.subsidiary
LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C
  ON s.currency = c.id
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal
  ON sal.id = a.parent
LEFT JOIN SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY usd 
  ON usd.daycurrency = concat(cast(ap.startdate as DATE),s.currency)
  -- LEFT JOIN INBOUND_RAW.NETSUITE.CUSTOMER cust
--   ON cust.id = t.entity

WHERE //TL.subsidiary = '10' AND /*Internal ID of the subsidiary that the report should be generated for*/
  tal.posting = 'T'
  and (A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') )
  --   //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') AND /*20210901 for Aug 2021*/
  --   //AP.startdate > TO_DATE('20230101', 'YYYYMMDD') /*20210331 for April-March Fiscal Calendar 2021*/)
  --    OR
  -- (A.accttype NOT IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
  --   //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') /*20210901 for Aug 2021*/
  -- )) 
  AND TL.id = tal.transactionline
  AND A.acctnumber <> '30020' 
  
  //AND
  //A.acctnumber <> '<RetainedEarningsAccountNumber>' /*Account Number of the Retained Earnings Account which is calculated separately.*/
GROUP BY '30020', /*Account Number of the Retained Earnings Account which is calculated separately.*/
  'Retained Earnings',
  TL.department,
  TL.class,
  TL.location,
  ap.startdate,
  tl.subsidiary,
  c.name,
  a.parent,
  a.accttype,
  sal.fullname,
  t.type,
  t.id,
  tal.accountingbook,
  a.displaynamewithhierarchy,
  s.name,
  usd.exchangerate,
  YEAR(ap.startdate),
  MONTH(ap.startdate),
  GetFiscalYear(ap.startdate),
  t.tranid,
  tl.id,
  CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)),
  t.memo,
  tl.createdfrom--,
  -- cust.companyname,
  -- cust.id,
  -- cust.entityid



HAVING SUM(tal.amount) <> 0
),

PeriodAccountsNetIncome as (


SELECT 
  '0' AS GLAmount,
  a.acctnumber AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
  a.fullname AS AccountName,
  '0' AS Department,
  '0' AS Class,
  '0' AS Location,
  ap.startdate AS PostingPeriodStartDate,
  '0' AS Subsidiary,
  '0' AS Currency,
  '0' AS SubAccountOf,
  a.accttype AS AccountType,
  '0' AS SubAccountName,
  '0' AS TransactionType,
  '0' AS TransactionID,
  '1' AS AccountingBook,
  '0' AS AccountNameHierarchy,
  '0' AS GLAmountUSD,
  s.name AS SubsidiaryName,
  '0' AS ExchangeRate,
  YEAR(ap.startdate) as USFiscalYear,
  MONTH(ap.startdate) as TransactionMonth,
  GetFiscalYear(ap.startdate) AS IndiaFiscalYear,
  '0' as DocumentNumber,
  '0' as LineID,
  '0' as SubPeriodCurrency,
  '0' as Memo,
  '0' as CreatedFrom
--,
  -- '0' as BillingCustomerName,
  -- '0' as BillingCustomerID,
  -- '0' as BillingCustomerEntityID


FROM  INBOUND_RAW.NETSUITE.ACCOUNT A
JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
where 
((a.accttype = 'COGS'
OR
a.accttype = 'Expense'
OR
a.accttype = 'OthExpense'
OR
a.accttype = 'Income'
OR
a.accttype = 'OthIncome'

)
and MONTH(ap.startdate) = 4
and YEAR(ap.startdate) >= 2023
and s.name = 'Clausion India Private Limited'
)

),


PeriodAccountsRetainedEarnings as (


SELECT 
  '0' AS GLAmount,
  a.acctnumber AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
  a.fullname AS AccountName,
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
  YEAR(ap.startdate) as USFiscalYear,
  MONTH(ap.startdate) as TransactionMonth,
  GetFiscalYear(ap.startdate) AS IndiaFiscalYear,
  '0' as DocumentNumber,
  '0' as LineID,
  '0' as SubPeriodCurrency,
  '0' as Memo,
  '0' as CreatedFrom
--,
  -- '0' as BillingCustomerName,
  -- '0' as BillingCustomerID,
  -- '0' as BillingCustomerEntityID

FROM  INBOUND_RAW.NETSUITE.ACCOUNT A 
JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
where 
((a.accttype = 'COGS'
OR
a.accttype = 'Expense'
OR
a.accttype = 'OthExpense'
OR
a.accttype = 'Income'
OR
a.accttype = 'OthIncome'

)
and MONTH(ap.startdate) = 4
and YEAR(ap.startdate) >= 2023
and s.name = 'Clausion India Private Limited'
)

)


SELECT * FROM AllAccounts
UNION ALL
SELECT * FROM RetainedEarnings
UNION ALL 
SELECT * FROM PeriodAccountsNetIncome
UNION ALL 
SELECT * FROM PeriodAccountsRetainedEarnings
;

    RETURN 'Table SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY created successfully';
END;
$$;

select 
*
from SB_ERPTEAM.PUBLIC.VW_BALANCESHEET b
where b.TransactionID = '18478561'
;

select * from INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tl where tl.transaction = '18561990'

;

select *  from INBOUND_RAW.NETSUITE.REVENUEPLAN where id = '5872617'

;

select *  from INBOUND_RAW.NETSUITE.REVENUEPLANPLANNEDREVENUE where revenueplan = '5872617'

;

/* 
sum of income and expense from start of year through selected end date
*/ 
--#endregion








































--#region Fucked Up Balance Sheet ARCHIVE
/*
Fields to add
- document number
- memo
- posting period
- hyperlink
- customer
- subsidiary
- business unit

 */


create or replace view SB_ERPTEAM.PUBLIC.VW_BALANCESHEET as 
WITH AllAccounts AS (
SELECT distinct 
  SUM(tal.amount) AS GLAmount, 
  A.acctnumber AS AccountNumber, 
  A.fullname AS AccountName,
  TL.department AS Department,
  TL.class AS Class,
  TL.location AS Location,
  ap.startdate as PostingPeriodStartDate,
  tl.subsidiary as Subsidiary,
  c.name as Currency,
  a.parent as SubAccountOf,
  a.accttype as AccountType,
  sal.fullname as SubAccountName,
  t.type as TransactionType,
  t.id as TransactionID,
  tal.accountingbook as AccountingBook,
  a.displaynamewithhierarchy as AccountNameHiearchy,
  ifnull(SUM(tal.amount * usd.exchangerate), SUM(tal.amount)) AS GLAmountUSD,
  s.name as SubsidiaryName,
  usd.exchangerate as ExchangeRate,
  --usd.averagerate as ExchangeRate,
  YEAR(ap.startdate) as USFiscalYear,
  MONTH(ap.startdate) as TransactionMonth,
  GetFiscalYear(ap.startdate) as IndiaFiscalYear,
  t.tranid as DocumentNumber,
  tl.id as LineID,
  CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)) as SubPeriodCurrency,
  t.memo as Memo,
  tl.createdfrom as CreatedFrom
  
  
  --,
  -- cust.companyname as BillingCustomerName,
  -- cust.id as BillingCustomerID,
  -- cust.entityid as BillingCustomerEntityID





FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tal 
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T
  ON T.id = tal.transaction
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A 
  ON tal.account = A.id
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL
  ON concat(TL.transaction,tl.id) = concat(tal.transaction,tal.transactionline)
FULL JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
  ON T.postingperiod = AP.id
LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
  ON S.id = TL.subsidiary
LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C
  ON s.currency = c.id
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal
  ON a.parent = sal.id
LEFT JOIN SB_ERPTEAM.PUBLIC.NS_USD usd 
  ON usd.currencydate = concat(s.currency,cast(t.trandate as DATE))
-- LEFT JOIN INBOUND_RAW.NETSUITE.CUSTOMER cust
--   ON cust.id = t.entity

WHERE //TL.subsidiary = '10' AND /*Internal ID of the subsidiary that the report should be generated for*/
  tal.posting = 'T'
  //(A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
    //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') AND /*20210901 for Aug 2021*/
    //AP.startdate > TO_DATE('20230101', 'YYYYMMDD') /*20210331 for April-March Fiscal Calendar 2021*/)
   //OR
  //(A.accttype NOT IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
    //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') /*20210901 for Aug 2021*/)
  //)) 
  
  AND TL.id = tal.transactionline
  AND A.acctnumber <> '30020' 

   //AND
  //A.acctnumber <> '<RetainedEarningsAccountNumber>' /*Account Number of the Retained Earnings Account which is calculated separately.*/
GROUP BY A.acctnumber,
  A.fullname,
  TL.department,
  TL.class,
  TL.location,
  ap.startdate,
  tl.subsidiary,
  c.name,
  a.parent,
  a.accttype,
  sal.fullname,
  t.type,
  t.id,
  tal.accountingbook,
  a.displaynamewithhierarchy,
  s.name,
  usd.exchangerate,
  YEAR(ap.startdate),
  MONTH(ap.startdate),
  GetFiscalYear(ap.startdate),
  t.tranid,
  tl.id,
  CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)),
  t.memo,
  tl.createdfrom
--,
  -- cust.companyname,
  -- cust.id,
  -- cust.entityid



HAVING SUM(tal.amount) <> 0

),
 RetainedEarnings as (
 SELECT distinct
   SUM(-tal.amount) AS GLAmount,
  '30020' AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
  'Retained Earnings' AS AccountName,
  TL.department AS Department,
  TL.class AS Class,
  TL.location AS Location,
  ap.startdate as PostingPeriodStartDate,
  tl.subsidiary as Subsidiary,
  c.name as Currency,
  a.parent as SubAccountOf,
  'RetainedEarnings' as AccountType,
  sal.fullname as SubAccountName,
  t.type as TransactionType,
  t.id as TransactionID,
  tal.accountingbook as AccountingBook,
  a.displaynamewithhierarchy as AccountNameHiearchy,
  ifnull(SUM(tal.amount * usd.exchangerate), SUM(tal.amount)) AS GLAmountUSD,
  s.name as SubsidiaryName,
  usd.exchangerate as ExchangeRate,
  --usd.averagerate as ExchangeRate,
  YEAR(ap.startdate) as USFiscalYear,
  MONTH(ap.startdate) as TransactionMonth,
  GetFiscalYear(ap.startdate) as IndiaFiscalYear,
  t.tranid as DocumentNumber,
  tl.id as LineID,
  CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)) as SubPeriodCurrency,
  t.memo as Memo,
  tl.createdfrom as CreatedFrom
--,
  -- cust.companyname as BillingCustomerName,
  -- cust.id as BillingCustomerID,
  -- cust.entityid as BillingCustomerEntityID



FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tal 
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T
  ON T.id = tal.transaction
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A 
  ON tal.account = A.id
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL
  ON TL.transaction = tal.transaction
FULL JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
  ON T.postingperiod = AP.id
LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
  ON S.id = TL.subsidiary
LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C
  ON s.currency = c.id
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal
  ON sal.id = a.parent
LEFT JOIN SB_ERPTEAM.PUBLIC.NS_USD usd 
  ON usd.currencydate = concat(s.currency,cast(t.trandate as DATE))
  -- LEFT JOIN INBOUND_RAW.NETSUITE.CUSTOMER cust
--   ON cust.id = t.entity

WHERE //TL.subsidiary = '10' AND /*Internal ID of the subsidiary that the report should be generated for*/
  tal.posting = 'T'
  and (A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') )
  --   //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') AND /*20210901 for Aug 2021*/
  --   //AP.startdate > TO_DATE('20230101', 'YYYYMMDD') /*20210331 for April-March Fiscal Calendar 2021*/)
  --    OR
  -- (A.accttype NOT IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
  --   //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') /*20210901 for Aug 2021*/
  -- )) 
  AND TL.id = tal.transactionline
  AND A.acctnumber <> '30020' 
  
  //AND
  //A.acctnumber <> '<RetainedEarningsAccountNumber>' /*Account Number of the Retained Earnings Account which is calculated separately.*/
GROUP BY '30020', /*Account Number of the Retained Earnings Account which is calculated separately.*/
  'Retained Earnings',
  TL.department,
  TL.class,
  TL.location,
  ap.startdate,
  tl.subsidiary,
  c.name,
  a.parent,
  a.accttype,
  sal.fullname,
  t.type,
  t.id,
  tal.accountingbook,
  a.displaynamewithhierarchy,
  s.name,
  usd.exchangerate,
  YEAR(ap.startdate),
  MONTH(ap.startdate),
  GetFiscalYear(ap.startdate),
  t.tranid,
  tl.id,
  CONCAT(tl.subsidiary,CONCAT(t.postingperiod,c.name)),
  t.memo,
  tl.createdfrom--,
  -- cust.companyname,
  -- cust.id,
  -- cust.entityid



HAVING SUM(tal.amount) <> 0
),

PeriodAccountsNetIncome as (


SELECT 
  '0' AS GLAmount,
  a.acctnumber AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
  a.fullname AS AccountName,
  '0' AS Department,
  '0' AS Class,
  '0' AS Location,
  ap.startdate AS PostingPeriodStartDate,
  '0' AS Subsidiary,
  '0' AS Currency,
  '0' AS SubAccountOf,
  a.accttype AS AccountType,
  '0' AS SubAccountName,
  '0' AS TransactionType,
  '0' AS TransactionID,
  '1' AS AccountingBook,
  '0' AS AccountNameHierarchy,
  '0' AS GLAmountUSD,
  s.name AS SubsidiaryName,
  '0' AS ExchangeRate,
  YEAR(ap.startdate) as USFiscalYear,
  MONTH(ap.startdate) as TransactionMonth,
  GetFiscalYear(ap.startdate) AS IndiaFiscalYear,
  '0' as DocumentNumber,
  '0' as LineID,
  '0' as SubPeriodCurrency,
  '0' as Memo,
  '0' as CreatedFrom
--,
  -- '0' as BillingCustomerName,
  -- '0' as BillingCustomerID,
  -- '0' as BillingCustomerEntityID


FROM  INBOUND_RAW.NETSUITE.ACCOUNT A
JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
where 
((a.accttype = 'COGS'
OR
a.accttype = 'Expense'
OR
a.accttype = 'OthExpense'
OR
a.accttype = 'Income'
OR
a.accttype = 'OthIncome'

)
and MONTH(ap.startdate) = 4
and YEAR(ap.startdate) >= 2023
and s.name = 'Clausion India Private Limited'
)

),


PeriodAccountsRetainedEarnings as (


SELECT 
  '0' AS GLAmount,
  a.acctnumber AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
  a.fullname AS AccountName,
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
  YEAR(ap.startdate) as USFiscalYear,
  MONTH(ap.startdate) as TransactionMonth,
  GetFiscalYear(ap.startdate) AS IndiaFiscalYear,
  '0' as DocumentNumber,
  '0' as LineID,
  '0' as SubPeriodCurrency,
  '0' as Memo,
  '0' as CreatedFrom
--,
  -- '0' as BillingCustomerName,
  -- '0' as BillingCustomerID,
  -- '0' as BillingCustomerEntityID

FROM  INBOUND_RAW.NETSUITE.ACCOUNT A 
JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
where 
((a.accttype = 'COGS'
OR
a.accttype = 'Expense'
OR
a.accttype = 'OthExpense'
OR
a.accttype = 'Income'
OR
a.accttype = 'OthIncome'

)
and MONTH(ap.startdate) = 4
and YEAR(ap.startdate) >= 2023
and s.name = 'Clausion India Private Limited'
)

)


SELECT * FROM AllAccounts
UNION ALL
SELECT * FROM RetainedEarnings
UNION ALL 
SELECT * FROM PeriodAccountsNetIncome
UNION ALL 
SELECT * FROM PeriodAccountsRetainedEarnings
;

select 
*
from SB_ERPTEAM.PUBLIC.VW_BALANCESHEET b
where b.TransactionID = '18478561'
;

select * from INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tl where tl.transaction = '18561990'

;

select *  from INBOUND_RAW.NETSUITE.REVENUEPLAN where id = '5872617'

;

select *  from INBOUND_RAW.NETSUITE.REVENUEPLANPLANNEDREVENUE where revenueplan = '5872617'

;

/* 
sum of income and expense from start of year through selected end date
*/ 
--#endregion

select  * from SB_ERPTEAM.PUBLIC.VW_BALANCESHEET where transactionid = '17799077' and subsidiary = '231'

;

select count(id) from SB_ERPTEAM.PUBLIC.VW_BALANCESHEET

;


describe table INBOUND_RAW.NETSUITE.ACCOUNT

;
CREATE OR REPLACE FUNCTION GetFiscalYear(start_date DATE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    var year = START_DATE.getFullYear();
    var month = START_DATE.getMonth() + 1; // JavaScript months are zero-indexed
    if (month > 3) {
        // Fiscal year starts in April and belongs to the current year
        return (year + '-' + (year + 1).toString());
    } else {
        // Before April, belongs to the previous fiscal year
        return ((year - 1) + '-' + year.toString());
    }
$$;


CREATE OR REPLACE FUNCTION GetFiscalYear(start_date DATE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    var date = new Date(START_DATE);  // Convert START_DATE to a JavaScript Date object
    var year = date.getFullYear();
    var month = date.getMonth() + 1; // JavaScript months are zero-indexed
    if (month > 3) {
        // Fiscal year starts in April and belongs to the current year
        return (year + '-' + (year + 1).toString());
    } else {
        // Before April, belongs to the previous fiscal year
        return ((year - 1) + '-' + year.toString());
    }
$$;




--#region Original Balance Sheet

-- create or replace view SB_ERPTEAM.PUBLIC.VW_BALANCESHEET as 

-- SELECT SUM(TAL.amount) AS GLAmount, 
--   A.acctnumber AS AccountNumber, 
--   A.fullname AS AccountName,
--   TL.department AS Department,
--   TL.class AS Class,
--   TL.location AS Location,
--   ap.startdate as PostingPeriodStartDate,
--   tl.subsidiary as Subsidiary,
--   c.name as Currency,
--   a.parent as SubAccountOf,
--   a.accttype as AccountType,
--   sal.fullname as SubAccountName,
--   t.type as TransactionType,
--   t.id as TransactionID,
--   tal.accountingbook as AccountingBook,
--   a.displaynamewithhierarchy as AccountNameHiearchy

-- FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE TAL 
-- LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T
--   ON T.id = TAL.transaction
-- LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A 
--   ON TAL.account = A.id
-- LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL
--   ON TL.transaction = TAL.transaction
-- LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
--   ON T.postingperiod = AP.id
-- LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
--   ON S.id = TL.subsidiary
-- LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C
--   ON t.currency = c.id
-- LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal
--   ON a.parent = sal.id


-- WHERE //TL.subsidiary = '10' AND /*Internal ID of the subsidiary that the report should be generated for*/
--   TAL.posting = 'T' AND
--   (A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
--     //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') AND /*20210901 for Aug 2021*/
--     //AP.startdate > TO_DATE('20230101', 'YYYYMMDD') /*20210331 for April-March Fiscal Calendar 2021*/)
--    OR
--   (A.accttype NOT IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
--     //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') /*20210901 for Aug 2021*/)
--   )) AND
--   TL.id = TAL.transactionline //AND
--   //A.acctnumber <> '<RetainedEarningsAccountNumber>' /*Account Number of the Retained Earnings Account which is calculated separately.*/
-- GROUP BY A.acctnumber,
--   A.fullname,
--   TL.department,
--   TL.class,
--   TL.location,
--   ap.startdate,
--   tl.subsidiary,
--   c.name,
--   a.parent,
--   a.accttype,
--   sal.fullname,
--   t.type,
--   t.id,
--   tal.accountingbook,
--   a.displaynamewithhierarchy

-- HAVING SUM(TAL.amount) <> 0
-- UNION SELECT SUM(-TAL.amount) AS GLAmount,
--   '30020' AS AccountNumber, /*Account Number of the Retained Earnings Account which is calculated separately.*/
--   'Retained Earnings' AS AccountName,
--   TL.department AS Department,
--   TL.class AS Class,
--   TL.location AS Location,
--   ap.startdate as PostingPeriodStartDate,
--   tl.subsidiary as Subsidiary,
--   c.name as Currency,
--   a.parent as SubAccountOf,
--   a.accttype as AccountType,
--   sal.fullname as SubAccountName,
--   t.type as TransactionType,
--   t.id as TransactionID,
--   tal.accountingbook as AccountingBook,
--   a.displaynamewithhierarchy as AccountNameHiearchy


-- FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE TAL 
-- LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T
--   ON T.id = TAL.transaction
-- LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A 
--   ON TAL.account = A.id
-- LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL
--   ON TL.transaction = TAL.transaction
-- LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP
--   ON T.postingperiod = AP.id
-- LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S
--   ON S.id = TL.subsidiary
-- LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C
--   ON t.currency = c.id
-- LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal
--   ON sal.id = a.parent
-- WHERE //TL.subsidiary = '10' AND /*Internal ID of the subsidiary that the report should be generated for*/
--   TAL.posting = 'T' AND
--   (A.accttype IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
--     //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') AND /*20210901 for Aug 2021*/
--     //AP.startdate > TO_DATE('20230101', 'YYYYMMDD') /*20210331 for April-March Fiscal Calendar 2021*/)
--      OR
--   (A.accttype NOT IN ('Income', 'Expense', 'OthIncome', 'OthExpense', 'COGS') 
--     //AND AP.enddate < TO_DATE('20231231', 'YYYYMMDD') /*20210901 for Aug 2021*/
--   )) AND
--   TL.id = TAL.transactionline //AND
--   //A.acctnumber <> '<RetainedEarningsAccountNumber>' /*Account Number of the Retained Earnings Account which is calculated separately.*/
-- GROUP BY '30020', /*Account Number of the Retained Earnings Account which is calculated separately.*/
--   'Retained Earnings',
--   TL.department,
--   TL.class,
--   TL.location,
--   ap.startdate,
--   tl.subsidiary,
--   c.name,
--   a.parent,
--   a.accttype,
--   sal.fullname,
--   t.type,
--   t.id,
--   tal.accountingbook,
--   a.displaynamewithhierarchy


-- HAVING SUM(TAL.amount) <> 0

-- ;
--#endregion
;

select id from INBOUND_RAW.NETSUITE.ACCOUNT order by id

;

CREATE OR REPLACE VIEW SB_ERPTEAM.PUBLIC.VW_BALANCESHEET AS 

WITH BaseData AS (
    SELECT SUM(tal.amount) AS GLAmount, 
        A.acctnumber AS AccountNumber, 
        A.fullname AS AccountName,
        TL.department AS Department,
        TL.class AS Class,
        TL.location AS Location,
        ap.startdate as PostingPeriodStartDate,
        tl.subsidiary as Subsidiary,
        c.name as Currency,
        a.parent as SubAccountOf,
        a.accttype as AccountType,
        sal.fullname as SubAccountName,
        t.type as TransactionType,
        t.id as TransactionID,
        tal.accountingbook as AccountingBook,
        a.displaynamewithhierarchy as AccountNameHiearchy,
        IFNULL(SUM(tal.amount * usd.averagerate), SUM(tal.amount)) AS GLAmountUSD,
        s.name as SubsidiaryName,
        usd.averagerate as ExchangeRate,
        YEAR(ap.startdate) as USFiscalYear,
        MONTH(ap.startdate) as TransactionMonth,
        GetFiscalYear(ap.startdate) as IndiaFiscalYear
    FROM INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tal 
    LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION T ON T.id = tal.transaction
    LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT A ON tal.account = A.id
    LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE TL ON TL.transaction = tal.transaction
    FULL JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD AP ON T.postingperiod = AP.id
    LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY S ON S.id = TL.subsidiary
    LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY C ON s.currency = c.id
    LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT sal ON a.parent = sal.id
    LEFT JOIN SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD usd ON usd.subperiodcurrency = CONCAT(tl.subsidiary,CONCAT(t.postingperiod,s.currency))
    WHERE tal.posting = 'T'
    AND TL.id = tal.transactionline
    AND A.acctnumber <> '30020'
    GROUP BY A.acctnumber,
        A.fullname,
        TL.department,
        TL.class,
        TL.location,
        ap.startdate,
        tl.subsidiary,
        c.name,
        a.parent,
        a.accttype,
        sal.fullname,
        t.type,
        t.id,
        tal.accountingbook,
        a.displaynamewithhierarchy,
        s.name,
        usd.averagerate,
        YEAR(ap.startdate),
        MONTH(ap.startdate),
        GetFiscalYear(ap.startdate)
    HAVING SUM(tal.amount) <> 0
),
DummyRows AS (
    SELECT 
        0 AS GLAmount, 
        NULL AS AccountNumber, 
        AccountName AS AccountName,
        NULL AS Department,
        NULL AS Class,
        NULL AS Location,
        '4/1/2024' AS PostingPeriodStartDate, -- April 1st of the current year
        NULL AS Subsidiary,
        NULL AS Currency,
        NULL AS SubAccountOf,
        A.accttype AS AccountType,
        NULL AS SubAccountName,
        NULL AS TransactionType,
        NULL AS TransactionID,
        NULL AS AccountingBook,
        NULL AS AccountNameHiearchy,
        0 AS GLAmountUSD,
        NULL AS SubsidiaryName,
        NULL AS ExchangeRate,
        YEAR(DATE_FROM_PARTS(YEAR(GETDATE()), 4, 1)) AS USFiscalYear,
        MONTH(DATE_FROM_PARTS(YEAR(GETDATE()), 4, 1)) AS TransactionMonth,
        GetFiscalYear(DATE_FROM_PARTS(YEAR(GETDATE()), 4, 1)) AS IndiaFiscalYear
    FROM INBOUND_RAW.NETSUITE.ACCOUNT A
    GROUP BY A.accttype, YEAR(GETDATE())
)
SELECT * FROM BaseData
UNION ALL
SELECT * FROM DummyRows
;
//C weird C G


;
