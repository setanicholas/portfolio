
--#region Create VW_COLLECTIONS

CREATE OR REPLACE VIEW SB_ERPTEAM.PUBLIC.VW_COLLECTIONS AS 

select 
t.id as TranID, 
t.trandate as TransDate, 
t.type as TranType, 
//tl.item as TranItem, 
i.itemid as ItemName, 
i.custitem_product_family as ItemProductFamily, 
//tal.amount, 
ts.name as TranStatus,
tl.creditforeignamount as ForeignAmount,
s.name as Subsidiary,
concat(c.entityid, concat(' ',c.companyname)) as CustomerName,
c.custentity_credit_hold as CreditHold,
cur.name as TranCurrency,
emp.email as LastModifiedBy,
tl.creditforeignamount * cex.exchangerate as AmountUSDCred,
tl.debitforeignamount * cex.exchangerate as AmountUSDDeb,
tl.rateamount,
rrr.name as "Rev Rec Rule",
i.itemtype as "Item Type",
tl.closedate as ClosedDate,
tl.cleareddate as ClearedDate,
t.duedate as DueDate,
tl.id as TransactionLineID,
rt.payment_date as "Payment Date",
rt.PAYMENT_PAYING_AMOUNT as PaymentAmount,
rt.INTERNAL_ID as PaymentInternalID,
rt.APPLIED_TO_INTERNAL_ID as PaymentInvoiceInternalID,
rt.APPLIED_TO_DATE as PaymentInvoiceDate,
COALESCE(tl.creditforeignamount, 0) * COALESCE(cex.exchangerate, 0) - COALESCE(tl.debitforeignamount, 0) * COALESCE(cex.exchangerate, 0) AS TotalLineAmountUSD,
COALESCE(rt.applied_to_transaction_amount_remaining, 0) * cex.exchangerate AS AmountRemaining,
i.custitem_product_family as  ProductLine,

--#region ProductLine > ProductGroup
case
when i.location = '1' then 'Spreadsheet Server'
when i.location = '2' then 'Spreadsheet Server'
when i.location = '3' then 'Spreadsheet Server'
when i.location = '4' then 'Other Financial Reporting'
when i.location = '5' then 'Spreadsheet Server'
when i.location = '6' then 'Logi'
when i.location = '8' then 'Spreadsheet Server'
when i.location = '9' then 'Spreadsheet Server'
when i.location = '10' then 'Spreadsheet Server'
when i.location = '12' then 'Hubble'
when i.location = '13' then 'Other'
when i.location = '14' then 'Spreadsheet Server'
when i.location = '15' then 'Hubble'
when i.location = '16' then 'Other'
when i.location = '17' then 'Spreadsheet Server'
when i.location = '18' then 'Hubble'
when i.location = '19' then 'Hubble'
when i.location = '20' then 'Wands'
when i.location = '22' then 'Bizview'
when i.location = '23' then 'Hubble'
when i.location = '24' then 'Hubble'
when i.location = '101' then 'Wands'
when i.location = '102' then 'Wands'
when i.location = '104' then 'CXO'
when i.location = '105' then 'Wands'
when i.location = '106' then 'Wands'
when i.location = '107' then 'Hubble'
when i.location = '108' then 'Hubble'
when i.location = '109' then 'Hubble'
when i.location = '110' then 'Hubble'
when i.location = '111' then 'Hubble'
when i.location = '112' then 'Hubble'
when i.location = '113' then 'Hubble'
when i.location = '114' then 'Wands'
when i.location = '115' then 'Hubble'
when i.location = '117' then 'Other Financial Reporting'
when i.location = '118' then 'Jet'
when i.location = '119' then 'Jet'
when i.location = '120' then 'Jet'
when i.location = '121' then 'Spreadsheet Server'
when i.location = '122' then 'Jet'
when i.location = '123' then 'Hubble'
when i.location = '125' then 'Jet'
when i.location = '126' then 'Hubble'
when i.location = '127' then 'Jet'
when i.location = '128' then 'Bizview'
when i.location = '129' then 'Bizview'
when i.location = '130' then 'Bizview'
when i.location = '131' then 'Longview Analytics'
when i.location = '132' then 'Longview Close'
when i.location = '133' then 'Tax'
when i.location = '134' then 'Longview Close'
when i.location = '135' then 'Tidemark'
when i.location = '136' then 'Longview Close'
when i.location = '137' then 'Tax'
when i.location = '138' then 'Tax'
when i.location = '139' then 'Wands'
when i.location = '141' then 'Other Financial Reporting'
when i.location = '142' then 'Other Financial Reporting'
when i.location = '143' then 'Other Financial Reporting'
when i.location = '144' then 'Other Financial Reporting'
when i.location = '145' then 'Spreadsheet Server'
when i.location = '146' then 'Other Financial Reporting'
when i.location = '147' then 'Viareport'
when i.location = '148' then 'Viareport'
when i.location = '149' then 'Equity'
when i.location = '150' then 'Disclosure Management'
when i.location = '151' then 'Disclosure Management'
when i.location = '152' then 'Disclosure Management'
when i.location = '153' then 'Disclosure Management'
when i.location = '154' then 'IDL'
when i.location = '155' then 'IDL'
when i.location = '156' then 'IDL'
when i.location = '157' then 'IDL'
when i.location = '158' then 'IDL'
when i.location = '159' then 'IDL'
when i.location = '160' then 'IDL'
when i.location = '161' then 'IDL'
when i.location = '162' then 'IDL'
when i.location = '163' then 'IDL'
when i.location = '164' then 'IDL'
when i.location = '165' then 'IDL'
when i.location = '167' then 'IDL'
when i.location = '168' then 'IDL'
when i.location = '169' then 'IDL'
when i.location = '171' then 'IDL'
when i.location = '172' then 'IDL'
when i.location = '173' then 'IDL'
when i.location = '174' then 'IDL'
when i.location = '175' then 'IDL'
when i.location = '176' then 'IDL'
when i.location = '254' then 'IDL'
when i.location = '255' then 'IDL'
when i.location = '256' then 'IDL'
when i.location = '257' then 'IDL'
when i.location = '258' then 'IDL'
when i.location = '259' then 'IDL'
when i.location = '260' then 'Calumo'
when i.location = '261' then 'Data Intelligence'
when i.location = '262' then 'Angles'
when i.location = '263' then 'Angles'
when i.location = '265' then 'Other Financial Reporting'
when i.location = '275' then 'Other Financial Reporting'
when i.location = '276' then 'Other Financial Reporting'
when i.location = '277' then 'Other Financial Reporting'
when i.location = '279' then 'Hubble'
when i.location = '280' then 'Hubble'
when i.location = '281' then 'IDL'
when i.location = '282' then 'Jet'
when i.location = '283' then 'Jet'
when i.location = '284' then 'Jet'
when i.location = '285' then 'Data Intelligence'
when i.location = '287' then 'Spreadsheet Server'
when i.location = '289' then 'Operational Reporting'
when i.location = '291' then 'Process Runner'
when i.location = '295' then 'Simba'
when i.location = '297' then 'Spreadsheet Server'
when i.location = '298' then 'Tidemark'
when i.location = '300' then 'Other Financial Reporting'
when i.location = '302' then 'Logi'
when i.location = '303' then 'Logi'
when i.location = '304' then 'Logi'
when i.location = '305' then 'Logi'
when i.location = '306' then 'Logi'
when i.location = '309' then 'Logi'
when i.location = '310' then 'Other Close & Consolidation'
when i.location = '311' then 'Other Close & Consolidation'
when i.location = '312' then 'Other Close & Consolidation'
when i.location = '313' then 'Other Close & Consolidation'
when i.location = '314' then 'Other Close & Consolidation'
when i.location = '315' then 'Other Close & Consolidation'
when i.location = '316' then 'Logi'
when i.location = '317' then 'Other Close & Consolidation'
when i.location = '318' then 'Logi'
when i.location = '319' then 'Tax'
when i.location = '320' then 'Power ON'
when i.location = '321' then 'Angles'
when i.location = '322' then 'Angles'
when i.location = '323' then 'Angles'
when i.location = '324' then 'Other Close & Consolidation'
when i.location = '325' then 'Other Close & Consolidation'
when i.location = '326' then 'Other Close & Consolidation'
when i.location = '327' then 'Process Runner'
when i.location = '328' then 'Process Runner'
when i.location = '329' then 'Process Runner'
when i.location = '330' then 'Process Runner'
when i.location = '331' then 'Simba'
when i.location = '332' then 'Simba'
when i.location = '333' then 'SourceConnect'
when i.location = '334' then 'Power ON'
when i.location = '335' then 'Power ON'
when i.location = '336' then 'Power ON'
when i.location = '337' then 'Angles'
when i.location = '338' then 'Power ON'
when i.location = '339' then 'Power ON'
when i.location = '340' then 'Platform'
when i.location = '341' then 'Angles'
when i.location = '342' then 'Vizlib'
when i.location = '343' then 'Vizlib'
when i.location = '344' then 'Vizlib'
when i.location = '345' then 'Vizlib'
when i.location = '346' then 'Vizlib'
when i.location = '347' then 'Vizlib'




else '' end as ProductGroup,
--#endregion

--#region ProductLine > Pillar
case  
when i.location = '1' then 'Financial Reporting'
when i.location = '2' then 'Financial Reporting'
when i.location = '3' then 'Financial Reporting'
when i.location = '4' then 'Financial Reporting'
when i.location = '5' then 'Financial Reporting'
when i.location = '6' then 'Embedded Analytics & Data Intelligence'
when i.location = '8' then 'Financial Reporting'
when i.location = '9' then 'Financial Reporting'
when i.location = '10' then 'Financial Reporting'
when i.location = '12' then 'Financial Reporting'
when i.location = '13' then 'Financial Reporting'
when i.location = '14' then 'Financial Reporting'
when i.location = '15' then 'Financial Reporting'
when i.location = '16' then 'Financial Reporting'
when i.location = '17' then 'Financial Reporting'
when i.location = '18' then 'Financial Reporting'
when i.location = '19' then 'Financial Reporting'
when i.location = '20' then 'Financial Reporting'
when i.location = '22' then 'Budgeting and Planning'
when i.location = '23' then 'Financial Reporting'
when i.location = '24' then 'Financial Reporting'
when i.location = '101' then 'Financial Reporting'
when i.location = '102' then 'Financial Reporting'
when i.location = '104' then 'Financial Reporting'
when i.location = '105' then 'Financial Reporting'
when i.location = '106' then 'Financial Reporting'
when i.location = '107' then 'Financial Reporting'
when i.location = '108' then 'Financial Reporting'
when i.location = '109' then 'Financial Reporting'
when i.location = '110' then 'Financial Reporting'
when i.location = '111' then 'Financial Reporting'
when i.location = '112' then 'Financial Reporting'
when i.location = '113' then 'Financial Reporting'
when i.location = '114' then 'Financial Reporting'
when i.location = '115' then 'Financial Reporting'
when i.location = '117' then 'Financial Reporting'
when i.location = '118' then 'Financial Reporting'
when i.location = '119' then 'Financial Reporting'
when i.location = '120' then 'Financial Reporting'
when i.location = '121' then 'Financial Reporting'
when i.location = '122' then 'Financial Reporting'
when i.location = '123' then 'Financial Reporting'
when i.location = '125' then 'Financial Reporting'
when i.location = '126' then 'Financial Reporting'
when i.location = '127' then 'Financial Reporting'
when i.location = '128' then 'Budgeting and Planning'
when i.location = '129' then 'Budgeting and Planning'
when i.location = '130' then 'Budgeting and Planning'
when i.location = '131' then 'Operational Reporting'
when i.location = '132' then 'Close and Consolidation'
when i.location = '133' then 'Tax Reporting'
when i.location = '134' then 'Close and Consolidation'
when i.location = '135' then 'Budgeting and Planning'
when i.location = '136' then 'Close and Consolidation'
when i.location = '137' then 'Tax Reporting'
when i.location = '138' then 'Tax Reporting'
when i.location = '139' then 'Financial Reporting'
when i.location = '141' then 'Financial Reporting'
when i.location = '142' then 'Financial Reporting'
when i.location = '143' then 'Financial Reporting'
when i.location = '144' then 'Financial Reporting'
when i.location = '145' then 'Financial Reporting'
when i.location = '146' then 'Financial Reporting'
when i.location = '147' then 'Close and Consolidation'
when i.location = '148' then 'Close and Consolidation'
when i.location = '149' then 'Equity Management'
when i.location = '150' then 'Disclosure Management'
when i.location = '151' then 'Disclosure Management'
when i.location = '152' then 'Disclosure Management'
when i.location = '153' then 'Disclosure Management'
when i.location = '154' then 'Close and Consolidation'
when i.location = '155' then 'Close and Consolidation'
when i.location = '156' then 'Close and Consolidation'
when i.location = '157' then 'Close and Consolidation'
when i.location = '158' then 'Close and Consolidation'
when i.location = '159' then 'Close and Consolidation'
when i.location = '160' then 'Close and Consolidation'
when i.location = '161' then 'Close and Consolidation'
when i.location = '162' then 'Close and Consolidation'
when i.location = '163' then 'Close and Consolidation'
when i.location = '164' then 'Close and Consolidation'
when i.location = '165' then 'Close and Consolidation'
when i.location = '167' then 'Close and Consolidation'
when i.location = '168' then 'Close and Consolidation'
when i.location = '169' then 'Close and Consolidation'
when i.location = '171' then 'Close and Consolidation'
when i.location = '172' then 'Close and Consolidation'
when i.location = '173' then 'Close and Consolidation'
when i.location = '174' then 'Close and Consolidation'
when i.location = '175' then 'Close and Consolidation'
when i.location = '176' then 'Close and Consolidation'
when i.location = '254' then 'Close and Consolidation'
when i.location = '255' then 'Close and Consolidation'
when i.location = '256' then 'Close and Consolidation'
when i.location = '257' then 'Close and Consolidation'
when i.location = '258' then 'Close and Consolidation'
when i.location = '259' then 'Close and Consolidation'
when i.location = '260' then 'Budgeting and Planning'
when i.location = '261' then 'Embedded Analytics & Data Intelligence'
when i.location = '262' then 'Operational Reporting'
when i.location = '263' then 'Operational Reporting'
when i.location = '265' then 'Financial Reporting'
when i.location = '275' then 'Financial Reporting'
when i.location = '276' then 'Financial Reporting'
when i.location = '277' then 'Financial Reporting'
when i.location = '279' then 'Financial Reporting'
when i.location = '280' then 'Financial Reporting'
when i.location = '281' then 'Close and Consolidation'
when i.location = '282' then 'Financial Reporting'
when i.location = '283' then 'Financial Reporting'
when i.location = '284' then 'Financial Reporting'
when i.location = '285' then 'Embedded Analytics & Data Intelligence'
when i.location = '287' then 'Financial Reporting'
when i.location = '289' then 'Operational Reporting'
when i.location = '291' then 'Operational Reporting'
when i.location = '295' then 'Data Integrations'
when i.location = '297' then 'Financial Reporting'
when i.location = '298' then 'Budgeting and Planning'
when i.location = '300' then 'Financial Reporting'
when i.location = '302' then 'Embedded Analytics & Data Intelligence'
when i.location = '303' then 'Embedded Analytics & Data Intelligence'
when i.location = '304' then 'Embedded Analytics & Data Intelligence'
when i.location = '305' then 'Embedded Analytics & Data Intelligence'
when i.location = '306' then 'Embedded Analytics & Data Intelligence'
when i.location = '309' then 'Embedded Analytics & Data Intelligence'
when i.location = '310' then 'Close and Consolidation'
when i.location = '311' then 'Close and Consolidation'
when i.location = '312' then 'Close and Consolidation'
when i.location = '313' then 'Close and Consolidation'
when i.location = '314' then 'Close and Consolidation'
when i.location = '315' then 'Close and Consolidation'
when i.location = '316' then 'Embedded Analytics & Data Intelligence'
when i.location = '317' then 'Close and Consolidation'
when i.location = '318' then 'Embedded Analytics & Data Intelligence'
when i.location = '319' then 'Tax Reporting'
when i.location = '320' then 'Data Integrations'
when i.location = '321' then 'Operational Reporting'
when i.location = '322' then 'Operational Reporting'
when i.location = '323' then 'Operational Reporting'
when i.location = '324' then 'Close and Consolidation'
when i.location = '325' then 'Close and Consolidation'
when i.location = '326' then 'Close and Consolidation'
when i.location = '327' then 'Operational Reporting'
when i.location = '328' then 'Operational Reporting'
when i.location = '329' then 'Operational Reporting'
when i.location = '330' then 'Operational Reporting'
when i.location = '331' then 'Data Integrations'
when i.location = '332' then 'Data Integrations'
when i.location = '333' then 'Data Integrations'
when i.location = '334' then 'Data Integrations'
when i.location = '335' then 'Data Integrations'
when i.location = '336' then 'Data Integrations'
when i.location = '337' then 'Operational Reporting'
when i.location = '338' then 'Data Integrations'
when i.location = '339' then 'Data Integrations'
when i.location = '340' then 'Data Integrations'
when i.location = '341' then 'Operational Reporting'
when i.location = '342' then 'Data Integrations'
when i.location = '343' then 'Data Integrations'
when i.location = '344' then 'Data Integrations'
when i.location = '345' then 'Data Integrations'
when i.location = '346' then 'Data Integrations'
when i.location = '347' then 'Data Integrations'



else '' end as Pillar,
--#endregion

--#region ProductLine > Business Unit
case  

when i.location = '1' then 'FP&A'
when i.location = '2' then 'FP&A'
when i.location = '3' then 'FP&A'
when i.location = '4' then 'FP&A'
when i.location = '5' then 'FP&A'
when i.location = '6' then 'Data & Analytics'
when i.location = '8' then 'FP&A'
when i.location = '9' then 'FP&A'
when i.location = '10' then 'FP&A'
when i.location = '12' then 'FP&A'
when i.location = '13' then 'FP&A'
when i.location = '14' then 'FP&A'
when i.location = '15' then 'FP&A'
when i.location = '16' then 'FP&A'
when i.location = '17' then 'FP&A'
when i.location = '18' then 'FP&A'
when i.location = '19' then 'FP&A'
when i.location = '20' then 'FP&A'
when i.location = '22' then 'FP&A'
when i.location = '23' then 'FP&A'
when i.location = '24' then 'FP&A'
when i.location = '101' then 'FP&A'
when i.location = '102' then 'FP&A'
when i.location = '104' then 'FP&A'
when i.location = '105' then 'FP&A'
when i.location = '106' then 'FP&A'
when i.location = '107' then 'FP&A'
when i.location = '108' then 'FP&A'
when i.location = '109' then 'FP&A'
when i.location = '110' then 'FP&A'
when i.location = '111' then 'FP&A'
when i.location = '112' then 'FP&A'
when i.location = '113' then 'FP&A'
when i.location = '114' then 'FP&A'
when i.location = '115' then 'FP&A'
when i.location = '117' then 'FP&A'
when i.location = '118' then 'FP&A'
when i.location = '119' then 'FP&A'
when i.location = '120' then 'FP&A'
when i.location = '121' then 'FP&A'
when i.location = '122' then 'FP&A'
when i.location = '123' then 'FP&A'
when i.location = '125' then 'FP&A'
when i.location = '126' then 'FP&A'
when i.location = '127' then 'FP&A'
when i.location = '128' then 'FP&A'
when i.location = '129' then 'FP&A'
when i.location = '130' then 'FP&A'
when i.location = '131' then 'FP&A'
when i.location = '132' then 'Controllership'
when i.location = '133' then 'Controllership'
when i.location = '134' then 'Controllership'
when i.location = '135' then 'FP&A'
when i.location = '136' then 'Controllership'
when i.location = '137' then 'Controllership'
when i.location = '138' then 'Controllership'
when i.location = '139' then 'FP&A'
when i.location = '141' then 'FP&A'
when i.location = '142' then 'FP&A'
when i.location = '143' then 'FP&A'
when i.location = '144' then 'FP&A'
when i.location = '145' then 'FP&A'
when i.location = '146' then 'FP&A'
when i.location = '147' then 'Controllership'
when i.location = '148' then 'Controllership'
when i.location = '149' then 'Controllership'
when i.location = '150' then 'Controllership'
when i.location = '151' then 'Controllership'
when i.location = '152' then 'Controllership'
when i.location = '153' then 'Controllership'
when i.location = '154' then 'Controllership'
when i.location = '155' then 'Controllership'
when i.location = '156' then 'Controllership'
when i.location = '157' then 'Controllership'
when i.location = '158' then 'Controllership'
when i.location = '159' then 'Controllership'
when i.location = '160' then 'Controllership'
when i.location = '161' then 'Controllership'
when i.location = '162' then 'Controllership'
when i.location = '163' then 'Controllership'
when i.location = '164' then 'Controllership'
when i.location = '165' then 'Controllership'
when i.location = '167' then 'Controllership'
when i.location = '168' then 'Controllership'
when i.location = '169' then 'Controllership'
when i.location = '171' then 'Controllership'
when i.location = '172' then 'Controllership'
when i.location = '173' then 'Controllership'
when i.location = '174' then 'Controllership'
when i.location = '175' then 'Controllership'
when i.location = '176' then 'Controllership'
when i.location = '254' then 'Controllership'
when i.location = '255' then 'Controllership'
when i.location = '256' then 'Controllership'
when i.location = '257' then 'Controllership'
when i.location = '258' then 'Controllership'
when i.location = '259' then 'Controllership'
when i.location = '260' then 'FP&A'
when i.location = '261' then 'Data & Analytics'
when i.location = '262' then 'FP&A'
when i.location = '263' then 'FP&A'
when i.location = '265' then 'FP&A'
when i.location = '275' then 'FP&A'
when i.location = '276' then 'FP&A'
when i.location = '277' then 'FP&A'
when i.location = '279' then 'FP&A'
when i.location = '280' then 'FP&A'
when i.location = '281' then 'Controllership'
when i.location = '282' then 'FP&A'
when i.location = '283' then 'FP&A'
when i.location = '284' then 'FP&A'
when i.location = '285' then 'Data & Analytics'
when i.location = '287' then 'FP&A'
when i.location = '289' then 'FP&A'
when i.location = '291' then 'FP&A'
when i.location = '295' then 'Data & Analytics'
when i.location = '297' then 'FP&A'
when i.location = '298' then 'FP&A'
when i.location = '300' then 'FP&A'
when i.location = '302' then 'Data & Analytics'
when i.location = '303' then 'Data & Analytics'
when i.location = '304' then 'Data & Analytics'
when i.location = '305' then 'Data & Analytics'
when i.location = '306' then 'Data & Analytics'
when i.location = '309' then 'Data & Analytics'
when i.location = '310' then 'Controllership'
when i.location = '311' then 'Controllership'
when i.location = '312' then 'Controllership'
when i.location = '313' then 'Controllership'
when i.location = '314' then 'Controllership'
when i.location = '315' then 'Controllership'
when i.location = '316' then 'Data & Analytics'
when i.location = '317' then 'Controllership'
when i.location = '318' then 'Data & Analytics'
when i.location = '319' then 'Controllership'
when i.location = '320' then 'Data & Analytics'
when i.location = '321' then 'FP&A'
when i.location = '322' then 'FP&A'
when i.location = '323' then 'FP&A'
when i.location = '324' then 'Controllership'
when i.location = '325' then 'Controllership'
when i.location = '326' then 'Controllership'
when i.location = '327' then 'FP&A'
when i.location = '328' then 'FP&A'
when i.location = '329' then 'FP&A'
when i.location = '330' then 'FP&A'
when i.location = '331' then 'Data & Analytics'
when i.location = '332' then 'Data & Analytics'
when i.location = '333' then 'Data & Analytics'
when i.location = '334' then 'Data & Analytics'
when i.location = '335' then 'Data & Analytics'
when i.location = '336' then 'Data & Analytics'
when i.location = '337' then 'FP&A'
when i.location = '338' then 'Data & Analytics'
when i.location = '339' then 'Data & Analytics'
when i.location = '340' then 'Data & Analytics'
when i.location = '341' then 'FP&A'
when i.location = '342' then 'Data & Analytics'
when i.location = '343' then 'Data & Analytics'
when i.location = '344' then 'Data & Analytics'
when i.location = '345' then 'Data & Analytics'
when i.location = '346' then 'Data & Analytics'
when i.location = '347' then 'Data & Analytics'


else '' end as BusinessUnit,
--#endregion

a.id as SFAccountID,
a.type as SFAccountType,
a.owner_name_c as SFAccountOwner,
t.TRANID as DocumentNumber,
cex.exchangerate as ExchangeRate,
a.type as CustomerType,
a.Owner_Name_c as AccountOwner,
a.Customer_Success_Associate_c as CustomerSuccessManager,
a.Account_Cancellation_c as AccountCancellationFlag,
a.Cancellation_Date_c as AccountCancellationDate,
a.At_Risk_c as AtRisk,
a.Number_of_Open_At_Risk_Records_c as OpenAtRiskNumbers,
a.annual_revenue as AccountARR,
t.entity as CustomerID




/*

NEW QUERY

Open At-Risk Number

At-Risk Subject

At-Risk Status

At-Risk Created Date

At-Risk Reason
 */

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
left join SB_ERPTEAM.PUBLIC.USDCONVERSIONBYDAY cex on cex.daycurrency = concat(cast(t.trandate as DATE),t.currency)
full join SB_ERPTEAM.PUBLIC.TABLE_PAYMENTS_ODBC_USD rt on rt.APPLIED_TO_INTERNAL_ID = t.id
left join INBOUND_RAW.SALESFORCE.ACCOUNT a on a.id = c.externalid


// Pull in consolidated exchange 
// use this to replicate portal

where exists (select 1 from INBOUND_RAW.NETSUITE.TRANSACTIONSTATUS ts2 where ts2.TRANTYPE = 'CustInvc')
and t.type = 'CustInvc' and tl.mainline = 'F' and (tl.creditforeignamount <> 0 or tl.debitforeignamount <> 0)


--#endregion
;

select top 1000 * from SB_ERPTEAM.PUBLIC.VW_COLLECTIONS 
where tranid = '19168869'
;


select * from INBOUND_RAW.SALESFORCE.PRODUCT_2 where bmi_sf_ns_net_suite_id_c = '2163'
///select * from INBOUND_RAW.ENT_DATA_FLAT_FILES.SETA_TEST_SYSTEM_NOTE_SEARCH_RESULTS_813



-- select * from INBOUND_RAW.NETSUITE.transactionaccountingline tl where tl.transaction = '8535946';

-- -- CustPymt

-- -- select type from INBOUND_RAW.NETSUITE.TRANSACTION
-- -- group by type
-- select * from INBOUND_RAW.NETSUITE.NOTE

--select * from INBOUND_RAW.NETSUITE.TRANSACTIONLINE


--#region Archived
create or replace view SB_ERPTEAM.PUBLIC.VW_COLLECTIONS(
	TRANID,
	TRANSDATE,
	TRANTYPE,
	ITEMNAME,
	ITEMPRODUCTFAMILY,
	TRANSTATUS,
	FOREIGNAMOUNT,
	SUBSIDIARY,
	CUSTOMERNAME,
	CREDITHOLD,
	TRANCURRENCY,
	LASTMODIFIEDBY,
	AMOUNTUSDCRED,
	AMOUNTUSDDEB,
	RATEAMOUNT,
	"Rev Rec Rule",
	"Item Type",
	CLOSEDDATE,
	CLEAREDDATE,
	DUEDATE,
	TRANSACTIONLINEID,
	"Payment Date",
	PAYMENTAMOUNT,
	PAYMENTINTERNALID,
	PAYMENTINVOICEINTERNALID,
	PAYMENTINVOICEDATE,
	TOTALLINEAMOUNTUSD,
	AMOUNTREMAINING,
	PRODUCTLINE,
	PRODUCTGROUP,
	PILLAR,
	BUSINESSUNIT,
	SFACCOUNTID,
	SFACCOUNTTYPE,
	SFACCOUNTOWNER,
	DOCUMENTNUMBER,
	EXCHANGERATE
) as 

select 
t.id as TranID, 
t.trandate as TransDate, 
t.type as TranType, 
//tl.item as TranItem, 
i.itemid as ItemName, 
i.custitem_product_family as ItemProductFamily, 
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
tl.rateamount,
rrr.name as "Rev Rec Rule",
i.itemtype as "Item Type",
tl.closedate as ClosedDate,
tl.cleareddate as ClearedDate,
t.duedate as DueDate,
tl.id as TransactionLineID,
rt.payment_date as "Payment Date",
rt.PAYMENT_PAYING_AMOUNT as PaymentAmount,
rt.INTERNAL_ID as PaymentInternalID,
rt.APPLIED_TO_INTERNAL_ID as PaymentInvoiceInternalID,
rt.APPLIED_TO_DATE as PaymentInvoiceDate,
COALESCE(tl.creditforeignamount, 0) * COALESCE(cex.averagerate, 0) - COALESCE(tl.debitforeignamount, 0) * COALESCE(cex.averagerate, 0) AS TotalLineAmountUSD,
COALESCE(rt.applied_to_transaction_amount_remaining, 0) * cex.averagerate AS AmountRemaining,
i.custitem_product_family as  ProductLine,

--#region ProductLine > ProductGroup
case
when i.location = '1' then 'Spreadsheet Server'
when i.location = '2' then 'Spreadsheet Server'
when i.location = '3' then 'Spreadsheet Server'
when i.location = '4' then 'Other Financial Reporting'
when i.location = '5' then 'Spreadsheet Server'
when i.location = '6' then 'Logi'
when i.location = '8' then 'Spreadsheet Server'
when i.location = '9' then 'Spreadsheet Server'
when i.location = '10' then 'Spreadsheet Server'
when i.location = '12' then 'Hubble'
when i.location = '13' then 'Other'
when i.location = '14' then 'Spreadsheet Server'
when i.location = '15' then 'Hubble'
when i.location = '16' then 'Other'
when i.location = '17' then 'Spreadsheet Server'
when i.location = '18' then 'Hubble'
when i.location = '19' then 'Hubble'
when i.location = '20' then 'Wands'
when i.location = '22' then 'Bizview'
when i.location = '23' then 'Hubble'
when i.location = '24' then 'Hubble'
when i.location = '101' then 'Wands'
when i.location = '102' then 'Wands'
when i.location = '104' then 'CXO'
when i.location = '105' then 'Wands'
when i.location = '106' then 'Wands'
when i.location = '107' then 'Hubble'
when i.location = '108' then 'Hubble'
when i.location = '109' then 'Hubble'
when i.location = '110' then 'Hubble'
when i.location = '111' then 'Hubble'
when i.location = '112' then 'Hubble'
when i.location = '113' then 'Hubble'
when i.location = '114' then 'Wands'
when i.location = '115' then 'Hubble'
when i.location = '117' then 'Other Financial Reporting'
when i.location = '118' then 'Jet'
when i.location = '119' then 'Jet'
when i.location = '120' then 'Jet'
when i.location = '121' then 'Spreadsheet Server'
when i.location = '122' then 'Jet'
when i.location = '123' then 'Hubble'
when i.location = '125' then 'Jet'
when i.location = '126' then 'Hubble'
when i.location = '127' then 'Jet'
when i.location = '128' then 'Bizview'
when i.location = '129' then 'Bizview'
when i.location = '130' then 'Bizview'
when i.location = '131' then 'Longview Analytics'
when i.location = '132' then 'Longview Close'
when i.location = '133' then 'Tax'
when i.location = '134' then 'Longview Close'
when i.location = '135' then 'Tidemark'
when i.location = '136' then 'Longview Close'
when i.location = '137' then 'Tax'
when i.location = '138' then 'Tax'
when i.location = '139' then 'Wands'
when i.location = '141' then 'Other Financial Reporting'
when i.location = '142' then 'Other Financial Reporting'
when i.location = '143' then 'Other Financial Reporting'
when i.location = '144' then 'Other Financial Reporting'
when i.location = '145' then 'Spreadsheet Server'
when i.location = '146' then 'Other Financial Reporting'
when i.location = '147' then 'Viareport'
when i.location = '148' then 'Viareport'
when i.location = '149' then 'Equity'
when i.location = '150' then 'Disclosure Management'
when i.location = '151' then 'Disclosure Management'
when i.location = '152' then 'Disclosure Management'
when i.location = '153' then 'Disclosure Management'
when i.location = '154' then 'IDL'
when i.location = '155' then 'IDL'
when i.location = '156' then 'IDL'
when i.location = '157' then 'IDL'
when i.location = '158' then 'IDL'
when i.location = '159' then 'IDL'
when i.location = '160' then 'IDL'
when i.location = '161' then 'IDL'
when i.location = '162' then 'IDL'
when i.location = '163' then 'IDL'
when i.location = '164' then 'IDL'
when i.location = '165' then 'IDL'
when i.location = '167' then 'IDL'
when i.location = '168' then 'IDL'
when i.location = '169' then 'IDL'
when i.location = '171' then 'IDL'
when i.location = '172' then 'IDL'
when i.location = '173' then 'IDL'
when i.location = '174' then 'IDL'
when i.location = '175' then 'IDL'
when i.location = '176' then 'IDL'
when i.location = '254' then 'IDL'
when i.location = '255' then 'IDL'
when i.location = '256' then 'IDL'
when i.location = '257' then 'IDL'
when i.location = '258' then 'IDL'
when i.location = '259' then 'IDL'
when i.location = '260' then 'Calumo'
when i.location = '261' then 'Data Intelligence'
when i.location = '262' then 'Angles'
when i.location = '263' then 'Angles'
when i.location = '265' then 'Other Financial Reporting'
when i.location = '275' then 'Other Financial Reporting'
when i.location = '276' then 'Other Financial Reporting'
when i.location = '277' then 'Other Financial Reporting'
when i.location = '279' then 'Hubble'
when i.location = '280' then 'Hubble'
when i.location = '281' then 'IDL'
when i.location = '282' then 'Jet'
when i.location = '283' then 'Jet'
when i.location = '284' then 'Jet'
when i.location = '285' then 'Data Intelligence'
when i.location = '287' then 'Spreadsheet Server'
when i.location = '289' then 'Operational Reporting'
when i.location = '291' then 'Process Runner'
when i.location = '295' then 'Simba'
when i.location = '297' then 'Spreadsheet Server'
when i.location = '298' then 'Tidemark'
when i.location = '300' then 'Other Financial Reporting'
when i.location = '302' then 'Logi'
when i.location = '303' then 'Logi'
when i.location = '304' then 'Logi'
when i.location = '305' then 'Logi'
when i.location = '306' then 'Logi'
when i.location = '309' then 'Logi'
when i.location = '310' then 'Other Close & Consolidation'
when i.location = '311' then 'Other Close & Consolidation'
when i.location = '312' then 'Other Close & Consolidation'
when i.location = '313' then 'Other Close & Consolidation'
when i.location = '314' then 'Other Close & Consolidation'
when i.location = '315' then 'Other Close & Consolidation'
when i.location = '316' then 'Logi'
when i.location = '317' then 'Other Close & Consolidation'
when i.location = '318' then 'Logi'
when i.location = '319' then 'Tax'
when i.location = '320' then 'Power ON'
when i.location = '321' then 'Angles'
when i.location = '322' then 'Angles'
when i.location = '323' then 'Angles'
when i.location = '324' then 'Other Close & Consolidation'
when i.location = '325' then 'Other Close & Consolidation'
when i.location = '326' then 'Other Close & Consolidation'
when i.location = '327' then 'Process Runner'
when i.location = '328' then 'Process Runner'
when i.location = '329' then 'Process Runner'
when i.location = '330' then 'Process Runner'
when i.location = '331' then 'Simba'
when i.location = '332' then 'Simba'
when i.location = '333' then 'SourceConnect'
when i.location = '334' then 'Power ON'
when i.location = '335' then 'Power ON'
when i.location = '336' then 'Power ON'
when i.location = '337' then 'Angles'
when i.location = '338' then 'Power ON'
when i.location = '339' then 'Power ON'
when i.location = '340' then 'Platform'
when i.location = '341' then 'Angles'
when i.location = '342' then 'Vizlib'
when i.location = '343' then 'Vizlib'
when i.location = '344' then 'Vizlib'
when i.location = '345' then 'Vizlib'
when i.location = '346' then 'Vizlib'
when i.location = '347' then 'Vizlib'




else '' end as ProductGroup,
--#endregion

--#region ProductLine > Pillar
case  
when i.location = '1' then 'Financial Reporting'
when i.location = '2' then 'Financial Reporting'
when i.location = '3' then 'Financial Reporting'
when i.location = '4' then 'Financial Reporting'
when i.location = '5' then 'Financial Reporting'
when i.location = '6' then 'Embedded Analytics & Data Intelligence'
when i.location = '8' then 'Financial Reporting'
when i.location = '9' then 'Financial Reporting'
when i.location = '10' then 'Financial Reporting'
when i.location = '12' then 'Financial Reporting'
when i.location = '13' then 'Financial Reporting'
when i.location = '14' then 'Financial Reporting'
when i.location = '15' then 'Financial Reporting'
when i.location = '16' then 'Financial Reporting'
when i.location = '17' then 'Financial Reporting'
when i.location = '18' then 'Financial Reporting'
when i.location = '19' then 'Financial Reporting'
when i.location = '20' then 'Financial Reporting'
when i.location = '22' then 'Budgeting and Planning'
when i.location = '23' then 'Financial Reporting'
when i.location = '24' then 'Financial Reporting'
when i.location = '101' then 'Financial Reporting'
when i.location = '102' then 'Financial Reporting'
when i.location = '104' then 'Financial Reporting'
when i.location = '105' then 'Financial Reporting'
when i.location = '106' then 'Financial Reporting'
when i.location = '107' then 'Financial Reporting'
when i.location = '108' then 'Financial Reporting'
when i.location = '109' then 'Financial Reporting'
when i.location = '110' then 'Financial Reporting'
when i.location = '111' then 'Financial Reporting'
when i.location = '112' then 'Financial Reporting'
when i.location = '113' then 'Financial Reporting'
when i.location = '114' then 'Financial Reporting'
when i.location = '115' then 'Financial Reporting'
when i.location = '117' then 'Financial Reporting'
when i.location = '118' then 'Financial Reporting'
when i.location = '119' then 'Financial Reporting'
when i.location = '120' then 'Financial Reporting'
when i.location = '121' then 'Financial Reporting'
when i.location = '122' then 'Financial Reporting'
when i.location = '123' then 'Financial Reporting'
when i.location = '125' then 'Financial Reporting'
when i.location = '126' then 'Financial Reporting'
when i.location = '127' then 'Financial Reporting'
when i.location = '128' then 'Budgeting and Planning'
when i.location = '129' then 'Budgeting and Planning'
when i.location = '130' then 'Budgeting and Planning'
when i.location = '131' then 'Operational Reporting'
when i.location = '132' then 'Close and Consolidation'
when i.location = '133' then 'Tax Reporting'
when i.location = '134' then 'Close and Consolidation'
when i.location = '135' then 'Budgeting and Planning'
when i.location = '136' then 'Close and Consolidation'
when i.location = '137' then 'Tax Reporting'
when i.location = '138' then 'Tax Reporting'
when i.location = '139' then 'Financial Reporting'
when i.location = '141' then 'Financial Reporting'
when i.location = '142' then 'Financial Reporting'
when i.location = '143' then 'Financial Reporting'
when i.location = '144' then 'Financial Reporting'
when i.location = '145' then 'Financial Reporting'
when i.location = '146' then 'Financial Reporting'
when i.location = '147' then 'Close and Consolidation'
when i.location = '148' then 'Close and Consolidation'
when i.location = '149' then 'Equity Management'
when i.location = '150' then 'Disclosure Management'
when i.location = '151' then 'Disclosure Management'
when i.location = '152' then 'Disclosure Management'
when i.location = '153' then 'Disclosure Management'
when i.location = '154' then 'Close and Consolidation'
when i.location = '155' then 'Close and Consolidation'
when i.location = '156' then 'Close and Consolidation'
when i.location = '157' then 'Close and Consolidation'
when i.location = '158' then 'Close and Consolidation'
when i.location = '159' then 'Close and Consolidation'
when i.location = '160' then 'Close and Consolidation'
when i.location = '161' then 'Close and Consolidation'
when i.location = '162' then 'Close and Consolidation'
when i.location = '163' then 'Close and Consolidation'
when i.location = '164' then 'Close and Consolidation'
when i.location = '165' then 'Close and Consolidation'
when i.location = '167' then 'Close and Consolidation'
when i.location = '168' then 'Close and Consolidation'
when i.location = '169' then 'Close and Consolidation'
when i.location = '171' then 'Close and Consolidation'
when i.location = '172' then 'Close and Consolidation'
when i.location = '173' then 'Close and Consolidation'
when i.location = '174' then 'Close and Consolidation'
when i.location = '175' then 'Close and Consolidation'
when i.location = '176' then 'Close and Consolidation'
when i.location = '254' then 'Close and Consolidation'
when i.location = '255' then 'Close and Consolidation'
when i.location = '256' then 'Close and Consolidation'
when i.location = '257' then 'Close and Consolidation'
when i.location = '258' then 'Close and Consolidation'
when i.location = '259' then 'Close and Consolidation'
when i.location = '260' then 'Budgeting and Planning'
when i.location = '261' then 'Embedded Analytics & Data Intelligence'
when i.location = '262' then 'Operational Reporting'
when i.location = '263' then 'Operational Reporting'
when i.location = '265' then 'Financial Reporting'
when i.location = '275' then 'Financial Reporting'
when i.location = '276' then 'Financial Reporting'
when i.location = '277' then 'Financial Reporting'
when i.location = '279' then 'Financial Reporting'
when i.location = '280' then 'Financial Reporting'
when i.location = '281' then 'Close and Consolidation'
when i.location = '282' then 'Financial Reporting'
when i.location = '283' then 'Financial Reporting'
when i.location = '284' then 'Financial Reporting'
when i.location = '285' then 'Embedded Analytics & Data Intelligence'
when i.location = '287' then 'Financial Reporting'
when i.location = '289' then 'Operational Reporting'
when i.location = '291' then 'Operational Reporting'
when i.location = '295' then 'Data Integrations'
when i.location = '297' then 'Financial Reporting'
when i.location = '298' then 'Budgeting and Planning'
when i.location = '300' then 'Financial Reporting'
when i.location = '302' then 'Embedded Analytics & Data Intelligence'
when i.location = '303' then 'Embedded Analytics & Data Intelligence'
when i.location = '304' then 'Embedded Analytics & Data Intelligence'
when i.location = '305' then 'Embedded Analytics & Data Intelligence'
when i.location = '306' then 'Embedded Analytics & Data Intelligence'
when i.location = '309' then 'Embedded Analytics & Data Intelligence'
when i.location = '310' then 'Close and Consolidation'
when i.location = '311' then 'Close and Consolidation'
when i.location = '312' then 'Close and Consolidation'
when i.location = '313' then 'Close and Consolidation'
when i.location = '314' then 'Close and Consolidation'
when i.location = '315' then 'Close and Consolidation'
when i.location = '316' then 'Embedded Analytics & Data Intelligence'
when i.location = '317' then 'Close and Consolidation'
when i.location = '318' then 'Embedded Analytics & Data Intelligence'
when i.location = '319' then 'Tax Reporting'
when i.location = '320' then 'Data Integrations'
when i.location = '321' then 'Operational Reporting'
when i.location = '322' then 'Operational Reporting'
when i.location = '323' then 'Operational Reporting'
when i.location = '324' then 'Close and Consolidation'
when i.location = '325' then 'Close and Consolidation'
when i.location = '326' then 'Close and Consolidation'
when i.location = '327' then 'Operational Reporting'
when i.location = '328' then 'Operational Reporting'
when i.location = '329' then 'Operational Reporting'
when i.location = '330' then 'Operational Reporting'
when i.location = '331' then 'Data Integrations'
when i.location = '332' then 'Data Integrations'
when i.location = '333' then 'Data Integrations'
when i.location = '334' then 'Data Integrations'
when i.location = '335' then 'Data Integrations'
when i.location = '336' then 'Data Integrations'
when i.location = '337' then 'Operational Reporting'
when i.location = '338' then 'Data Integrations'
when i.location = '339' then 'Data Integrations'
when i.location = '340' then 'Data Integrations'
when i.location = '341' then 'Operational Reporting'
when i.location = '342' then 'Data Integrations'
when i.location = '343' then 'Data Integrations'
when i.location = '344' then 'Data Integrations'
when i.location = '345' then 'Data Integrations'
when i.location = '346' then 'Data Integrations'
when i.location = '347' then 'Data Integrations'



else '' end as Pillar,
--#endregion

--#region ProductLine > Business Unit
case  

when i.location = '1' then 'FP&A'
when i.location = '2' then 'FP&A'
when i.location = '3' then 'FP&A'
when i.location = '4' then 'FP&A'
when i.location = '5' then 'FP&A'
when i.location = '6' then 'Data & Analytics'
when i.location = '8' then 'FP&A'
when i.location = '9' then 'FP&A'
when i.location = '10' then 'FP&A'
when i.location = '12' then 'FP&A'
when i.location = '13' then 'FP&A'
when i.location = '14' then 'FP&A'
when i.location = '15' then 'FP&A'
when i.location = '16' then 'FP&A'
when i.location = '17' then 'FP&A'
when i.location = '18' then 'FP&A'
when i.location = '19' then 'FP&A'
when i.location = '20' then 'FP&A'
when i.location = '22' then 'FP&A'
when i.location = '23' then 'FP&A'
when i.location = '24' then 'FP&A'
when i.location = '101' then 'FP&A'
when i.location = '102' then 'FP&A'
when i.location = '104' then 'FP&A'
when i.location = '105' then 'FP&A'
when i.location = '106' then 'FP&A'
when i.location = '107' then 'FP&A'
when i.location = '108' then 'FP&A'
when i.location = '109' then 'FP&A'
when i.location = '110' then 'FP&A'
when i.location = '111' then 'FP&A'
when i.location = '112' then 'FP&A'
when i.location = '113' then 'FP&A'
when i.location = '114' then 'FP&A'
when i.location = '115' then 'FP&A'
when i.location = '117' then 'FP&A'
when i.location = '118' then 'FP&A'
when i.location = '119' then 'FP&A'
when i.location = '120' then 'FP&A'
when i.location = '121' then 'FP&A'
when i.location = '122' then 'FP&A'
when i.location = '123' then 'FP&A'
when i.location = '125' then 'FP&A'
when i.location = '126' then 'FP&A'
when i.location = '127' then 'FP&A'
when i.location = '128' then 'FP&A'
when i.location = '129' then 'FP&A'
when i.location = '130' then 'FP&A'
when i.location = '131' then 'FP&A'
when i.location = '132' then 'Controllership'
when i.location = '133' then 'Controllership'
when i.location = '134' then 'Controllership'
when i.location = '135' then 'FP&A'
when i.location = '136' then 'Controllership'
when i.location = '137' then 'Controllership'
when i.location = '138' then 'Controllership'
when i.location = '139' then 'FP&A'
when i.location = '141' then 'FP&A'
when i.location = '142' then 'FP&A'
when i.location = '143' then 'FP&A'
when i.location = '144' then 'FP&A'
when i.location = '145' then 'FP&A'
when i.location = '146' then 'FP&A'
when i.location = '147' then 'Controllership'
when i.location = '148' then 'Controllership'
when i.location = '149' then 'Controllership'
when i.location = '150' then 'Controllership'
when i.location = '151' then 'Controllership'
when i.location = '152' then 'Controllership'
when i.location = '153' then 'Controllership'
when i.location = '154' then 'Controllership'
when i.location = '155' then 'Controllership'
when i.location = '156' then 'Controllership'
when i.location = '157' then 'Controllership'
when i.location = '158' then 'Controllership'
when i.location = '159' then 'Controllership'
when i.location = '160' then 'Controllership'
when i.location = '161' then 'Controllership'
when i.location = '162' then 'Controllership'
when i.location = '163' then 'Controllership'
when i.location = '164' then 'Controllership'
when i.location = '165' then 'Controllership'
when i.location = '167' then 'Controllership'
when i.location = '168' then 'Controllership'
when i.location = '169' then 'Controllership'
when i.location = '171' then 'Controllership'
when i.location = '172' then 'Controllership'
when i.location = '173' then 'Controllership'
when i.location = '174' then 'Controllership'
when i.location = '175' then 'Controllership'
when i.location = '176' then 'Controllership'
when i.location = '254' then 'Controllership'
when i.location = '255' then 'Controllership'
when i.location = '256' then 'Controllership'
when i.location = '257' then 'Controllership'
when i.location = '258' then 'Controllership'
when i.location = '259' then 'Controllership'
when i.location = '260' then 'FP&A'
when i.location = '261' then 'Data & Analytics'
when i.location = '262' then 'FP&A'
when i.location = '263' then 'FP&A'
when i.location = '265' then 'FP&A'
when i.location = '275' then 'FP&A'
when i.location = '276' then 'FP&A'
when i.location = '277' then 'FP&A'
when i.location = '279' then 'FP&A'
when i.location = '280' then 'FP&A'
when i.location = '281' then 'Controllership'
when i.location = '282' then 'FP&A'
when i.location = '283' then 'FP&A'
when i.location = '284' then 'FP&A'
when i.location = '285' then 'Data & Analytics'
when i.location = '287' then 'FP&A'
when i.location = '289' then 'FP&A'
when i.location = '291' then 'FP&A'
when i.location = '295' then 'Data & Analytics'
when i.location = '297' then 'FP&A'
when i.location = '298' then 'FP&A'
when i.location = '300' then 'FP&A'
when i.location = '302' then 'Data & Analytics'
when i.location = '303' then 'Data & Analytics'
when i.location = '304' then 'Data & Analytics'
when i.location = '305' then 'Data & Analytics'
when i.location = '306' then 'Data & Analytics'
when i.location = '309' then 'Data & Analytics'
when i.location = '310' then 'Controllership'
when i.location = '311' then 'Controllership'
when i.location = '312' then 'Controllership'
when i.location = '313' then 'Controllership'
when i.location = '314' then 'Controllership'
when i.location = '315' then 'Controllership'
when i.location = '316' then 'Data & Analytics'
when i.location = '317' then 'Controllership'
when i.location = '318' then 'Data & Analytics'
when i.location = '319' then 'Controllership'
when i.location = '320' then 'Data & Analytics'
when i.location = '321' then 'FP&A'
when i.location = '322' then 'FP&A'
when i.location = '323' then 'FP&A'
when i.location = '324' then 'Controllership'
when i.location = '325' then 'Controllership'
when i.location = '326' then 'Controllership'
when i.location = '327' then 'FP&A'
when i.location = '328' then 'FP&A'
when i.location = '329' then 'FP&A'
when i.location = '330' then 'FP&A'
when i.location = '331' then 'Data & Analytics'
when i.location = '332' then 'Data & Analytics'
when i.location = '333' then 'Data & Analytics'
when i.location = '334' then 'Data & Analytics'
when i.location = '335' then 'Data & Analytics'
when i.location = '336' then 'Data & Analytics'
when i.location = '337' then 'FP&A'
when i.location = '338' then 'Data & Analytics'
when i.location = '339' then 'Data & Analytics'
when i.location = '340' then 'Data & Analytics'
when i.location = '341' then 'FP&A'
when i.location = '342' then 'Data & Analytics'
when i.location = '343' then 'Data & Analytics'
when i.location = '344' then 'Data & Analytics'
when i.location = '345' then 'Data & Analytics'
when i.location = '346' then 'Data & Analytics'
when i.location = '347' then 'Data & Analytics'


else '' end as BusinessUnit,
--#endregion

a.id as SFAccountID,
a.type as SFAccountType,
a.owner_name_c as SFAccountOwner,
t.TRANID as DocumentNumber,
cex.averagerate as ExchangeRate

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
full join SB_ERPTEAM.PUBLIC.TABLE_PAYMENTS_ODBC_USD rt on rt.APPLIED_TO_INTERNAL_ID = t.id
left join INBOUND_RAW.SALESFORCE.ACCOUNT a on a.id = c.externalid


// Pull in consolidated exchange 
// use this to replicate portal

where exists (select 1 from INBOUND_RAW.NETSUITE.TRANSACTIONSTATUS ts2 where ts2.TRANTYPE = 'CustInvc')
and t.type = 'CustInvc' and tl.mainline = 'F' and (tl.creditforeignamount <> 0 or tl.debitforeignamount <> 0)
--#endregion
;
--#endregion


AND(
OR(
ISBLANK(BMI_SF_NS_NetSuiteID__c),
BEGINS(BMI_SF_NS_NetSuiteID__c, "Error")
),
OR(
ISBLANK(NetSuite_Order_ID__c),
BEGINS(NetSuite_Order_ID__c, "Error")
),
OR(
ISBLANK(NetSuite_Integration_Sync_Date_Time__c),
LastModifiedDate > NetSuite_Integration_Sync_Date_Time__c
)
)
&& ActivatedDate > DATETIMEVALUE(DATE(2021,10,07)) && ISPICKVAL(Status, "Activated") && NOT(ISBLANK(Account.BMI_SF_NS__NetSuiteID__c)) && NOT(ISBLANK(Legal_Entity__c)) && ISBLANK(BMI_SF_NS_Sync_Error_Message__c) && NOT(ISBLANK(blng__BillingAccount__r.BMI_SF_NS__NetSuiteID__c )) && (blng__BillingAccount__r.ID <> "0014U00002ygSztQAE") 


/* && ISPICKVAL(Opportunity.StageName , "Closed Won") */