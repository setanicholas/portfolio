CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS (
    RevenuePlanID VARCHAR(240),
    RevenuePlanITEM VARCHAR(240),
    RevenuePlanREVENUEPLANCURRENCY VARCHAR(240),
    RevenuePlanAMOUNT VARCHAR(240),
    RevenuePlanType VARCHAR(240),
    RevenuePlanPlannedRevenueID VARCHAR(240),
    RevenuePlanPlannedRevenueAMOUNT NUMBER(38,2),
    RevenuePlanPlannedRevenuePLANNEDPERIOD VARCHAR(240),
    RevenuePlanPlannedRevenuePOSTINGPERIOD VARCHAR(240),
    RevenuePlanPlannedRevenueJOURNAL VARCHAR(240),
    FromCurrency VARCHAR(240),
    ToCurrency VARCHAR(240),
    -- FromSubsidiary VARCHAR(240),
    -- FromSubsidiaryID VARCHAR(240),
    PeriodName VARCHAR(240),
    PostingPeriodID VARCHAR(240),
    PeriodCurrency VARCHAR(240),
    RevPlanPeriodCurrency VARCHAR(240),
    RevPlanUSD NUMBER(38,2),
    RevPlanForex NUMBER(38,2),
    PlanSub VARCHAR(240),
    AverageRate NUMBER(38,2),
    ItemDisplayName VARCHAR(240),
    ItemType VARCHAR(240),
    ItemIncomeAccount VARCHAR(240),
    CustomerName VARCHAR(240),
    OrderProductName VARCHAR(240),
    OrderProductDealID VARCHAR(240),
    EndUserName VARCHAR(240),
    ItemRevRecRule VARCHAR(240),
    OrderProductID VARCHAR(240),
    PostedAmountUSD NUMBER(38,2),
    PlannedAmountUSD NUMBER(38,2),
    PostedAmountForex NUMBER(38,2),
    PlannedAmountForex NUMBER(38,2),
    NSOrderID VARCHAR(240),
    CustomerID VARCHAR(240),
    EndUserID VARCHAR(240),
    ElementSource VARCHAR(240),
    OrderProductAmount NUMBER(38,2),
    ArrangementBillTo VARCHAR(240),
    ArrangementEndUser VARCHAR(240),
    Subsidiary VARCHAR(240),
    Itemcustitem_product_family VARCHAR(240),
    OrderProductDate VARCHAR(240),
    RevElementCreateRevenuePlansOn VARCHAR(240),
    RevElementSourceRecordType VARCHAR(240),
    ItemDeferralAccount VARCHAR(240),
    RevRecStartDate DATE,
    RevRecEndDate VARCHAR(240),
    RevenueElementID VARCHAR(240),
    ArrangementNumber VARCHAR(240),
    IncomeAccountName VARCHAR(240),
    IncomeAccountType VARCHAR(240),
    ServiceContract VARCHAR(240),
    IsRecognized VARCHAR(240),
    PeriodStartDate DATE,
    APPeriodName VARCHAR(240),
    ServiceContractNumber VARCHAR(240),
    ServiceContractStartDate DATE,
    ServiceContractEndDate DATE,
    SFOrderProductID VARCHAR(240),
    RecordType nvarchar(510),
    ServiceContractARRAmount decimal(16,2),
    ServiceContractId nchar(18),
    AccountName nvarchar(510),
    AccountId nchar(18),
    NetSuiteProductFamily nvarchar(240),
    NetSuiteProductLine nvarchar(240),
    SalesforceProductFamily nvarchar(240),
    SalesforceProductLine nvarchar(240),
    NetSuiteCustomerSFID nvarchar(240),
    SalesforceEndUserID nvarchar(240),
    //ADD | Record Type = X > track new bookings
    OpportunityID nvarchar(240), 
    OpportunityRecordType nvarchar(240),   
    OrderNumber nvarchar(240)
    );
 
INSERT INTO SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS (
    RevenuePlanID,
    RevenuePlanITEM,
    RevenuePlanREVENUEPLANCURRENCY,
    RevenuePlanAMOUNT,
    RevenuePlanType,
    RevenuePlanPlannedRevenueID,
    RevenuePlanPlannedRevenueAMOUNT,
    RevenuePlanPlannedRevenuePLANNEDPERIOD,
    RevenuePlanPlannedRevenuePOSTINGPERIOD,
    RevenuePlanPlannedRevenueJOURNAL,
    FromCurrency,
    ToCurrency,
    -- FromSubsidiary,
    -- FromSubsidiaryID,
    //PeriodName,
    PostingPeriodID,
    PeriodCurrency,
    RevPlanPeriodCurrency,
    RevPlanUSD,
    RevPlanForex,
    PlanSub,
    AverageRate,
    ItemDisplayName,
    ItemType,
    ItemIncomeAccount,
    CustomerName,
    OrderProductName,
    OrderProductDealID,
    EndUserName,
    ItemRevRecRule,
    OrderProductID,
    PostedAmountUSD,
    PlannedAmountUSD,
    PostedAmountForex,
    PlannedAmountForex,
    NSOrderID,
    CustomerID,
    EndUserID,
    ElementSource,
    OrderProductAmount,
    ArrangementBillTo,
    ArrangementEndUser,
    Subsidiary,
    Itemcustitem_product_family,
    OrderProductDate,
    RevElementCreateRevenuePlansOn,
    RevElementSourceRecordType,
    ItemDeferralAccount,
    RevRecStartDate,
    RevRecEndDate,
    RevenueElementID,
    ArrangementNumber,
    IncomeAccountName,
    IncomeAccountType,
    ServiceContract,
    IsRecognized,
    PeriodStartDate,
    APPeriodName,
    ServiceContractNumber,
    ServiceContractStartDate,
    ServiceContractEndDate,
    SFOrderProductID,
    RecordType,
    ServiceContractARRAmount,
    ServiceContractId,
    AccountName,
    AccountId,
    NetSuiteProductFamily,
    NetSuiteProductLine,
    NetSuiteCustomerSFID,
    SalesforceEndUserID,
    OrderNumber)
SELECT DISTINCT 
    rp.ID,
    rp.ITEM,
    rp.REVENUEPLANCURRENCY,
    rp.AMOUNT,
    rp.revenueplantype,
    rppr.ID,
    rppr.AMOUNT,
    rppr.PLANNEDPERIOD,
    rppr.POSTINGPERIOD,
    rppr.JOURNAL,
    -- c.ConsolidatedExchangeRateID,
    -- c.CurencyRate,
    cur.symbol,
    'USD',
    -- c.FromSubsidiary,
    -- c.FromSubsidiaryID,
    -- c.ToSubSidiary,
    '',//c.PostingPeriodID,
    '',//c.PeriodCurrency,
    CONCAT(rppr.PLANNEDPERIOD, rp.REVENUEPLANCURRENCY),
    rppr.AMOUNT * cer.currentrate,
    rppr.AMOUNT,
    re.subsidiary,
    cer.currentrate,
    i.displayname,
    i.itemtype,
    i.incomeaccount,
    cust.companyname,
    op.name,
    op.custrecord_is_cl_sf_deal_id,
    enduser.companyname,
    rrr.name,
    op.id,
    CASE WHEN rppr.JOURNAL IS NOT NULL THEN rppr.AMOUNT * cer.currentrate END,
    CASE WHEN rppr.JOURNAL IS NULL THEN rppr.AMOUNT * cer.currentrate END,
    CASE WHEN rppr.JOURNAL IS NOT NULL THEN rppr.AMOUNT END,
    CASE WHEN rppr.JOURNAL IS NULL THEN rppr.AMOUNT END,
    op.custrecord_is_cl_order,
    cust.id,
    enduser.id,
    re.source,
    op.custrecord_is_cl_price,
    t.entity,
    t.custbody_so_enduser,
    s.name,
    i.custitem_product_family,
    op.custrecord_is_cl_date,
    re.createrevenueplanson,
    re.sourcerecordtype,
    i.deferralaccount,
    re.revrecstartdate,
    re.revrecenddate,
    re.id,
    t.id,
    CASE
        WHEN acc.acctnumber LIKE '401%' THEN 'Maintenance Revenue'
        WHEN acc.acctnumber LIKE '402%' THEN 'Subscription Revenue'
        WHEN acc.acctnumber LIKE '403%' THEN 'License Revenue'
        WHEN acc.acctnumber LIKE '40410%' THEN 'Professional Services Revenue'
        WHEN acc.acctnumber LIKE '40490%' THEN 'Professional Services Revenue'
        WHEN acc.acctnumber LIKE '40420%' THEN 'Recurring Service'
        WHEN acc.acctnumber LIKE '40480%' THEN 'Recurring Service'
        WHEN acc.acctnumber LIKE '405%' THEN 'Hosting Revenue'
        ELSE ''
    END,
    acc.accttype,
    sfop.sbqqsc_service_contract_c,
    rppr.isrecognized,
ap.startdate,
ap.PeriodName,
sfsc.contract_number,
sfsc.start_date,
sfsc.end_date,
sfop.id,
'Revenue Plan Linked to Service Contract',
sfsc.net_arr_c,
sfsc.id,
cust.CompanyName as AccountName,
a.Id as AccountId,
CASE 
 WHEN i.custitem_product_family = '46' THEN 'Agility'
 WHEN i.custitem_product_family = '42' THEN 'Angles'
 WHEN i.custitem_product_family = '68' THEN 'Angles For Oracle'
 WHEN i.custitem_product_family = '69' THEN 'Angles for SAP'
 WHEN i.custitem_product_family = '75' THEN 'Angles MidMarket'
 WHEN i.custitem_product_family = '74' THEN 'Angles Professional'
 WHEN i.custitem_product_family = '4' THEN 'Atlas'
 WHEN i.custitem_product_family = '50' THEN 'BizInsight'
 WHEN i.custitem_product_family = '11' THEN 'Biznet'
 WHEN i.custitem_product_family = '13' THEN 'Bizview'
 WHEN i.custitem_product_family = '38' THEN 'CALUMO'
 WHEN i.custitem_product_family = '26' THEN 'Certent Disclosure Management'
 WHEN i.custitem_product_family = '51' THEN 'Certent Disclosure Management'
 WHEN i.custitem_product_family = '25' THEN 'Certent Equity Management'
 WHEN i.custitem_product_family = '63' THEN 'Clausion'
 WHEN i.custitem_product_family = '27' THEN 'Corporate'
 WHEN i.custitem_product_family = '67' THEN 'Cubeware'
 WHEN i.custitem_product_family = '8' THEN 'CXO'
 WHEN i.custitem_product_family = '3' THEN 'DecisionPoint'
 WHEN i.custitem_product_family = '62' THEN 'Dundas'
 WHEN i.custitem_product_family = '22' THEN 'Event1'
 WHEN i.custitem_product_family = '41' THEN 'Exago'
 WHEN i.custitem_product_family = '7' THEN 'Excel4Apps'
 WHEN i.custitem_product_family = '64' THEN 'FastPost'
 WHEN i.custitem_product_family = '2' THEN 'Global'
 WHEN i.custitem_product_family = '1' THEN 'Hubble'
 WHEN i.custitem_product_family = '28' THEN 'IDL'
 WHEN i.custitem_product_family = '29' THEN 'IDL 3RD Party'
 WHEN i.custitem_product_family = '37' THEN 'IDL Bundle'
 WHEN i.custitem_product_family = '36' THEN 'IDL Designer'
 WHEN i.custitem_product_family = '31' THEN 'IDL Disclosure Management'
 WHEN i.custitem_product_family = '32' THEN 'IDL Forecast'
 WHEN i.custitem_product_family = '30' THEN 'IDL Konsis'
 WHEN i.custitem_product_family = '33' THEN 'IDL Konsis'
 WHEN i.custitem_product_family = '34' THEN 'IDL PIT AG'
 WHEN i.custitem_product_family = '52' THEN 'IDL Third Party'
 WHEN i.custitem_product_family = '14' THEN 'Insight'
 WHEN i.custitem_product_family = '10' THEN 'Intellicast'
 WHEN i.custitem_product_family = '5' THEN 'iSuite'
 WHEN i.custitem_product_family = '40' THEN 'Izenda'
 WHEN i.custitem_product_family = '12' THEN 'Jet'
 WHEN i.custitem_product_family = '47' THEN 'Kalido'
 WHEN i.custitem_product_family = '35' THEN 'Legacy'
 WHEN i.custitem_product_family = '53' THEN 'Legacy Accounting'
 WHEN i.custitem_product_family = '6' THEN 'Legacy Accounting Module'
 WHEN i.custitem_product_family = '61' THEN 'Legerity'
 WHEN i.custitem_product_family = '59' THEN 'Logi Analytics'
 WHEN i.custitem_product_family = '71' THEN 'Logi Composer'
 WHEN i.custitem_product_family = '72' THEN 'Logi Info'
 WHEN i.custitem_product_family = '73' THEN 'Logi Report'
 WHEN i.custitem_product_family = '39' THEN 'Logi Symphony'
 WHEN i.custitem_product_family = '15' THEN 'Longview Analytics'
 WHEN i.custitem_product_family = '16' THEN 'Longview Close'
 WHEN i.custitem_product_family = '17' THEN 'Longview Hosting'
 WHEN i.custitem_product_family = '18' THEN 'Longview Integration Suite'
 WHEN i.custitem_product_family = '19' THEN 'Longview Plan'
 WHEN i.custitem_product_family = '20' THEN 'Longview Tax'
 WHEN i.custitem_product_family = '21' THEN 'Longview Tidemark'
 WHEN i.custitem_product_family = '48' THEN 'Magnitude'
 WHEN i.custitem_product_family = '23' THEN 'Mekko Graphics'
 WHEN i.custitem_product_family = '49' THEN 'New Amsterdam Parent Software, LLC'
 WHEN i.custitem_product_family = '54' THEN 'Operational Reporting'
 WHEN i.custitem_product_family = '76' THEN 'Platform'
 WHEN i.custitem_product_family = '70' THEN 'PowerON'
 WHEN i.custitem_product_family = '43' THEN 'Process Runner'
 WHEN i.custitem_product_family = '45' THEN 'Simba'
 WHEN i.custitem_product_family = '44' THEN 'SourceConnect'
 WHEN i.custitem_product_family = '55' THEN 'Spreadsheet Server'
 WHEN i.custitem_product_family = '66' THEN 'Tabella'
 WHEN i.custitem_product_family = '56' THEN 'Tidemark'
 WHEN i.custitem_product_family = '24' THEN 'Viareport'
 WHEN i.custitem_product_family = '77' THEN 'Vizlib'
 WHEN i.custitem_product_family = '9' THEN 'Wands'
 WHEN i.custitem_product_family = '57' THEN 'Wands for Oracle'
 WHEN i.custitem_product_family = '58' THEN 'Wands for SAP'
ELSE ''
END
,
CASE 
 WHEN i.location  = '1' THEN 'Accounts Payable'
 WHEN i.location  = '2' THEN 'Accounts Receivable'
 WHEN i.location  = '3' THEN 'Analyst'
 WHEN i.location  = '4' THEN 'Atlas'
 WHEN i.location  = '5' THEN 'Budget Accelerator'
 WHEN i.location  = '6' THEN 'Consulting'
 WHEN i.location  = '7' THEN 'DecisionPoint'
 WHEN i.location  = '8' THEN 'Fee'
 WHEN i.location  = '9' THEN 'Fixed Asset'
 WHEN i.location  = '10' THEN 'General Ledger'
 WHEN i.location  = '11' THEN 'iSuite-Other'
 WHEN i.location  = '12' THEN 'Maintenance'
 WHEN i.location  = '13' THEN 'Other'
 WHEN i.location  = '14' THEN 'Purchasing'
 WHEN i.location  = '15' THEN 'Reporting Desktop'
 WHEN i.location  = '16' THEN 'SheetRight'
 WHEN i.location  = '17' THEN 'Spreadsheet Server'
 WHEN i.location  = '18' THEN 'Suite'
 WHEN i.location  = '19' THEN 'Suite Reporting'
 WHEN i.location  = '20' THEN 'TBD'
 WHEN i.location  = '22' THEN 'Training'
 WHEN i.location  = '23' THEN 'Web Reporting'
 WHEN i.location  = '24' THEN 'Writeback'
 WHEN i.location  = '101' THEN 'E4A-Oracle Software'
 WHEN i.location  = '102' THEN 'E4A-SAP Software'
 WHEN i.location  = '103' THEN 'E4A-PeopleSoft Software'
 WHEN i.location  = '104' THEN 'CXO'
 WHEN i.location  = '105' THEN 'Wands for Oracle'
 WHEN i.location  = '106' THEN 'Wands for SAP'
 WHEN i.location  = '107' THEN 'Accelerator'
 WHEN i.location  = '108' THEN 'Advanced Distributions'
 WHEN i.location  = '109' THEN 'Intellicast'
 WHEN i.location  = '110' THEN 'Desktop'
 WHEN i.location  = '111' THEN 'Planning'
 WHEN i.location  = '112' THEN 'QSoftware'
 WHEN i.location  = '113' THEN 'Scheduler'
 WHEN i.location  = '114' THEN 'Wands for Peoplesoft'
 WHEN i.location  = '115' THEN 'Web'
 WHEN i.location  = '117' THEN 'Biznet'
 WHEN i.location  = '118' THEN 'Analytics'
 WHEN i.location  = '119' THEN 'Reports'
 WHEN i.location  = '120' THEN 'Budgets'
 WHEN i.location  = '121' THEN 'Legacy'
 WHEN i.location  = '122' THEN 'Jet'
 WHEN i.location  = '123' THEN 'Insight'
 WHEN i.location  = '124' THEN 'ORA'
 WHEN i.location  = '125' THEN 'Software'
 WHEN i.location  = '126' THEN 'Hubble Enterprise'
 WHEN i.location  = '127' THEN 'Jet Basics'
 WHEN i.location  = '128' THEN 'Bizview Planning'
 WHEN i.location  = '129' THEN 'Bizview Traditional'
 WHEN i.location  = '130' THEN 'Bizview Legacy'
 WHEN i.location  = '131' THEN 'Longview Analytics'
 WHEN i.location  = '132' THEN 'Longview Close'
 WHEN i.location  = '133' THEN 'Longview Hosting'
 WHEN i.location  = '134' THEN 'Longview Integration Suite'
 WHEN i.location  = '135' THEN 'Longview Tidemark'
 WHEN i.location  = '136' THEN 'Longview Plan'
 WHEN i.location  = '137' THEN 'Longview Provision'
 WHEN i.location  = '138' THEN 'Longview Transfer Pricing'
 WHEN i.location  = '139' THEN 'Wands for Oracle ERP Cloud'
 WHEN i.location  = '141' THEN 'Office Connector'
 WHEN i.location  = '142' THEN 'Liberty Reports'
 WHEN i.location  = '143' THEN 'Integrator'
 WHEN i.location  = '144' THEN 'Forecast'
 WHEN i.location  = '145' THEN 'Buyout'
 WHEN i.location  = '146' THEN 'Mekko Graphics'
 WHEN i.location  = '147' THEN 'Viareport Conso & Report'
 WHEN i.location  = '148' THEN 'Viareport Lease'
 WHEN i.location  = '149' THEN 'Certent Equity Management'
 WHEN i.location  = '150' THEN 'Certent Dnet'
 WHEN i.location  = '151' THEN 'Certent DM'
 WHEN i.location  = '152' THEN 'Certent CDM'
 WHEN i.location  = '153' THEN 'Certent Clarity C7'
 WHEN i.location  = '154' THEN 'IDL'
 WHEN i.location  = '155' THEN 'IDL 3rd Party'
 WHEN i.location  = '156' THEN 'IDL ACP'
 WHEN i.location  = '157' THEN 'IDL Azure'
 WHEN i.location  = '158' THEN 'IDL Cockpit'
 WHEN i.location  = '159' THEN 'IDL DeltaMaster'
 WHEN i.location  = '160' THEN 'IDL Designer'
 WHEN i.location  = '161' THEN 'IDL ESEF'
 WHEN i.location  = '162' THEN 'IDL FinRep'
 WHEN i.location  = '163' THEN 'IDL Forecast'
 WHEN i.location  = '164' THEN 'IDL Konsis'
 WHEN i.location  = '165' THEN 'IDL MS SQL'
 WHEN i.location  = '166' THEN 'IDL OEM'
 WHEN i.location  = '167' THEN 'IDL PIT'
 WHEN i.location  = '168' THEN 'IDL Publisher'
 WHEN i.location  = '169' THEN 'IDL ReportFactory'
 WHEN i.location  = '170' THEN 'IDL Report Factory'
 WHEN i.location  = '171' THEN 'IDL SmartConnect'
 WHEN i.location  = '172' THEN 'IDL Smart Connectivity'
 WHEN i.location  = '173' THEN 'IDL TM1'
 WHEN i.location  = '174' THEN 'IDL Training'
 WHEN i.location  = '175' THEN 'IDL XLSLink'
 WHEN i.location  = '176' THEN 'IDL XLS Link'
 WHEN i.location  = '254' THEN 'IDL Cash-In'
 WHEN i.location  = '255' THEN 'IDL eGecko'
 WHEN i.location  = '256' THEN 'IDL Schilling Finanz'
 WHEN i.location  = '257' THEN 'IDL CbCR'
 WHEN i.location  = '258' THEN 'IDL Dimman'
 WHEN i.location  = '259' THEN 'IDL Contract Manager'
 WHEN i.location  = '260' THEN 'CALUMO'
 WHEN i.location  = '261' THEN 'Agility'
 WHEN i.location  = '262' THEN 'Angles'
 WHEN i.location  = '263' THEN 'Angles for SAP'
 WHEN i.location  = '264' THEN 'Azure'
 WHEN i.location  = '265' THEN 'BizInsight'
 WHEN i.location  = '266' THEN 'Cash-In'
 WHEN i.location  = '267' THEN 'CbCR'
 WHEN i.location  = '268' THEN 'Cockpit'
 WHEN i.location  = '269' THEN 'Contract Manager'
 WHEN i.location  = '270' THEN 'DeltaMaster'
 WHEN i.location  = '271' THEN 'Designer'
 WHEN i.location  = '272' THEN 'Dimman'
 WHEN i.location  = '273' THEN 'eGecko'
 WHEN i.location  = '274' THEN 'ESEF'
 WHEN i.location  = '275' THEN 'Event1 Buyout'
 WHEN i.location  = '276' THEN 'Event1 Forecast'
 WHEN i.location  = '277' THEN 'Event1 Integrator'
 WHEN i.location  = '278' THEN 'FinRep'
 WHEN i.location  = '279' THEN 'Hubble Desktop'
 WHEN i.location  = '280' THEN 'Hubble Suite'
 WHEN i.location  = '281' THEN 'IDL Third Party'
 WHEN i.location  = '282' THEN 'Jet Analytics'
 WHEN i.location  = '283' THEN 'Jet Budgets'
 WHEN i.location  = '284' THEN 'Jet Reports'
 WHEN i.location  = '285' THEN 'Kalido'
 WHEN i.location  = '286' THEN 'Konsis'
 WHEN i.location  = '287' THEN 'Legacy Accounting'
 WHEN i.location  = '288' THEN 'MS SQL'
 WHEN i.location  = '289' THEN 'Operational Reporting'
 WHEN i.location  = '290' THEN 'PIT'
 WHEN i.location  = '291' THEN 'Process Runner'
 WHEN i.location  = '292' THEN 'Publisher'
 WHEN i.location  = '293' THEN 'ReportFactory'
 WHEN i.location  = '294' THEN 'Schilling Franz'
 WHEN i.location  = '295' THEN 'Simba'
 WHEN i.location  = '296' THEN 'SmartConnect'
 WHEN i.location  = '297' THEN 'Spreadsheet Analyst'
 WHEN i.location  = '298' THEN 'Tidemark'
 WHEN i.location  = '299' THEN 'TM1'
 WHEN i.location  = '300' THEN 'XL Connect'
 WHEN i.location  = '301' THEN 'XLSLink'
 WHEN i.location  = '302' THEN 'Exago'
 WHEN i.location  = '303' THEN 'Izenda'
 WHEN i.location  = '304' THEN 'Logi Composer'
 WHEN i.location  = '305' THEN 'Logi Info'
 WHEN i.location  = '306' THEN 'Logi Report'
 WHEN i.location  = '308' THEN 'Angles for Mid-Market'
 WHEN i.location  = '309' THEN 'Logi Analytics'
 WHEN i.location  = '310' THEN 'FastPost'
 WHEN i.location  = '311' THEN 'Clausion Financial Consolidation'
 WHEN i.location  = '312' THEN 'Clausion Business Planning'
 WHEN i.location  = '313' THEN 'Tabella Financial Consolidation'
 WHEN i.location  = '314' THEN 'Tabella Planning'
 WHEN i.location  = '315' THEN 'FastPost Express'
 WHEN i.location  = '316' THEN 'Dundas'
 WHEN i.location  = '317' THEN 'Cubeware'
 WHEN i.location  = '318' THEN 'Logi Symphony'
 WHEN i.location  = '319' THEN 'Longview Tax'
 WHEN i.location  = '320' THEN 'Power On'
 WHEN i.location  = '321' THEN 'Angles for Oracle-Analytics'
 WHEN i.location  = '322' THEN 'Angles for Oracle-Rapid Decisions'
 WHEN i.location  = '323' THEN 'Angles for Oracle-Views'
 WHEN i.location  = '324' THEN 'Cubeware Importer White Label'
 WHEN i.location  = '325' THEN 'Cubeware Third Party'
 WHEN i.location  = '326' THEN 'Cubeware-CW1'
 WHEN i.location  = '327' THEN 'Process Runner DB'
 WHEN i.location  = '328' THEN 'Process Runner Easy Workflow'
 WHEN i.location  = '329' THEN 'Process Runner GLSU'
 WHEN i.location  = '330' THEN 'Process Runner Innowera'
 WHEN i.location  = '331' THEN 'Simba Connectors'
 WHEN i.location  = '332' THEN 'Simba SDK'
 WHEN i.location  = '333' THEN 'SourceConnect'
 WHEN i.location  = '334' THEN 'Visual Planner'
 WHEN i.location  = '335' THEN 'Power Update'
 WHEN i.location  = '336' THEN 'Power Planner'
 WHEN i.location  = '337' THEN 'Angles Professional'
 WHEN i.location  = '338' THEN 'Visual Planner+'
 WHEN i.location  = '339' THEN 'XL Table'
 WHEN i.location  = '340' THEN 'Platform'
 WHEN i.location  = '341' THEN 'Angles for Oracle-Legacy BI'
ELSE ''
END,
cust.externalid,
sfo.account_id,
sfo.Order_Number


from INBOUND_RAW.NETSUITE.REVENUEPLAN rp
join INBOUND_RAW.NETSUITE.REVENUEPLANPLANNEDREVENUE rppr on rppr.revenueplan = rp.id
join INBOUND_RAW.NETSUITE.REVENUEELEMENT re on re.id = rp.createdfrom
left join inbound_raw.netsuite.currency cur ON cur.symbol = rp.revenueplancurrency
 
left join INBOUND_RAW.NETSUITE.CONSOLIDATEDEXCHANGERATE cer ON cer.fromcurrency = cur.id AND cer.postingperiod = rppr.PlannedPeriod AND cer.fromsubsidiary = re.subsidiary AND cer.tosubsidiary = 1 AND cer.accountingbook = 1 

//join SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD c on c.periodcurrency = concat(rppr.PLANNEDPERIOD,rp.REVENUEPLANCURRENCY)
join INBOUND_RAW.NETSUITE.TRANSACTION t on t.id = re.revenuearrangement
join INBOUND_RAW.NETSUITE.ITEM i on i.id = rp.ITEM
left join INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op on op.name = re.source
left join INBOUND_RAW.NETSUITE.CUSTOMER cust on cust.id = t.entity
left join INBOUND_RAW.NETSUITE.CUSTOMER enduser on enduser.id = t.custbody_so_enduser
join INBOUND_RAW.NETSUITE.REVENUERECOGNITIONRULE rrr on rrr.id = i.revenuerecognitionrule
join INBOUND_RAW.NETSUITE.SUBSIDIARY s on s.id = re.subsidiary
join INBOUND_RAW.NETSUITE.ACCOUNT acc on acc.id = i.incomeaccount
left join INBOUND_RAW.SALESFORCE.ORDER_ITEM sfop on sfop.id = op.externalid
left join INBOUND_RAW.SALESFORCE."ORDER" sfo on sfo.id = sfop.order_id

left join INBOUND_RAW.SALESFORCE.SERVICE_CONTRACT sfsc on sfsc.id = sfop.sbqqsc_service_contract_c
//left join INBOUND_RAW.SALESFORCE.CONTRACT_LINE_ITEM sfscl on sfslc.ServiceContract = sfsc.id
join INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD ap on ap.id = rppr.plannedperiod
left join INBOUND_RAW.SALESFORCE.ACCOUNT a on a.Id = sfsc.account_id
//left join INBOUND_RAW.SALESFORCE.ACCOUNT ae on ae.Id = sfsc.account_id
where
//i.displayname = 'JET-MNT-RPT-REPORTSMNT' and 
rppr.AMOUNT <> 0 

//and  
    --  (year(sfsc.end_date) = 2023
    --   or year(sfsc.start_date) = 2023
    --   or (year(sfsc.start_date) <= 2023 and year(sfsc.end_date) >= 2023))

      and
rp.revenueplantype = 'ACTUAL' and 
(i.itemtype = 'Service' or i.itemtype = 'NonInvtPart')

;
 



select distinct top 10000
* from SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS 
//where revenueplanid = '3074521'


/* 




--MP: Service contracts that are not linked to a Revenue Plan through the first join
insert into SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS(
    ServiceContractNumber,
    ServiceContractStartDate,
    ServiceContractEndDate,
    SFOrderProductID,
    RecordType,
    ServiceContractARRAmount,
    ServiceContractId,
    Subsidiary,
    AccountName,
    AccountId,
    PeriodStartDate,
    PostedAmountForex,
    SalesforceProductFamily,
    SalesforceProductLine
    // PostedAmountUSD
    )
select distinct sfsc.contract_number,
        sfsc.start_date,
        sfsc.end_date,
        sfop.order_id,
        'Service Contract Not Linked to Revenue Plan',
        sfsc.net_arr_c,
        sfsc.id,
        l.name,
        a.Name,
        a.Id,
        sfsc.start_date,
        sfsc.net_arr_c,
        p.family_c,
        p.product_line_c
        //sfsc.net_arr_c * AverageRate
  from INBOUND_RAW.SALESFORCE.SERVICE_CONTRACT sfsc
   left join INBOUND_RAW.SALESFORCE.ORDER_ITEM sfop on sfsc.id = sfop.sbqqsc_service_contract_c
   left join INBOUND_RAW.SALESFORCE.blng_legal_entity_c l on l.Id = sfop.legal_entity_c
   left join INBOUND_RAW.SALESFORCE.ACCOUNT a on a.Id = sfsc.account_id
   left join INBOUND_RAW.SALESFORCE.ACCOUNT ae on ae.Id = sfsc.account_id
   left join INBOUND_RAW.SALESFORCE.PRODUCT_2 p on p.id = sfop.product_2_id
   //LEFT JOIN SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD usd ON CONCAT(usd.fromcurrency, usd.PERIODSTARTDATE) = CONCAT(o.Currency_Iso_Code, DATE_TRUNC('MONTH', o.created_date)::DATE)

--    where (year(sfsc.end_date) = 2023
--       or year(sfsc.start_date) = 2023
--       or (year(sfsc.start_date) <= 2023 and year(sfsc.end_date) >= 2023))
--      and not exists (select 1 from SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS s
                    --   where sfsc.id = s.SERVICECONTRACTID)
                    ;
 
--select TOP 1000 MEMO from INBOUND_RAW.NETSUITE.TRANSACTION WHERE type = 'Journal' --jOURNAL
UPDATE SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS
SET RecordType = 'Service Contract Not Linked to Revenue Plan'
WHERE ServiceContractId IS NULL;

//where CustomerName = 'W. L. Gore Associates, Inc'
  --where RECORDTYPE = 'Service Contract Not Linked to Revenue Plan';
 
/*
select PERIODSTARTDATE, ServiceContractStartDate,
    ServiceContractEndDate, * from SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS
   where recordtype = 'Service Contract Not Linked to Revenue Plan'
    union
  select top 1 PERIODSTARTDATE, ServiceContractStartDate,
    ServiceContractEndDate, * from SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS
   where recordtype <> 'Service Contract Not Linked to Revenue Plan'
*/
  --select count(1) from SB_ERPTEAM.PUBLIC.REVPLAN_SERVICECONTACTS


/* 
- Another query - first query > full joins on service contract > then rev plan linked to service contract > then rev plan not linked to service contract | copy first and second insert | change to rev with no service contract
- Find criteria and add
- To assemble scenarios will be one by one
    - How to mark each scenario
        - Everything linked to SC > everything not linked
- How long will this whole shin dig take?
    - Based on what we're looking at now

- Identify cash sales?? > salesforce?
*/

AND(ISBLANK(BMI_SF_NS_NetSuiteID__c), 
blng__TotalAmount__c > 0, 
blng__InvoicePostedDate__c >= DATEVALUE("2021-10-08"), 
ISBLANK(BMI_SF_NS_Sync_Error_Message__c), 
NOT(ISBLANK(blng__Order__r.blng__BillingAccount__c)), 
blng__Account__r.of_Invoice_Delivery_Contacts__c > 0,
ISPICKVAL(blng__InvoiceStatus__c, "Posted")),

OR(

AND(
ISBLANK(BMI_SF_NS_NetSuiteID__c),
blng__TotalAmount__c > 0, 
CreatedDate >= DATEVALUE("2021-10-08"),
ISBLANK(BMI_SF_NS_Sync_Error_Message__c), 
NOT(ISBLANK(blng__Order__r.blng__BillingAccount__c)), 
blng__Account__r.of_Invoice_Delivery_Contacts__c > 0,
ISPICKVAL(blng__InvoiceStatus__c, "Rebilled")))