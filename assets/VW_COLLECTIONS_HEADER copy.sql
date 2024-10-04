CREATE OR REPLACE table SB_ERPTEAM.PUBLIC.T_COLLECTIONS_HEADER AS 

select 
t.id as TranID, 
t.trandate as TransDate, 
t.type as TranType, 
//tl.item as TranItem, 
//tal.amount, 
ts.name as TranStatus,
tl.creditforeignamount as ForeignAmount,
s.name as Subsidiary,
c.companyname as CustomerName,
c.custentity_credit_hold as CreditHold,
cur.name as TranCurrency,
emp.email as LastModifiedBy,
tl.creditforeignamount * cex.averagerate as AmountUSDCred,
tl.debitforeignamount * cex.averagerate as AmountUSDDeb,
tl.closedate as ClosedDate,
tl.cleareddate as ClearedDate,
t.duedate as DueDate,
//COALESCE(rt.applied_to_transaction_amount_remaining, 0) * cex.averagerate AS AmountRemaining,

a.id as SFAccountID,
a.type as SFAccountType,
a.owner_name_c as SFAccountOwner,
t.TRANID as DocumentNumber

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
left join SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD cex on cex.periodcurrency = concat(p.id,cur.name)
left join INBOUND_RAW.SALESFORCE.ACCOUNT a on a.id = c.externalid


// Pull in consolidated exchange 
// use this to replicate portal

where exists (select 1 from INBOUND_RAW.NETSUITE.TRANSACTIONSTATUS ts2 where ts2.TRANTYPE = 'CustInvc')
and t.type = 'CustInvc' and tl.mainline = 'F' and (tl.creditforeignamount <> 0 or tl.debitforeignamount <> 0)
--#endregion

group by
 
t.id, 
t.trandate, 
t.type, 
//tl.item as TranItem, 
//tal.amount, 
ts.name,
tl.creditforeignamount,
s.name,
c.companyname,
c.custentity_credit_hold,
cur.name,
emp.email,
tl.creditforeignamount * cex.averagerate,
tl.debitforeignamount * cex.averagerate,
tl.closedate,
tl.cleareddate,
t.duedate,


a.id,
a.type,
a.owner_name_c,
t.TRANID 
;



--CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM AS 

with cte as ( 
select 
p.internal_id as PaymentInternalID,
p.APPLIED_TO_INTERNAL_ID,
t.tranid,
p.APPLIED_TO_AMOUNT_USD,
t.AmountUSDCred,
(t.AmountUSDCred - p.APPLIED_TO_AMOUNT_USD) as TotalAmountRemainingUSD

from SB_ERPTEAM.PUBLIC.TABLE_PAYMENTS_ODBC_USD p
join SB_ERPTEAM.PUBLIC.T_COLLECTIONS_HEADER t on t.TranID = p.applied_to_internal_id
group by

p.internal_id,
p.APPLIED_TO_INTERNAL_ID,
t.tranid,
p.APPLIED_TO_AMOUNT_USD,
t.AmountUSDCred,
(t.AmountUSDCred - p.APPLIED_TO_AMOUNT_USD)
)
/*
how to sum the invoice amount before joining - do in first query 

 */

select * from cte
;

select * from SB_ERPTEAM.PUBLIC.T_PAYMENT_APPLIED_TO_SUM

;

select * from SB_ERPTEAM.PUBLIC.T_COLLECTIONS_HEADER