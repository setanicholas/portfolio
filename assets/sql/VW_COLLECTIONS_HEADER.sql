CREATE OR REPLACE table SB_ERPTEAM.PUBLIC.T_COLLECTIONS_HEADER AS 

WITH LocationRank AS (
    SELECT
        t.id AS item_id,
        t.FirstLocation,
        t.id AS transaction_id,
        ROW_NUMBER() OVER(PARTITION BY t.id ORDER BY t.id ASC) AS rank
    FROM INBOUND_RAW.NETSUITE.TRANSACTION t
    INNER JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON tl.transaction = t.id
    LEFT JOIN INBOUND_RAW.NETSUITE.ITEM i ON t.id = tl.item
    WHERE t.type = 'CustInvc' -- Adjust this condition as necessary
)

SELECT 
    t.id as TranID, 
    t.trandate as TransDate, 
    t.type as TranType, 
    ts.name as TranStatus,
    SUM(tl.creditforeignamount) as ForeignAmount,
    s.name as Subsidiary,
    CONCAT(c.entityid, ' ', c.companyname) as CustomerName,
    c.custentity_credit_hold as CreditHold,
    cur.name as TranCurrency,
    emp.email as LastModifiedBy,
    SUM((tl.creditforeignamount * cex.averagerate)) as AmountUSDCred,
    SUM(tl.debitforeignamount * cex.averagerate) as AmountUSDDeb,
    tl.closedate as ClosedDate,
    tl.cleareddate as ClearedDate,
    t.duedate as DueDate,
    a.id as SFAccountID,
    a.type as SFAccountType,
    a.owner_name_c as SFAccountOwner,
    t.TRANID as DocumentNumber,
    t.postingperiod as PostingPeriod,
    lr.location as FirstLocation -- Ensuring 'lr' is correctly identified and 'location' is valid

FROM INBOUND_RAW.NETSUITE.TRANSACTION t
JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON tl.transaction = t.id
JOIN INBOUND_RAW.NETSUITE.CUSTOMER c ON c.id = t.entity
JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD p ON p.id = t.postingperiod
JOIN SB_ERPTEAM.NS_TEST.INVTRANSTATUS ts ON ts.id = t.status
JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY s ON s.id = tl.subsidiary
LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY cur ON cur.id = t.currency
LEFT JOIN INBOUND_RAW.NETSUITE.EMPLOYEE emp ON emp.id = t.custbody_lastmodifiedby
LEFT JOIN SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD cex ON cex.periodcurrency = CONCAT(p.id, cur.name)
LEFT JOIN INBOUND_RAW.SALESFORCE.ACCOUNT a ON a.id = c.externalid
LEFT JOIN LocationRank lr ON lr.transaction_id = t.id AND lr.rank = 1 -- Correct join condition

WHERE EXISTS (
    SELECT 1 
    FROM INBOUND_RAW.NETSUITE.TRANSACTIONSTATUS ts2 
    WHERE ts2.TRANTYPE = 'CustInvc'
) 
AND t.type = 'CustInvc' 
AND tl.mainline = 'F' 
AND (tl.creditforeignamount <> 0 OR tl.debitforeignamount <> 0)

GROUP BY
    t.id, 
    t.trandate, 
    t.type, 
    ts.name,
    s.name,
    CONCAT(c.entityid, ' ', c.companyname),
    c.custentity_credit_hold,
    cur.name,
    emp.email,
    tl.closedate,
    tl.cleareddate,
    t.duedate,
    a.id,
    a.type,
    a.owner_name_c,
    t.TRANID,
    t.postingperiod,
    lr.location


;

update SB_ERPTEAM.PUBLIC.T_COLLECTIONS_HEADER
set  AmountUSDDeb = case when AmountUSDDeb is null then 0 else AmountUSDDeb end
;
select * from SB_ERPTEAM.PUBLIC.T_COLLECTIONS_HEADER

;


CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM AS 

with cte as ( 
select 
    t.tranid as InvoiceInternalID,
    -- CAST(p.internal_id AS DECIMAL(10,2)) as PaymentInternalID,
    -- CAST(p.APPLIED_TO_INTERNAL_ID AS DECIMAL(10,2)) as PaymentAppliedToInternalID,
    CAST(sum(p.amountpaid) AS DECIMAL(10,2)) as PaymentAppliedAmount,
    CAST(sum(t.AmountUSDCred - t.AmountUSDDeb) AS DECIMAL(10,2)) as InvoiceAmount,
    CASE WHEN t.TranStatus = 'Open' THEN CAST((t.AmountUSDCred - t.AmountUSDDeb - p.amountpaid)AS DECIMAL(10,2)) ELSE 0 END as TotalAmountRemainingUSD,
    CAST(NULL AS DECIMAL(10,2)) as InvoiceAmountRemaining,
    t.CustomerName as CustomerName,
    t.Subsidiary as Subsidiary,
    t.TranStatus as InvoiceStatus,
    '' as ExchangeRate,
    t.postingperiod as PostingPeriod,
    t.TranCurrency as Currency,
    t.FirstLocation as Location,
--#region ProductLine > Business Unit
case    
when t.FirstLocation = '1' then 'FP&A'
when t.FirstLocation = '2' then 'FP&A'
when t.FirstLocation = '3' then 'FP&A'
when t.FirstLocation = '4' then 'FP&A'
when t.FirstLocation = '5' then 'FP&A'
when t.FirstLocation = '6' then 'Data & Analytics'
when t.FirstLocation = '8' then 'FP&A'
when t.FirstLocation = '9' then 'FP&A'
when t.FirstLocation = '10' then 'FP&A'
when t.FirstLocation = '12' then 'FP&A'
when t.FirstLocation = '13' then 'FP&A'
when t.FirstLocation = '14' then 'FP&A'
when t.FirstLocation = '15' then 'FP&A'
when t.FirstLocation = '16' then 'FP&A'
when t.FirstLocation = '17' then 'FP&A'
when t.FirstLocation = '18' then 'FP&A'
when t.FirstLocation = '19' then 'FP&A'
when t.FirstLocation = '20' then 'FP&A'
when t.FirstLocation = '22' then 'FP&A'
when t.FirstLocation = '23' then 'FP&A'
when t.FirstLocation = '24' then 'FP&A'
when t.FirstLocation = '101' then 'FP&A'
when t.FirstLocation = '102' then 'FP&A'
when t.FirstLocation = '104' then 'FP&A'
when t.FirstLocation = '105' then 'FP&A'
when t.FirstLocation = '106' then 'FP&A'
when t.FirstLocation = '107' then 'FP&A'
when t.FirstLocation = '108' then 'FP&A'
when t.FirstLocation = '109' then 'FP&A'
when t.FirstLocation = '110' then 'FP&A'
when t.FirstLocation = '111' then 'FP&A'
when t.FirstLocation = '112' then 'FP&A'
when t.FirstLocation = '113' then 'FP&A'
when t.FirstLocation = '114' then 'FP&A'
when t.FirstLocation = '115' then 'FP&A'
when t.FirstLocation = '117' then 'FP&A'
when t.FirstLocation = '118' then 'FP&A'
when t.FirstLocation = '119' then 'FP&A'
when t.FirstLocation = '120' then 'FP&A'
when t.FirstLocation = '121' then 'FP&A'
when t.FirstLocation = '122' then 'FP&A'
when t.FirstLocation = '123' then 'FP&A'
when t.FirstLocation = '125' then 'FP&A'
when t.FirstLocation = '126' then 'FP&A'
when t.FirstLocation = '127' then 'FP&A'
when t.FirstLocation = '128' then 'FP&A'
when t.FirstLocation = '129' then 'FP&A'
when t.FirstLocation = '130' then 'FP&A'
when t.FirstLocation = '131' then 'FP&A'
when t.FirstLocation = '132' then 'Controllership'
when t.FirstLocation = '133' then 'Controllership'
when t.FirstLocation = '134' then 'Controllership'
when t.FirstLocation = '135' then 'FP&A'
when t.FirstLocation = '136' then 'Controllership'
when t.FirstLocation = '137' then 'Controllership'
when t.FirstLocation = '138' then 'Controllership'
when t.FirstLocation = '139' then 'FP&A'
when t.FirstLocation = '141' then 'FP&A'
when t.FirstLocation = '142' then 'FP&A'
when t.FirstLocation = '143' then 'FP&A'
when t.FirstLocation = '144' then 'FP&A'
when t.FirstLocation = '145' then 'FP&A'
when t.FirstLocation = '146' then 'FP&A'
when t.FirstLocation = '147' then 'Controllership'
when t.FirstLocation = '148' then 'Controllership'
when t.FirstLocation = '149' then 'Controllership'
when t.FirstLocation = '150' then 'Controllership'
when t.FirstLocation = '151' then 'Controllership'
when t.FirstLocation = '152' then 'Controllership'
when t.FirstLocation = '153' then 'Controllership'
when t.FirstLocation = '154' then 'Controllership'
when t.FirstLocation = '155' then 'Controllership'
when t.FirstLocation = '156' then 'Controllership'
when t.FirstLocation = '157' then 'Controllership'
when t.FirstLocation = '158' then 'Controllership'
when t.FirstLocation = '159' then 'Controllership'
when t.FirstLocation = '160' then 'Controllership'
when t.FirstLocation = '161' then 'Controllership'
when t.FirstLocation = '162' then 'Controllership'
when t.FirstLocation = '163' then 'Controllership'
when t.FirstLocation = '164' then 'Controllership'
when t.FirstLocation = '165' then 'Controllership'
when t.FirstLocation = '167' then 'Controllership'
when t.FirstLocation = '168' then 'Controllership'
when t.FirstLocation = '169' then 'Controllership'
when t.FirstLocation = '171' then 'Controllership'
when t.FirstLocation = '172' then 'Controllership'
when t.FirstLocation = '173' then 'Controllership'
when t.FirstLocation = '174' then 'Controllership'
when t.FirstLocation = '175' then 'Controllership'
when t.FirstLocation = '176' then 'Controllership'
when t.FirstLocation = '254' then 'Controllership'
when t.FirstLocation = '255' then 'Controllership'
when t.FirstLocation = '256' then 'Controllership'
when t.FirstLocation = '257' then 'Controllership'
when t.FirstLocation = '258' then 'Controllership'
when t.FirstLocation = '259' then 'Controllership'
when t.FirstLocation = '260' then 'FP&A'
when t.FirstLocation = '261' then 'Data & Analytics'
when t.FirstLocation = '262' then 'FP&A'
when t.FirstLocation = '263' then 'FP&A'
when t.FirstLocation = '265' then 'FP&A'
when t.FirstLocation = '275' then 'FP&A'
when t.FirstLocation = '276' then 'FP&A'
when t.FirstLocation = '277' then 'FP&A'
when t.FirstLocation = '279' then 'FP&A'
when t.FirstLocation = '280' then 'FP&A'
when t.FirstLocation = '281' then 'Controllership'
when t.FirstLocation = '282' then 'FP&A'
when t.FirstLocation = '283' then 'FP&A'
when t.FirstLocation = '284' then 'FP&A'
when t.FirstLocation = '285' then 'Data & Analytics'
when t.FirstLocation = '287' then 'FP&A'
when t.FirstLocation = '289' then 'FP&A'
when t.FirstLocation = '291' then 'FP&A'
when t.FirstLocation = '295' then 'Data & Analytics'
when t.FirstLocation = '297' then 'FP&A'
when t.FirstLocation = '298' then 'FP&A'
when t.FirstLocation = '300' then 'FP&A'
when t.FirstLocation = '302' then 'Data & Analytics'
when t.FirstLocation = '303' then 'Data & Analytics'
when t.FirstLocation = '304' then 'Data & Analytics'
when t.FirstLocation = '305' then 'Data & Analytics'
when t.FirstLocation = '306' then 'Data & Analytics'
when t.FirstLocation = '309' then 'Data & Analytics'
when t.FirstLocation = '310' then 'Controllership'
when t.FirstLocation = '311' then 'Controllership'
when t.FirstLocation = '312' then 'Controllership'
when t.FirstLocation = '313' then 'Controllership'
when t.FirstLocation = '314' then 'Controllership'
when t.FirstLocation = '315' then 'Controllership'
when t.FirstLocation = '316' then 'Data & Analytics'
when t.FirstLocation = '317' then 'Controllership'
when t.FirstLocation = '318' then 'Data & Analytics'
when t.FirstLocation = '319' then 'Controllership'
when t.FirstLocation = '320' then 'Data & Analytics'
when t.FirstLocation = '321' then 'FP&A'
when t.FirstLocation = '322' then 'FP&A'
when t.FirstLocation = '323' then 'FP&A'
when t.FirstLocation = '324' then 'Controllership'
when t.FirstLocation = '325' then 'Controllership'
when t.FirstLocation = '326' then 'Controllership'
when t.FirstLocation = '327' then 'FP&A'
when t.FirstLocation = '328' then 'FP&A'
when t.FirstLocation = '329' then 'FP&A'
when t.FirstLocation = '330' then 'FP&A'
when t.FirstLocation = '331' then 'Data & Analytics'
when t.FirstLocation = '332' then 'Data & Analytics'
when t.FirstLocation = '333' then 'Data & Analytics'
when t.FirstLocation = '334' then 'Data & Analytics'
when t.FirstLocation = '335' then 'Data & Analytics'
when t.FirstLocation = '336' then 'Data & Analytics'
when t.FirstLocation = '337' then 'FP&A'
when t.FirstLocation = '338' then 'Data & Analytics'
when t.FirstLocation = '339' then 'Data & Analytics'
when t.FirstLocation = '340' then 'Data & Analytics'
when t.FirstLocation = '341' then 'FP&A'
when t.FirstLocation = '342' then 'Data & Analytics'
when t.FirstLocation = '343' then 'Data & Analytics'
when t.FirstLocation = '344' then 'Data & Analytics'
when t.FirstLocation = '345' then 'Data & Analytics'
when t.FirstLocation = '346' then 'Data & Analytics'
when t.FirstLocation = '347' then 'Data & Analytics'
else '' end as BusinessUnit
--#endregion


from SB_ERPTEAM.PUBLIC.TABLE_PAYMENTS_ODBC_USD p
full join SB_ERPTEAM.PUBLIC.T_COLLECTIONS_HEADER t on t.TranID = p.applied_to_internal_id

group by

    t.tranid,
    (t.AmountUSDCred - t.AmountUSDDeb - p.amountpaid),
    t.CustomerName,
    t.Subsidiary,
    t.TranStatus,
    t.postingperiod,
    t.TranCurrency,
    t.FirstLocation


)
-- ,

-- cte2 as (


    
--)

-- select *, case when INVOICESTATUS = 'Paid In Full' then 0 else TotalAmountRemainingUSD end as InvoiceAmountRemaining,
--           case when PAYMENTAPPLIEDAMOUNT is null then 0 else PAYMENTAPPLIEDAMOUNT end as PAYMENTAPPLIEDAMOUNT,
--           case when INVOICESTATUS = 'Open' then (INVOICEAMOUNT-PAYMENTAPPLIEDAMOUNT) else INVOICEAMOUNTREMAINING end as INVOICEAMOUNTREMAINING
-- from cte
select * from cte
;

/*
add customer id to PBI 
looks like there's an issue with currency based on subsidiary
How to bring in all invoices, not just those that have been paid DONE
how to sum the invoice amount before joining - do in first query DONE


CAST( AS DECIMAL(10,2)
*/

-- select * from cte
;
update SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM
SET InvoiceAmountRemaining = 
case when INVOICESTATUS = 'Paid In Full' then 0 else TotalAmountRemainingUSD end
;
update SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM
set PAYMENTAPPLIEDAMOUNT = case when PAYMENTAPPLIEDAMOUNT is null then 0 else PAYMENTAPPLIEDAMOUNT end
;
update SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM
set INVOICEAMOUNTREMAINING = case when INVOICESTATUS = 'Open' then (INVOICEAMOUNT-PAYMENTAPPLIEDAMOUNT) else INVOICEAMOUNTREMAINING end
;

-- update SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM 
-- set ExchangeRate = cex.averagerate
-- from SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM t
-- join SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD cex on cex.periodcurrency = concat(t.PostingPeriod,t.Currency)
-- ;

-- select * from SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM
-- where CustomerName = '72710 KAP Project Services, LTD'
-- ;


//CURRENCY


select * from SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM
;
tl.id,
tl.foreignamountunpaid

from INBOUND_RAW.NETSUITE.TRANSACTION t
join INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl on tl.transaction = t.id
join INBOUND_RAW.NETSUITE.CUSTOMER c on c.id = t.entity

where c.entityid = '72710' and tl.id = 0 and t.STATUS
