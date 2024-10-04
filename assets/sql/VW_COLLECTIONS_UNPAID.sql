CREATE OR REPLACE table SB_ERPTEAM.PUBLIC.T_COLLECTIONS_UNPAID AS 

select

t.id as InvoiceID,
tl.id as TransationLineID,
ts.name as TransactionStatus,
concat(c.entityid, concat(' ', c.companyname)) as CustomerName,
s.name as Subsidiary,

t.trandate as TransDate, 
tl.closedate as ClosedDate,
tl.cleareddate as ClearedDate,
t.duedate as DueDate,

sum(COALESCE(foreignamountunpaid, 0) * cex.exchangerate) as ForeignAmountUnpaid,
sum(COALESCE(creditforeignamount, 0) * cex.exchangerate) as AmountUSDCred,
sum(COALESCE(debitforeignamount, 0) * cex.exchangerate) as AmountUSDDeb,
sum(COALESCE(debitforeignamount, 0) * cex.exchangerate) - sum(COALESCE(creditforeignamount, 0) * cex.exchangerate) as TotalInvoiceAmount,

case when sum(COALESCE(foreignamountunpaid, 0) * cex.exchangerate) <> 0 then sum(COALESCE(foreignamountunpaid, 0) * cex.exchangerate) else sum(COALESCE(debitforeignamount, 0) * cex.exchangerate) - sum(COALESCE(creditforeignamount, 0) * cex.exchangerate) end as AmountRemaining

from INBOUND_RAW.NETSUITE.TRANSACTION t
join INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl on tl.transaction = t.id
join INBOUND_RAW.NETSUITE.CUSTOMER c on c.id = t.entity
join INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD p on p.id = t.postingperiod
join SB_ERPTEAM.NS_TEST.INVTRANSTATUS ts on ts.id = t.status
join INBOUND_RAW.NETSUITE.SUBSIDIARY s on s.id = tl.subsidiary
//join INBOUND_RAW.NETSUITE.transactionaccountingline tal on tal.transactionline = tl.id
left join INBOUND_RAW.NETSUITE.ITEM i on i.id = tl.item
//left join INBOUND_RAW.SALESFORCE.PRODUCT_2 p2 on p2.id = i.externalid
left join INBOUND_RAW.NETSUITE.REVENUERECOGNITIONRULE rrr on rrr.id = i.revenuerecognitionrule
//left join INBOUND_RAW.NETSUITE.CUSTOMER c on c.id = t.entity
left join INBOUND_RAW.NETSUITE.CURRENCY cur on cur.id = t.currency
left join INBOUND_RAW.NETSUITE.EMPLOYEE emp on emp.id = t.custbody_lastmodifiedby
//left join SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD cex on cex.periodcurrency = concat(p.id,cur.name)
left join INBOUND_RAW.SALESFORCE.ACCOUNT a on a.id = c.externalid
left join SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY cex on cex.daycurrency = concat(t.trandate,t.currency)

where tl.id = 0 

group by 
t.id,
tl.id,
ts.name,
s.name,
concat(c.entityid, concat(' ', c.companyname)),

t.trandate, 
tl.closedate,
tl.cleareddate,
t.duedate

;
select * from SB_ERPTEAM.PUBLIC.T_COLLECTIONS_UNPAID where customername = '88811 NextGen'

;
CREATE OR REPLACE PROCEDURE USP_T_COLLECTIONS_UNPAID()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
 CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_COLLECTIONS_UNPAID AS

SELECT
    t.id AS InvoiceID,
    tl.id AS TransactionLineID,
    ts.name AS TransactionStatus,
    CONCAT(c.entityid, ' ', c.companyname) AS CustomerName,
    s.name AS Subsidiary,
    t.trandate AS TransDate,
    tl.closedate AS ClosedDate,
    tl.cleareddate AS ClearedDate,
    t.duedate AS DueDate,
    SUM(COALESCE(foreignamountunpaid, 0)) AS Foreign_Amount_Unpaid,
    CASE 
        WHEN SUM(COALESCE(foreignamountunpaid, 0) / cex.exchangerate) IS NULL 
        THEN SUM(COALESCE(foreignamountunpaid, 0)) 
        ELSE SUM(COALESCE(foreignamountunpaid, 0) / cex.exchangerate) 
    END AS ForeignAmountUnpaid,
    SUM(COALESCE(creditforeignamount, 0) * cex.exchangerate) AS AmountUSDCred,
    SUM(COALESCE(debitforeignamount, 0) * cex.exchangerate) AS AmountUSDDeb,
    SUM(COALESCE(debitforeignamount, 0) * cex.exchangerate) - SUM(COALESCE(creditforeignamount, 0) * cex.exchangerate) AS TotalInvoiceAmount,
    CASE 
        WHEN SUM(COALESCE(foreignamountunpaid, 0) * cex.exchangerate) IS NULL 
        THEN SUM(COALESCE(debitforeignamount, 0) * cex.exchangerate) - SUM(COALESCE(creditforeignamount, 0) * cex.exchangerate) 
        ELSE SUM(COALESCE(foreignamountunpaid, 0) * cex.exchangerate)
    END AS AmountRemaining,
    CONCAT(CAST(p.startdate AS DATE), cur.id) AS Ejfkend,
    cex.exchangerate AS ExchangeRate1,
    c.externalid as CustSFID
FROM 
    INBOUND_RAW.NETSUITE.TRANSACTION t
JOIN 
    INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON tl.transaction = t.id
JOIN 
    INBOUND_RAW.NETSUITE.CUSTOMER c ON c.id = t.entity
JOIN 
    INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD p ON p.id = t.postingperiod
JOIN 
    SB_ERPTEAM.NS_TEST.INVTRANSTATUS ts ON ts.id = t.status
JOIN 
    INBOUND_RAW.NETSUITE.SUBSIDIARY s ON s.id = tl.subsidiary
LEFT JOIN 
    INBOUND_RAW.NETSUITE.ITEM i ON i.id = tl.item
LEFT JOIN 
    INBOUND_RAW.NETSUITE.REVENUERECOGNITIONRULE rrr ON rrr.id = i.revenuerecognitionrule
LEFT JOIN 
    INBOUND_RAW.NETSUITE.CURRENCY cur ON cur.id = t.currency
LEFT JOIN 
    INBOUND_RAW.NETSUITE.EMPLOYEE emp ON emp.id = t.custbody_lastmodifiedby
LEFT JOIN 
    SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY cex ON cex.daycurrency = CONCAT(CAST(p.startdate AS DATE), cur.id) 
LEFT JOIN 
    INBOUND_RAW.SALESFORCE.ACCOUNT a ON a.id = c.externalid
WHERE 
    tl.id = 0 
GROUP BY 
    t.id,
    tl.id,
    ts.name,
    s.name,
    CONCAT(c.entityid, ' ', c.companyname),
    t.trandate, 
    tl.closedate,
    tl.cleareddate,
    t.duedate,
    CONCAT(CAST(p.startdate AS DATE), cur.id),
    cex.exchangerate,
    c.externalid;


    RETURN 'Table SB_ERPTEAM.PUBLIC.T_COLLECTIONS_UNPAID created successfully';
END;
$$;



;




select * from SB_ERPTEAM.PUBLIC.T_COLLECTIONS_UNPAID where customername = '10026 Triumph Composite Systems, Inc.';


-- drop task sb_erpteam.public.ERPTeam_Refresh;


-- DROP PROCEDURE IF EXISTS USP_T_COLLECTIONS_UNPAID();

