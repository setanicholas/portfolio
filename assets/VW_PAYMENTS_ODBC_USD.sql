
//CREATE OR REPLACE VIEW SB_ERPTEAM.PUBLIC.VW_PAYMENTS_ODBC_USD AS 

CREATE OR REPLACE PROCEDURE USP_TABLE_PAYMENTS_ODBC_USD()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.TABLE_PAYMENTS_ODBC_USD AS 

select

distinct
p.id as INTERNAL_ID,
p.trandate as PAYMENT_DATE,
p.createddate as PAYMENT_CREATED_DATE,
appl_c.companyname as APPLIED_TO_NAME,
appl.id as APPLIED_TO_INTERNAL_ID,
appl.trandate as APPLIED_TO_DATE,
appl.type as APPLIED_TO_TYPE,
(p_tal.amount * p_usd.averagerate) - (p.custbody_unapplied_amount * p_usd.averagerate) as PAYMENT_PAYING_AMOUNT,
p_tal.amount as AMOUNT_PAID_FOR_EX_,
p.trandisplayname as PAYING_TRANSACTION,
p.id as PAYMENT_DOCUMENT_NUMBER,
p.custbody_itr_doc_number as IS_PAYMENT,
appl.duedate as APPLIED_TO_DUE_DATE,
appl_s.name as APPLIED_TO_TRANSACTION_SUBSIDIARY,
CAST(p.custbody_unapplied_amount * p_usd.averagerate AS DECIMAL(18, 2)) AS AMOUNT_REMAINING, -- Cast to DECIMAL(18, 2) or your desired data type
p_tl.subsidiary as SUBSIDIARY_INTERNAL_ID,  
p.postingperiod as ACCOUNTING_PERIOD_INTERNAL_ID,
(appl_tal.amountunpaid * appl_usd.averagerate) as APPLIED_TO_TRANSACTION_AMOUNT_REMAINING,
concat(p.postingperiod,p.currency) as PERIOD_CUR,
p_tal.amount * p_usd.averagerate as PAYMENT_PAYING_AMOUNT_USD,
appl_tal.amount * appl_usd.averagerate as APPLIED_TO_AMOUNT_USD,
appl_usd.averagerate as AppliedAverageRate,
p_usd.averagerate as PayementAverageRate,
p_tal.account as PaymentAccount,
p_tal.credit as PaymentCreditAmount,
p_tal.debit as PaymentDebitAmount,
p_tl.creditforeignamount as PaymentCreditForeign,
p_tl.debitforeignamount as PaymentDebitForeign,
ptli.nextdoc,
ptli.previousdoc,
ptli.linktype,
ptli.nexttype,
ptli.previoustype,
ptli.previousline,
appl_tal.amountpaid * p_usd.averagerate as AmountPaid,
p.currency


//Payment to Applied to Link
from INBOUND_RAW.NETSUITE.TRANSACTION p
join INBOUND_RAW.NETSUITE.PREVIOUSTRANSACTIONLINELINK ptli on ptli.nextdoc = p.id
join INBOUND_RAW.NETSUITE.TRANSACTION appl on appl.id = ptli.previousdoc

// Applied to Customer
join INBOUND_RAW.NETSUITE.CUSTOMER appl_c on appl_c.id = appl.entity

// Payment Sub Currency
join INBOUND_RAW.NETSUITE.TRANSACTIONLINE p_tl on p_tl.transaction = p.id
join INBOUND_RAW.NETSUITE.SUBSIDIARY p_sub on p_sub.id = p_tl.subsidiary
join INBOUND_RAW.NETSUITE.CURRENCY p_cur on p_cur.id = p_sub.currency
join SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD p_usd on p_usd.periodcurrency = concat(p.postingperiod,p_cur.name)
join INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE p_tal on concat(p_tal.transaction,p_tal.transactionline) = concat(p_tl.transaction,p_tl.id)

// Applied to Currency
join INBOUND_RAW.NETSUITE.TRANSACTIONLINE appl_tl on appl_tl.transaction = appl.id
join INBOUND_RAW.NETSUITE.SUBSIDIARY appl_s on appl_s.id = appl_tl.subsidiary
join INBOUND_RAW.NETSUITE.CURRENCY appl_cur on appl_cur.id = p_sub.currency
join SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD appl_usd on appl_usd.periodcurrency = concat(appl.postingperiod,appl_cur.name)
join INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE appl_tal on concat(appl_tal.transaction,appl_tal.transactionline) = concat(appl_tl.transaction,appl_tl.id)

//Accounting Lines

where 
ptli.nexttype = 'CustPymt' 
and p_tal.accountingbook = 1
-- //and p.id = '8054381'
     and p_tl.id = 0
     and appl_tl.id = 0
-- //and p.id = '500955'
-- //and appl.id = '15392340'
     and appl_tal.amountpaid <> 0
and ptli._fivetran_deleted = 'FALSE'
order by p.id

;
    RETURN 'Table SB_ERPTEAM.PUBLIC.USP_TABLE_PAYMENTS_ODBC_USD created successfully';
END;
$$;
;

select * from SB_ERPTEAM.PUBLIC.TABLE_PAYMENTS_ODBC_USD where internal_id = '18004078'












//select * from INBOUND_RAW.NETSUITE.PREVIOUSTRANSACTIONLINELINK where nextdoc = 2602618






















-- ptli.nextdoc, 
-- ptli.foreignamount, 
-- ptli.previousdoc, 
-- appl.id, 
-- tal.amount


-- group by
-- p.id, 
-- ptli.nextdoc, 
-- ptli.foreignamount, 
-- ptli.previousdoc, 
-- appl.id,
-- tal.amount


-- select * from SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD


//CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.PAYMENTS_AMOUNT AS
-- SELECT
--   p.id AS INTERNAL_ID,
--   SUM(tl.creditforeignamount) AS PAYMENT_CREDIT_AMOUNT
--   FROM INBOUND_RAW.NETSUITE.TRANSACTION p
-- JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON tl.transaction = p.id
-- WHERE
-- p.type = 'CustPymt'
-- GROUP BY p.id
-- ;

-- select * from SB_ERPTEAM.PUBLIC.PAYMENTS_AMOUNT

-- ;

-- CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.APPLIED_TO_AMOUNT AS
-- SELECT
--   p.id AS INTERNAL_ID,
--   SUM(tl.creditforeignamount) AS PAYMENT_CREDIT_AMOUNT
--   FROM INBOUND_RAW.NETSUITE.TRANSACTION p
-- JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON tl.transaction = p.id
-- WHERE
-- p.type <> 'CustPymt'
-- GROUP BY p.id
-- ;

-- select * from SB_ERPTEAM.PUBLIC.APPLIED_TO_AMOUNT



-- ;


-- CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.PAYMENT_APPLIED_TO AS
-- select 
-- p.internal_id as P_INTERNAL_ID,
-- p.payment_credit_amount as payment_credit_amount,
-- link.internal_id as link_internal_ID,
-- link.payment_credit_amount as link_credit_amount,
-- p.payment_credit_amount - link.payment_credit_amount as delta

-- from SB_ERPTEAM.PUBLIC.PAYMENTS_AMOUNT p
-- join INBOUND_RAW.NETSUITE.PREVIOUSTRANSACTIONLINELINK ptli on ptli.nextdoc = p.INTERNAL_ID
-- join SB_ERPTEAM.PUBLIC.APPLIED_TO_AMOUNT link on ptli.previousdoc = link.internal_id
-- order by p.internal_id

-- ;

-- select * from SB_ERPTEAM.PUBLIC.PAYMENT_APPLIED_TO


-- ;

//select id from INBOUND_RAW.NETSUITE.TRANSACTION where type = 'CustPymt' 

