
/* 

ENHANCEMENTS

- Join to the salesforce credit rather than the NS credit
- Add Order and Plan number
- MIN / MAX Date to prevent dups
- DUPLICATE DUE TO TRANTYPE

*/


CREATE OR REPLACE PROCEDURE SB_ERPTEAM.PUBLIC.USP_T_REVPLANVIEW()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

    -- Create or replace the main table for revenue plan view
    CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_REVPLANVIEW_MAIN AS

    SELECT DISTINCT
        rp.ID AS RevenuePlanID, -- Revenue plan ID
        rp.ITEM AS RevenuePlanITEM, -- Item associated with the revenue plan
        rp.REVENUEPLANCURRENCY AS RevenuePlanREVENUEPLANCURRENCY, -- Currency of the revenue plan
        rp.AMOUNT AS RevenuePlanAMOUNT, -- Amount of the revenue plan
        rp.revenueplantype AS RevenuePlanType, -- Type of the revenue plan
        rppr.ID AS RevenuePlanPlannedRevenueID, -- Planned revenue ID
        rppr.PLANNEDPERIOD AS RevenuePlanPlannedRevenuePLANNEDPERIOD, -- Planned period for revenue
        rppr.POSTINGPERIOD AS RevenuePlanPlannedRevenuePOSTINGPERIOD, -- Posting period for revenue
        rppr.JOURNAL AS RevenuePlanPlannedRevenueJOURNAL, -- Journal associated with the planned revenue
        cer.currentrate AS CurrencyRate, -- Current exchange rate
        cer.FromCurrency AS FromCurrency, -- Original currency
        cer.ToCurrency AS ToCurrency, -- Target currency
        CONCAT(rppr.PLANNEDPERIOD, rp.REVENUEPLANCURRENCY) AS RevPlanPeriodCurrency, -- Concatenated planned period and currency
        rppr.AMOUNT * cer.currentrate AS RevPlanUSD, -- Revenue plan amount in USD
        rppr.amount AS RevPlanForex, -- Foreign exchange amount
        re.subsidiary AS PlanSub, -- Subsidiary associated with the plan
        i.displayname AS ItemDisplayName, -- Display name of the item
        i.itemtype AS ItemType, -- Type of the item
        acc.acctnumber AS ItemIncomeAccount, -- Income account for the item
        CONCAT(cust.entityid, ' ', cust.companyname) AS CustomerName, -- Customer name
        op.name AS OrderProductName, -- Name of the order product
        op.custrecord_is_cl_sf_deal_id AS OrderProductDealID, -- Deal ID associated with the order product
        enduser.companyname AS EndUserName, -- End user name
        rrr.name AS ItemRevRecRule, -- Revenue recognition rule for the item
        op.id AS OrderProductID, -- Order product ID
        op.custrecord_is_cl_order AS NSOrderID, -- NetSuite order ID
        cust.id AS CustomerID, -- Customer ID
        enduser.id AS EndUserID, -- End user ID
        re.source AS ElementSource, -- Source of the revenue element
        op.custrecord_is_cl_price AS OrderProductAmount, -- Amount for the order product
        t.entity AS ArrangementBillTo, -- Billing entity for the arrangement
        t.custbody_so_enduser AS ArrangementEndUser, -- End user for the arrangement
        s.name AS Subsidiary, -- Name of the subsidiary
        i.custitem_product_family AS ItemProductFamily, -- Product family for the item
        op.custrecord_is_cl_date AS OrderProductDate, -- Date of the order product
        re.createrevenueplanson AS RevElementCreateRevenuePlansOn, -- Create revenue plans on date
        re.sourcerecordtype AS RevElementSourceRecordType, -- Source record type for the revenue element
        def.fullname AS ItemDeferredRevAccount, -- Deferred revenue account for the item
        re.revrecstartdate AS RevRecStartDate, -- Revenue recognition start date
        re.revrecenddate AS RevRecEndDate, -- Revenue recognition end date
        re.id AS RevenueElementID, -- Revenue element ID
        t.id AS ArrangementNumber, -- Arrangement number
        CASE 
            WHEN acc.acctnumber LIKE '401%' THEN 'Maintenance Revenue' -- Classify account as Maintenance Revenue
            WHEN acc.acctnumber LIKE '402%' THEN 'Subscription Revenue' -- Classify account as Subscription Revenue
            WHEN acc.acctnumber LIKE '403%' THEN 'License Revenue' -- Classify account as License Revenue
            WHEN acc.acctnumber LIKE '40410%' THEN 'Professional Services Revenue' -- Classify account as Professional Services Revenue
            WHEN acc.acctnumber LIKE '40490%' THEN 'Professional Services Revenue' -- Classify account as Professional Services Revenue
            WHEN acc.acctnumber LIKE '40420%' THEN 'Recurring Service' -- Classify account as Recurring Service
            WHEN acc.acctnumber LIKE '40480%' THEN 'Recurring Service' -- Classify account as Recurring Service
            WHEN acc.acctnumber LIKE '405%' THEN 'Hosting Revenue' -- Classify account as Hosting Revenue
            WHEN acc.acctnumber LIKE '409%' THEN 'Other Revenue' -- Classify account as Other Revenue
            WHEN acc.acctnumber LIKE '409%' THEN 'Other Revenue' -- COGs Account
            ELSE acc.accountsearchdisplayname -- Use account search display name if no match
        END AS IncomeAccountName, -- Name of the income account
        acc.accttype AS IncomeAccountType, -- Type of the income account
        sfop.sbqqsc_service_contract_c AS ServiceContract, -- Service contract associated with the Salesforce order product
        rppr.isrecognized AS IsRecognized, -- Whether the revenue is recognized
        ap.PeriodName AS PostingPeriodName, -- Name of the posting period
        ap.startdate AS PostingPeriodStartDate, -- Start date of the posting period
        sfsc.contract_number AS ServiceContractNumber, -- Number of the service contract
        sfsc.start_date AS ServiceContractStartDate, -- Start date of the service contract
        sfsc.end_date AS ServiceContractEndDate, -- End date of the service contract
        sfop.id AS SalesforceOrderProductID, -- Salesforce order product ID
        CASE 
            WHEN rppr.JOURNAL IS NULL THEN 'Planned' -- Mark as Planned if no journal
            ELSE 'Posted' -- Mark as Posted if journal exists
        END AS PlanStatus, -- Status of the plan
        p.entityid AS ProjectName, -- Project name
        sq.NoMatchTransactionCount AS OPTransactionCount, -- Number of unmatched transactions for the order product
        cust.entityid AS CustomerEntityID, -- Customer entity ID
        CONCAT(re.subsidiary, CONCAT(rppr.PLANNEDPERIOD, rp.REVENUEPLANCURRENCY)) AS SubPeriodCurrency, -- Concatenated subsidiary, planned period, and currency
        rp.parentlinecurrency AS RevPlanParentLineCurrency, -- Parent line currency for the revenue plan
        t.trandate AS TranDate, -- Transaction date
        rppr.AMOUNT AS RevenuePlanPlannedRevenueAMOUNT, -- Amount of planned revenue
        CONCAT(YEAR(ap.startdate), '-', LPAD(MONTH(ap.startdate), 2, '0')) AS PeriodYearMonth, -- Year and month of the period
        rp.statusfordisplay AS PlanStatusForDisplay, -- Display status for the plan
        cer.currentrate AS CurrencyExchangeRate, -- Currency exchange rate
        CASE 
            WHEN sq.TranType = 'CustCred' OR sq.RevRecEndDate IS NOT NULL OR rppr.amount < 0 THEN 1 -- Mark as TranDummy if condition is met
            ELSE 0  
        END AS TranDummy, -- Transaction dummy indicator
        sq.TranType AS TranType, -- Type of the transaction
        op.custrecord_isw_revised_order_product AS RevisedOrderProduct, -- Revised order product indicator
        i.itemid, -- Item ID
        op.externalid AS OPExternalID, -- External ID for the order product
        MIN(sq.RevRecStartDate) OVER (PARTITION BY rppr.ID) AS FirstStartDate, -- First revenue recognition start date
        MAX(sq.RevRecEndDate) OVER (PARTITION BY rppr.ID) AS LastEndDate, -- Last revenue recognition end date
        t.tranid AS ArrangementDocNumber -- Arrangement document number

    FROM INBOUND_RAW.NETSUITE.REVENUEPLAN rp
    LEFT JOIN INBOUND_RAW.NETSUITE.REVENUEPLANPLANNEDREVENUE rppr ON rppr.revenueplan = rp.id -- Join with planned revenue
    LEFT JOIN INBOUND_RAW.NETSUITE.REVENUEELEMENT re ON re.id = rp.createdfrom -- Join with revenue element
    LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION t ON t.id = re.revenuearrangement -- Join with transaction
    LEFT JOIN INBOUND_RAW.NETSUITE.ITEM i ON i.id = rp.ITEM -- Join with item
    LEFT JOIN INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op ON op.name = re.source -- Join with contract lines
    LEFT JOIN INBOUND_RAW.NETSUITE.CUSTOMER cust ON cust.id = t.entity -- Join with customer
    LEFT JOIN INBOUND_RAW.NETSUITE.CUSTOMER enduser ON enduser.id = t.custbody_so_enduser -- Join with end user
    LEFT JOIN INBOUND_RAW.NETSUITE.REVENUERECOGNITIONRULE rrr ON rrr.id = i.revenuerecognitionrule -- Join with revenue recognition rule
    LEFT JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY s ON s.id = re.subsidiary -- Join with subsidiary
    LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT acc ON acc.id = i.incomeaccount -- Join with income account
    LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNT def ON def.id = i.deferredrevenueaccount -- Join with deferred revenue account
    LEFT JOIN INBOUND_RAW.SALESFORCE.ORDER_ITEM sfop ON sfop.id = op.externalid -- Join with Salesforce order item
    LEFT JOIN INBOUND_RAW.SALESFORCE.SERVICE_CONTRACT sfsc ON sfsc.id = sfop.sbqqsc_service_contract_c -- Join with Salesforce service contract
    LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD ap ON ap.id = CASE 
                                                                    WHEN rppr.postingperiod IS NULL THEN rppr.plannedperiod 
                                                                    ELSE rppr.postingperiod 
                                                                  END -- Join with accounting period
    LEFT JOIN INBOUND_RAW.NETSUITE.JOB p ON p.id = op.custrecord_is_cl_job -- Join with job
    LEFT JOIN inbound_raw.netsuite.currency cur ON cur.symbol = rp.revenueplancurrency -- Join with currency
    LEFT JOIN INBOUND_RAW.NETSUITE.CONSOLIDATEDEXCHANGERATE cer ON cer.fromcurrency = cur.id 
                                                                AND cer.postingperiod = rppr.PlannedPeriod 
                                                                AND cer.fromsubsidiary = re.subsidiary 
                                                                AND cer.tosubsidiary = 1 
                                                                AND cer.accountingbook = 1 -- Join with consolidated exchange rate

    -- Added to prevent transaction line issue
    LEFT JOIN (
        SELECT 
            COUNT(DISTINCT tl.transaction) AS NoMatchTransactionCount, -- Count of unmatched transactions
            SUM(tl.foreignamount) AS OPLinkedTransactionSum, -- Sum of linked transactions
            op.externalid AS OPExternalID, -- External ID of the order product
            CAST(tl.custcol_rev_rec_start_date AS DATE) AS RevRecStartDate, -- Revenue recognition start date
            CAST(tl.custcol_rev_rec_end_date AS DATE) AS RevRecEndDate, -- Revenue recognition end date
            tl.id AS TranLineID, -- Transaction line ID
            t.type AS TranType, -- Type of the transaction
            t.id AS TranID -- Transaction ID
        FROM INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op
        LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON op.externalid = tl.custcol_arm_sourceexternalid -- Join with transaction line
        LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION t ON t.id = tl.transaction -- Join with transaction
        GROUP BY 
            op.externalid, 
            tl.custcol_rev_rec_start_date, 
            tl.custcol_rev_rec_end_date,
            tl.id,
            t.type,
            t.id
    ) sq ON sq.OPExternalID = op.externalid -- Join with subquery to prevent transaction line issues

    WHERE 
        rppr.AMOUNT <> 0   -- Filter out zero amounts
        AND rp.revenueplantype = 'ACTUAL'  -- Only include actual revenue plans
        AND (i.itemtype = 'Service' OR i.itemtype = 'NonInvtPart') -- Only include service or non-inventory parts
    ORDER BY CONCAT(YEAR(ap.startdate), '-', LPAD(MONTH(ap.startdate), 2, '0')) DESC; -- Order by period year and month

    -- Create or replace the final table with additional logic
    CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_REVPLANVIEW AS
    SELECT DISTINCT
        rpt.*, -- Include all columns from the main table
        CASE 
            WHEN CONCAT(YEAR(rpt.LastEndDate), '-', LPAD(MONTH(rpt.LastEndDate), 2, '0')) >= rpt.PeriodYearMonth 
                OR TranType = 'CustCred' 
            THEN 1 
            ELSE 0 
        END AS PlanDummy100 -- Additional logic for PlanDummy100 column
    FROM SB_ERPTEAM.PUBLIC.T_REVPLANVIEW_MAIN rpt;

    -- Return success message
    RETURN 'Table SB_ERPTEAM.PUBLIC.T_REVPLANVIEW created successfully';

END;
$$;



select * from SB_ERPTEAM.PUBLIC.T_REVPLANVIEW r 
where// r.revenueplanid = 2889400// 5662145 //3331849
-- r.subsidiary = 'Insightsoftware Australia Pty Ltd.' 
--or
arrangementnumber = '17410131'

;




























































































































































--#region Crap

-- Archived

CREATE OR REPLACE PROCEDURE SB_ERPTEAM.PUBLIC.USP_T_REVPLANVIEW()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_REVPLANVIEW_MAIN AS

-- WITH CTE_MaxVersion AS (
--     SELECT 
--         rp.ID as RevenuePlanID,
--         MAX(rpv.version) as MaxVersion
--     FROM INBOUND_RAW.NETSUITE.REVENUEPLAN rp
--     LEFT JOIN INBOUND_RAW.NETSUITE.PLANNEDREVENUEVERSION rpv ON rpv.revenueplan = rp.id
--     where rp.revenueplantype = 'ACTUAL'
--     GROUP BY rp.ID
-- )

SELECT DISTINCT
    rp.ID as RevenuePlanID,
    rp.ITEM as RevenuePlanITEM,
    rp.REVENUEPLANCURRENCY as RevenuePlanREVENUEPLANCURRENCY,
    rp.AMOUNT as RevenuePlanAMOUNT,
    rp.revenueplantype as RevenuePlanType,
    rppr.ID as RevenuePlanPlannedRevenueID,
    rppr.PLANNEDPERIOD as RevenuePlanPlannedRevenuePLANNEDPERIOD,
    rppr.POSTINGPERIOD as RevenuePlanPlannedRevenuePOSTINGPERIOD,
    rppr.JOURNAL as RevenuePlanPlannedRevenueJOURNAL,
    --cer.currentrate as   //ConsolidatedExchangeRateID,
    cer.currentrate as CurencyRate,
    cer.FromCurrency as FromCurrency,
    cer.ToCurrency as ToCurrency,
    --c.FromSubsidiary as  //FromSubsidiary,
    --c.FromSubsidiaryID as  //FromSubsidiaryID,
    --c.ToSubSidiary as   //ToSubSidiary, 
    --c.PeriodName as PeriodName,
    --c.PostingPeriodID as PostingPeriodID,
    --c.PeriodCurrency as PeriodCurrency,
    concat(rppr.PLANNEDPERIOD,rp.REVENUEPLANCURRENCY) as RevPlanPeriodCurrency,
    rppr.AMOUNT * cer.currentrate as RevPlanUSD, 
    rppr.amount as RevPlanForex,
    re.subsidiary as PlanSub,
    --c.averagerate as AverageRate,
    i.displayname as ItemDisplayName,
    i.itemtype as ItemType,
    i.incomeaccount as ItemIncomeAccount,
    concat(cust.entityid,concat(' ',cust.companyname)) as CustomerName,
    op.name as OrderProductName,
    op.custrecord_is_cl_sf_deal_id as OrderProductDealID,
    enduser.companyname as EndUserName,
    rrr.name as ItemRevRecRule,
    op.id as OrderProductID,
    -- case when rppr.JOURNAL is not null then rppr.AMOUNT * c.averagerate end as PostedAmountUSD,
    -- case when rppr.JOURNAL is null then rppr.AMOUNT * c.averagerate end as PlannedAmountUSD,
    -- case when rppr.JOURNAL is not null then rppr.AMOUNT end as PostedAmountForex,
    -- case when rppr.JOURNAL is null then rppr.AMOUNT end as PlannedAmountForex,
    op.custrecord_is_cl_order as NSOrderID,
    cust.id as CustomerID,
    enduser.id as EndUserID,
    re.source as ElementSource,
    op.custrecord_is_cl_price as OrderProductAmount,
    t.entity as ArrangementBillTo,
    t.custbody_so_enduser as ArrangementEndUser,
    s.name as Subsidiary,
    i.custitem_product_family as ItemProductFamily,
    op.custrecord_is_cl_date as OrderProductDate,
    re.createrevenueplanson as RevElementCreateRevenuePlansOn,
    re.sourcerecordtype as RevElementSourceRecordType,
    def.fullname as ItemDeferredRevAccount,
    re.revrecstartdate as RevRecStartDate,
    re.revrecenddate as RevRecEndDate,
    re.id as RevenueElementID,
    t.id as ArrangementNumber,
    CASE 
        WHEN acc.acctnumber like '401%' THEN 'Maintenance Revenue' 
        WHEN acc.acctnumber like '402%' THEN 'Subscription Revenue'
        WHEN acc.acctnumber like '403%' THEN 'License Revenue'
        WHEN acc.acctnumber like '40410%' THEN 'Professional Services Revenue'
        WHEN acc.acctnumber like '40490%' THEN 'Professional Services Revenue'      
        WHEN acc.acctnumber like '40420%' THEN 'Recurring Service'
        WHEN acc.acctnumber like '40480%' THEN 'Recurring Service'
        WHEN acc.acctnumber like '405%' THEN 'Hosting Revenue'
        WHEN acc.acctnumber like '409%' THEN 'Other Revenue'
        ELSE acc.accountsearchdisplayname
    END as IncomeAccountName,
    acc.accttype as IncomeAccountType,
    sfop.sbqqsc_service_contract_c as ServiceContract,
    rppr.isrecognized as IsRecognized,
    ap.PeriodName as PostingPeriodName, -- Renamed column
    ap.startdate as PostingPeriodStartDate,
    sfsc.contract_number as ServiceContractNumber,
    sfsc.start_date as ServiceContractStartDate,
    sfsc.end_date as ServiceContractEndDate,
    sfop.id as SalesforceOrderProductID,
    case when rppr.JOURNAL is null then 'Planned' else 'Posted' end as PlanStatus,
    p.entityid as ProjectName,
    sq.NoMatchTransactionCount as OPTransactionCount,
    //sq.OPLinkedTransactionSum as OPLinkedTransactionSum,
    cust.entityid as CustomerEntityID,
    concat(re.subsidiary, concat(rppr.PLANNEDPERIOD,rp.REVENUEPLANCURRENCY)) as SubPeriodCurrency,
    rp.parentlinecurrency as RevPlanParentLineCurrency,
    -- ifnull(fx.exchangerate,1) as RevPlanCurrentExchangeRate,
    -- ifnull(fx2.exchangerate,1) as RevPlanOriginalExchangeRate,
    -- ((ifnull(fx.exchangerate,1)+ifnull(fx2.exchangerate,1)))/2 as RevPlanExchangeRateAdjustment,
    -- (rppr.amount * ifnull(fx.exchangerate,1)) as AdjustedForexRate,
    t.trandate as TranDate,
    rppr.AMOUNT as RevenuePlanPlannedRevenueAMOUNT,
    CONCAT(YEAR(ap.startdate),CONCAT('-', LPAD(MONTH(ap.startdate), 2, '0'))) AS PeriodYearMonth,
    rp.statusfordisplay as PlanStatusForDisplay,
    cer.currentrate as CurrencyExchangeRate,
    //sq.RevRecStartDate as TranRevRecStartDate, 
    //sq.RevRecEndDate as TranRevRecEndDate,
    CASE 
        WHEN sq.TranType = 'CustCred' OR sq.RevRecEndDate IS NOT NULL or rppr.amount < 0
        THEN 1 
        ELSE 0  
    END AS TranDummy,
    sq.TranType as TranType,
    //rpv.version,
    op.custrecord_isw_revised_order_product as RevisedOrderProduct,
    i.itemid,
    //sq.tranlineid,
    //sq.TranID,
    op.externalid as OPExternalID,
    MIN(sq.RevRecStartDate) OVER (PARTITION BY rppr.ID) as FirstStartDate,
    MAX(sq.RevRecEndDate) OVER (PARTITION BY rppr.ID) as LastEndDate,
    t.tranid as ArrangementDocNumber
// Add Order and Plan number

from INBOUND_RAW.NETSUITE.REVENUEPLAN rp
left join INBOUND_RAW.NETSUITE.REVENUEPLANPLANNEDREVENUE rppr on rppr.revenueplan = rp.id
left join INBOUND_RAW.NETSUITE.REVENUEELEMENT re on re.id = rp.createdfrom
left join INBOUND_RAW.NETSUITE.TRANSACTION t on t.id = re.revenuearrangement
left join INBOUND_RAW.NETSUITE.ITEM i on i.id = rp.ITEM
left join INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op on op.name = re.source
left join INBOUND_RAW.NETSUITE.CUSTOMER cust on cust.id = t.entity
left join INBOUND_RAW.NETSUITE.CUSTOMER enduser on enduser.id = t.custbody_so_enduser
left join INBOUND_RAW.NETSUITE.REVENUERECOGNITIONRULE rrr on rrr.id = i.revenuerecognitionrule
left join INBOUND_RAW.NETSUITE.SUBSIDIARY s on s.id = re.subsidiary
left join INBOUND_RAW.NETSUITE.ACCOUNT acc on acc.id = i.incomeaccount
left join INBOUND_RAW.NETSUITE.ACCOUNT def on def.id = i.deferredrevenueaccount
left join INBOUND_RAW.SALESFORCE.ORDER_ITEM sfop on sfop.id = op.externalid
left join INBOUND_RAW.SALESFORCE.SERVICE_CONTRACT sfsc on sfsc.id = sfop.sbqqsc_service_contract_c
--left join INBOUND_RAW.SALESFORCE.CONTRACT_LINE_ITEM sfscl on sfslc.ServiceContract = sfsc.id
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD ap ON ap.id = CASE WHEN rppr.postingperiod IS NULL THEN rppr.plannedperiod ELSE rppr.postingperiod END
left join INBOUND_RAW.NETSUITE.JOB p on p.id = op.custrecord_is_cl_job
--left join SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD c on c.subperiodcurrency = concat(re.subsidiary, concat(rppr.PLANNEDPERIOD,rp.REVENUEPLANCURRENCY))
left join inbound_raw.netsuite.currency cur ON cur.symbol = rp.revenueplancurrency
//left join INBOUND_RAW.NETSUITE.PLANNEDREVENUEVERSION rpv on rpv.revenueplan = rp.id
left join INBOUND_RAW.NETSUITE.CONSOLIDATEDEXCHANGERATE cer ON cer.fromcurrency = cur.id AND cer.postingperiod = rppr.PlannedPeriod AND cer.fromsubsidiary = re.subsidiary AND cer.tosubsidiary = 1 AND cer.accountingbook = 1
-- left join SB_ERPTEAM.PUBLIC.NS_ALL_FOREX fx on fx.base_tran_currencydate = concat(rp.parentlinecurrency,rp.REVENUEPLANCURRENCY)
-- left join SB_ERPTEAM.PUBLIC.NS_ALL_FOREX_ALL_DATES fx2 on fx2.base_tran_currencydate = concat(rp.parentlinecurrency,concat(rp.REVENUEPLANCURRENCY,cast(t.trandate as DATE)))



// Tran Line ISSUE
LEFT JOIN (
    SELECT 
        COUNT(DISTINCT tl.transaction) AS NoMatchTransactionCount,
        sum(tl.foreignamount) as OPLinkedTransactionSum,
        op.externalid OPExternalID,
        Cast(tl.custcol_rev_rec_start_date as DATE) as RevRecStartDate,
        Cast(tl.custcol_rev_rec_end_date as DATE) as RevRecEndDate,
        tl.id   as TranLineID,
        t.type  as TranType,
        t.id    as TranID
    FROM INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op
    LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON op.externalid = tl.custcol_arm_sourceexternalid
    LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION t ON t.id = tl.transaction
    GROUP BY 
        op.externalid, 
        tl.custcol_rev_rec_start_date, 
        tl.custcol_rev_rec_end_date,
        tl.id,
        t.type,
        t.id
) sq ON sq.OPExternalID = op.externalid

-- LEFT JOIN CTE_MaxVersion mv ON mv.RevenuePlanID = rp.id AND (rpv.version IS NULL OR rpv.version = mv.MaxVersion)


WHERE 
--(rpv.version IS NULL OR rpv.version = mv.MaxVersion) 

//i.displayname = 'JET-MNT-RPT-REPORTSMNT' and 
 rppr.AMOUNT <> 0   
and rp.revenueplantype = 'ACTUAL'  
and (i.itemtype = 'Service' or i.itemtype = 'NonInvtPart') 
//and rp.ID = 3331849
order by CONCAT(YEAR(ap.startdate),CONCAT('-', LPAD(MONTH(ap.startdate), 2, '0'))) desc
;


CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_REVPLANVIEW AS
select distinct
rpt.*,
case when CONCAT(YEAR(rpt.LastEndDate),CONCAT('-', LPAD(MONTH(rpt.LastEndDate), 2, '0'))) >= rpt.PeriodYearMonth or TranType = 'CustCred' then 1 else 0 end as PlanDummy100
from SB_ERPTEAM.PUBLIC.T_REVPLANVIEW_MAIN rpt 
// TRY GROUP BY

;
    RETURN 'Table SB_ERPTEAM.PUBLIC.T_REVPLANVIEW created successfully';
END;
$$;
;

//Join to the salesforce credit rather than the NS credit

select * from SB_ERPTEAM.PUBLIC.T_REVPLANVIEW r 
where r.ITEMINCOMEACCOUNT = 40420// 5662145 //3331849
-- r.subsidiary = 'Insightsoftware Australia Pty Ltd.' 
--or
--arrangementnumber = '17606182'

;



CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_REVPLANVIEW AS
;
select
-- Insert data into the temporary table based on specified conditions
 rp.ID as RevenuePlanID,
 rp.ITEM as RevenuePlanITEM,
 rp.REVENUEPLANCURRENCY as RevenuePlanREVENUEPLANCURRENCY,
 rp.AMOUNT as RevenuePlanAMOUNT,
 rp.revenueplantype as RevenuePlanType,
 rppr.ID as RevenuePlanPlannedRevenueID,
 rppr.PLANNEDPERIOD as RevenuePlanPlannedRevenuePLANNEDPERIOD,
 rppr.POSTINGPERIOD as RevenuePlanPlannedRevenuePOSTINGPERIOD,
 rppr.JOURNAL as RevenuePlanPlannedRevenueJOURNAL,
 //c.ConsolidatedExchangeRateID as   //ConsolidatedExchangeRateID,
 //c.CurencyRate as   //CurencyRate,
 c.FromCurrency as  FromCurrency,
 c.ToCurrency as  ToCurrency,
 //c.FromSubsidiary as  //FromSubsidiary,
 //c.FromSubsidiaryID as  //FromSubsidiaryID,
 //c.ToSubSidiary as   //ToSubSidiary, c.PeriodName as  PeriodName,
 c.PostingPeriodID as  PostingPeriodID,
 c.PeriodCurrency as  PeriodCurrency,
 concat(rppr.PLANNEDPERIOD,rp.REVENUEPLANCURRENCY) as RevPlanPeriodCurrency,
 rppr.AMOUNT * cer.currentrate as RevPlanUSD, 
 rppr.amount as RevPlanForex,
 re.subsidiary as PlanSub,
 c.averagerate as AverageRate,
 i.displayname as ItemDisplayName,
 i.itemtype as ItemType,
 i.incomeaccount as ItemIncomeAccount,
 concat(cust.entityid,concat(' ',cust.companyname)) as CustomerName,
 op.name as OrderProductName,
 op.custrecord_is_cl_sf_deal_id as OrderProductDealID,
 enduser.companyname as EndUserName,
 rrr.name as ItemRevRecRule,
 op.id as OrderProductID,
 case when rppr.JOURNAL is not null then rppr.AMOUNT * c.averagerate end as PostedAmountUSD,
 case when rppr.JOURNAL is null then rppr.AMOUNT * c.averagerate end as PlannedAmountUSD,
 case when rppr.JOURNAL is not null then rppr.AMOUNT end as PostedAmountForex,
 case when rppr.JOURNAL is null then rppr.AMOUNT end as PlannedAmountForex,
 op.custrecord_is_cl_order as NSOrderID,
 cust.id as CustomerID,
 enduser.id as EndUserID,
 re.source as ElementSource,
 op.custrecord_is_cl_price as OrderProductAmount,
 t.entity as ArrangementBillTo,
 t.custbody_so_enduser as ArrangementEndUser,
 s.name as Subsidiary,
 i.custitem_product_family as ItemProductFamily,
 op.custrecord_is_cl_date as OrderProductDate,
 re.createrevenueplanson as RevElementCreateRevenuePlansOn,
 re.sourcerecordtype as RevElementSourceRecordType,
 def.fullname as ItemDeferredRevAccount,
 re.revrecstartdate as RevRecStartDate,
 re.revrecenddate as RevRecEndDate,
 re.id as RevenueElementID,
 t.id as ArrangementNumber,
 CASE WHEN acc.acctnumber like '401%' THEN 'Maintenance Revenue' 
      WHEN acc.acctnumber like '402%' THEN 'Subscription Revenue'
      WHEN acc.acctnumber like '403%' THEN 'License Revenue'
      WHEN acc.acctnumber like '40410%' THEN 'Professional Services Revenue'
      WHEN acc.acctnumber like '40490%' THEN 'Professional Services Revenue'      
      WHEN acc.acctnumber like '40420%' THEN 'Recurring Service'
      WHEN acc.acctnumber like '40480%' THEN 'Recurring Service'
      WHEN acc.acctnumber like '405%' THEN 'Hosting Revenue'

      ELSE ''
      END
      as IncomeAccountName,
 acc.accttype as IncomeAccountType,
 sfop.sbqqsc_service_contract_c as ServiceContract,
 rppr.isrecognized as IsRecognized,
 ap.PeriodName as PeriodName,
 ap.startdate as PostingPeriodStartDate,
 sfsc.contract_number as ServiceContractNumber,
 sfsc.start_date as ServiceContractStartDate,
 sfsc.end_date as ServiceContractEndDate,
 sfop.id as SalesforceOrderProductID,
 case when rppr.JOURNAL is null then 'Planned' else 'Posted' end as PlanStatus,
 p.entityid as ProjectName,
 sq.NoMatchTransactionCount as OPTransactionCount,
 sq.OPLinkedTransactionSum as OPLinkedTransactionSum,
 cust.entityid as CustomerEntityID,
 concat(re.subsidiary, concat(rppr.PLANNEDPERIOD,rp.REVENUEPLANCURRENCY)) as SubPeriodCurrency,
 rp.parentlinecurrency as RevPlanParentLineCurrency,
--  ifnull(fx.exchangerate,1) as RevPlanCurrentExchangeRate,
--  ifnull(fx2.exchangerate,1) as RevPlanOriginalExchangeRate,
-- ((ifnull(fx.exchangerate,1)+ifnull(fx2.exchangerate,1)))/2 as RevPlanExchangeRateAdjustment,
-- (rppr.amount * ifnull(fx.exchangerate,1)) as AdjustedForexRate,
t.trandate as TranDate,
rppr.AMOUNT as RevenuePlanPlannedRevenueAMOUNT,
CONCAT(YEAR(ap.startdate),CONCAT('-', LPAD(MONTH(ap.startdate), 2, '0'))) AS PeriodYearMonth,
rp.statusfordisplay as PlanStatusForDisplay,
cer.currentrate as CurrencyExchangeRate,
sq.RevRecStartDate as TranRevRecStartDate, 
sq.RevRecEndDate as TranRevRecEndDate,
CASE 
    WHEN sq.TranType = 'CustCred' OR sq.RevRecEndDate IS NOT NULL 
    THEN 1 
    ELSE 0  
END AS TranDummy,
sq.TranType as TranType,
rpv.version,
op.custrecord_isw_revised_order_product as RevisedOrderProduct,
i.itemid

from INBOUND_RAW.NETSUITE.REVENUEPLAN rp
left join INBOUND_RAW.NETSUITE.REVENUEPLANPLANNEDREVENUE rppr on rppr.revenueplan = rp.id
left join INBOUND_RAW.NETSUITE.REVENUEELEMENT re on re.id = rp.createdfrom
left join INBOUND_RAW.NETSUITE.TRANSACTION t on t.id = re.revenuearrangement
left join INBOUND_RAW.NETSUITE.ITEM i on i.id = rp.ITEM
left join INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op on op.name = re.source
left join INBOUND_RAW.NETSUITE.CUSTOMER cust on cust.id = t.entity
left join INBOUND_RAW.NETSUITE.CUSTOMER enduser on enduser.id = t.custbody_so_enduser
left join INBOUND_RAW.NETSUITE.REVENUERECOGNITIONRULE rrr on rrr.id = i.revenuerecognitionrule
left join INBOUND_RAW.NETSUITE.SUBSIDIARY s on s.id = re.subsidiary
left join INBOUND_RAW.NETSUITE.ACCOUNT acc on acc.id = i.incomeaccount
left join INBOUND_RAW.NETSUITE.ACCOUNT def on def.id = i.deferredrevenueaccount
left join INBOUND_RAW.SALESFORCE.ORDER_ITEM sfop on sfop.id = op.externalid
left join INBOUND_RAW.SALESFORCE.SERVICE_CONTRACT sfsc on sfsc.id = sfop.sbqqsc_service_contract_c
//left join INBOUND_RAW.SALESFORCE.CONTRACT_LINE_ITEM sfscl on sfslc.ServiceContract = sfsc.id
LEFT JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD ap ON ap.id = CASE WHEN rppr.postingperiod IS NULL THEN rppr.plannedperiod ELSE rppr.postingperiod END
left join INBOUND_RAW.NETSUITE.JOB p on p.id = op.custrecord_is_cl_job
left join SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD c on c.subperiodcurrency = concat(re.subsidiary, concat(rppr.PLANNEDPERIOD,rp.REVENUEPLANCURRENCY))
left join inbound_raw.netsuite.currency cur ON cur.symbol = rp.revenueplancurrency

left join INBOUND_RAW.NETSUITE.PLANNEDREVENUEVERSION rpv on rpv.revenueplan = rp.id

left join INBOUND_RAW.NETSUITE.CONSOLIDATEDEXCHANGERATE cer ON cer.fromcurrency = cur.id AND cer.postingperiod = rppr.PlannedPeriod AND cer.fromsubsidiary = re.subsidiary AND cer.tosubsidiary = 1 AND cer.accountingbook = 1
left join SB_ERPTEAM.PUBLIC.NS_ALL_FOREX fx on fx.base_tran_currencydate = concat(rp.parentlinecurrency,rp.REVENUEPLANCURRENCY)
left join SB_ERPTEAM.PUBLIC.NS_ALL_FOREX_ALL_DATES fx2 on fx2.base_tran_currencydate = concat(rp.parentlinecurrency,concat(rp.REVENUEPLANCURRENCY,cast(t.trandate as DATE)))


LEFT JOIN (
    SELECT 
        COUNT(DISTINCT tl.transaction) AS NoMatchTransactionCount,
        sum(tl.foreignamount) as OPLinkedTransactionSum,
        op.externalid OPExternalID,
        Cast(tl.custcol_rev_rec_start_date as DATE) as RevRecStartDate,
        Cast(tl.custcol_rev_rec_end_date as DATE) as RevRecEndDate,
        tl.id TranID,
        t.type as TranType
    FROM INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op
    LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON op.externalid = tl.custcol_arm_sourceexternalid
    LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTION t ON t.id = tl.transaction



    GROUP BY 
    op.externalid, 
    tl.custcol_rev_rec_start_date, 
    tl.custcol_rev_rec_end_date,
    tl.id,
    t.type

;

--#endregion





//where planstatus = 'Planned'
//CASE WHEN i.product_line_c 	= '46' THEN 'Agility' ELSE	= '42' THEN 'Angles' ELSE	= '68' THEN 'Angles For Oracle' ELSE	= '69' THEN 'Angles for SAP' ELSE	= '75' THEN 'Angles MidMarket' ELSE	= '74' THEN 'Angles Professional' ELSE	= '4' THEN 'Atlas' ELSE	= '50' THEN 'BizInsight' ELSE	= '11' THEN 'Biznet' ELSE	= '13' THEN 'Bizview' ELSE	= '38' THEN 'CALUMO' ELSE	= '26' THEN 'Certent Disclosure Management' ELSE	= '51' THEN 'Certent Disclosure Management' ELSE	= '25' THEN 'Certent Equity Management' ELSE	= '63' THEN 'Clausion' ELSE	= '27' THEN 'Corporate' ELSE	= '67' THEN 'Cubeware' ELSE	= '8' THEN 'CXO' ELSE	= '3' THEN 'DecisionPoint' ELSE	= '62' THEN 'Dundas' ELSE	= '22' THEN 'Event1' ELSE	= '41' THEN 'Exago' ELSE	= '7' THEN 'Excel4Apps' ELSE	= '64' THEN 'FastPost' ELSE	= '2' THEN 'Global' ELSE	= '1' THEN 'Hubble' ELSE	= '28' THEN 'IDL' ELSE	= '29' THEN 'IDL 3RD Party' ELSE	= '37' THEN 'IDL Bundle' ELSE	= '36' THEN 'IDL Designer' ELSE	= '31' THEN 'IDL Disclosure Management' ELSE	= '32' THEN 'IDL Forecast' ELSE	= '30' THEN 'IDL Konsis' ELSE	= '33' THEN 'IDL Konsis' ELSE	= '34' THEN 'IDL PIT AG' ELSE	= '52' THEN 'IDL Third Party' ELSE	= '14' THEN 'Insight' ELSE	= '10' THEN 'Intellicast' ELSE	= '5' THEN 'iSuite' ELSE	= '40' THEN 'Izenda' ELSE	= '12' THEN 'Jet' ELSE	= '47' THEN 'Kalido' ELSE	= '35' THEN 'Legacy' ELSE	= '53' THEN 'Legacy Accounting' ELSE	= '6' THEN 'Legacy Accounting Module' ELSE	= '61' THEN 'Legerity' ELSE	= '59' THEN 'Logi Analytics' ELSE	= '71' THEN 'Logi Composer' ELSE	= '72' THEN 'Logi Info' ELSE	= '73' THEN 'Logi Report' ELSE	= '39' THEN 'Logi Symphony' ELSE	= '15' THEN 'Longview Analytics' ELSE	= '16' THEN 'Longview Close' ELSE	= '17' THEN 'Longview Hosting' ELSE	= '18' THEN 'Longview Integration Suite' ELSE	= '19' THEN 'Longview Plan' ELSE	= '20' THEN 'Longview Tax' ELSE	= '21' THEN 'Longview Tidemark' ELSE	= '48' THEN 'Magnitude' ELSE	= '23' THEN 'Mekko Graphics' ELSE	= '49' THEN 'New Amsterdam Parent Software, LLC' ELSE	= '54' THEN 'Operational Reporting' ELSE	= '76' THEN 'Platform' ELSE	= '70' THEN 'PowerON' ELSE	= '43' THEN 'Process Runner' ELSE	= '45' THEN 'Simba' ELSE	= '44' THEN 'SourceConnect' ELSE	= '55' THEN 'Spreadsheet Server' ELSE	= '66' THEN 'Tabella' ELSE	= '56' THEN 'Tidemark' ELSE	= '24' THEN 'Viareport' ELSE	= '77' THEN 'Vizlib' ELSE	= '9' THEN 'Wands' ELSE	= '57' THEN 'Wands for Oracle' ELSE	= '58' THEN 'Wands for SAP' ELSE	= '' THEN '' ELSE	= '' THEN '' ELSE
;

SELECT TOP 10 *
FROM (
    SELECT PERIODYEARMONTH, REVPLANFOREX
    FROM SB_ERPTEAM.PUBLIC.REVPLANVIEW
)
PIVOT (
    SUM(REVPLANFOREX)
    FOR PERIODYEARMONTH IN ('Value1', 'Value2', ..., 'ValueN') -- Replace with actual PERIODYEARMONTH values
) AS p

;

;
SELECT * 
  FROM monthly_sales
    PIVOT(SUM(amount) FOR MONTH IN ('JAN', 'FEB', 'MAR', 'APR'))
      AS p
  ORDER BY EMPID;

;

describe table SB_ERPTEAM.PUBLIC.REVPLANVIEW;

select * from SB_ERPTEAM.PUBLIC.REVPLANVIEW


//describe view SB_ERPTEAM.PUBLIC.REVPLANVIEW
//;

-- CREATE OR REPLACE PROCEDURE dynamic_pivot()
-- RETURNS STRING
-- LANGUAGE JAVASCRIPT
-- AS
-- $$
--     var customerIdsQuery = `SELECT LISTAGG(DISTINCT QUOTE_IDENT(CUSTOMERID), ', ') WITHIN GROUP (ORDER BY CUSTOMERID) AS customer_ids FROM SB_ERPTEAM.PUBLIC.REVPLANVIEW`;
--     var stmt = snowflake.createStatement({sqlText: customerIdsQuery});
--     var result = stmt.execute();
--     result.next();
--     var customerIds = result.getColumnValue(1);

--     var pivotQuery = `SELECT * FROM (
--                           SELECT POSTEDAMOUNTUSD, CUSTOMERID 
--                           FROM SB_ERPTEAM.PUBLIC.REVPLANVIEW
--                       ) PIVOT (
--                           SUM(POSTEDAMOUNTUSD) FOR CUSTOMERID IN (` + customerIds + `)
--                       )`;

--     return pivotQuery;
-- $$;

-- -- Execute the stored procedure
-- CALL dynamic_pivot();




;

select 
e.id,
e.source,
t.id,
t.trandisplayname,
op.name,
case when t.trandisplayname is null then op.name else t.trandisplayname end,
tl.transaction as OPRelatedTransaction


from INBOUND_RAW.NETSUITE.REVENUEELEMENT e
left join INBOUND_RAW.NETSUITE.TRANSACTION t on t.TRANDISPLAYNAME = e.source
left join INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op on op.name = e.source
left join INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl on tl.custcol_arm_sourceexternalid = op.externalid
;


SELECT 
    COUNT(tl.transaction) AS transaction_count,
    op.externalid
FROM INBOUND_RAW.NETSUITE.CUSTOMRECORD_CONTRACTLINES op
LEFT JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl 
    ON op.externalid = tl.custcol_arm_sourceexternalid
GROUP BY op.externalid
//HAVING COUNT(tl.transaction) = 0
;

with CTE AS
    (
select  CONCAT(cus.entityid,' ',cus.companyname) as Customer,
        rp.id as InternalID,
        rp.recordnumber as RevRecPlanNum,
        CAST(re.revenuearrangement AS TEXT) as RevenueArrangementIntID,
        rp.statusfordisplay as PlanStatus,
        acc.accountsearchdisplayname as DeferralAcct,
        acc2.accountsearchdisplayname as RecognitionAcct,
        rp.REVENUEPLANCURRENCY as PlanCurrency,
        rppr.amount as PlannedAmount,        
        ap.periodname as PlannedPeriod,
        CAST(ap.enddate AS DATE) as PeriodEndDate,
        sub.name as Subsidiary,
        cer.currentrate as CurrencyExchangeRate
from    inbound_raw.netsuite.revenueplanplannedrevenue rppr
left join    inbound_raw.netsuite.revenueplan rp ON rp.id = rppr.revenueplan
left join    inbound_raw.netsuite.accountingperiod ap ON rppr.PlannedPeriod = ap.id
left join    inbound_raw.netsuite.account acc ON rppr.deferredrevenueaccount = acc.id
left join    inbound_raw.netsuite.account acc2 ON rppr.recognitionaccount = acc2.id
left join    inbound_raw.netsuite.revenueelement re ON re.id = rp.createdfrom
left join    inbound_raw.netsuite.customer cus ON cus.id = re.entity
left join    inbound_raw.netsuite.subsidiary sub ON sub.id = re.subsidiary
left join    inbound_raw.netsuite.currency cur ON cur.symbol = rp.revenueplancurrency
left join    INBOUND_RAW.NETSUITE.CONSOLIDATEDEXCHANGERATE cer ON cer.fromcurrency = cur.id AND cer.postingperiod = rppr.PlannedPeriod AND cer.fromsubsidiary = re.subsidiary AND cer.tosubsidiary = 1 AND cer.accountingbook = 1
where   acc.accountsearchdisplayname = '24100 Deferred Commission - 3rd Parties'
    AND rp.REVENUEPLANTYPE = 'ACTUAL'
    )
 
select CTE.*,
    CASE WHEN PlanCurrency = 'USD' THEN PlannedAmount ELSE ROUND(PlannedAmount*CurrencyExchangeRate,2) END AS PlannedAmountUSD,
    CASE WHEN PlanCurrency = 'USD' THEN 1 ELSE CurrencyExchangeRate END AS ExchangeRate,
from CTE
   
;

select * from SB_ERPTEAM.PUBLIC.REVPLANVIEW;


select * from inbound_raw.netsuite.transaction

;


CREATE OR REPLACE VIEW SB_ERPTEAM.PUBLIC.REVPLANVIEW_REENGINEERED AS
select 
t.id,
tl.id as TranLineID,
tal.transaction,
tl.custcol_rev_rec_start_date as RevRecStartDate,
tl.custcol_rev_rec_end_date as RevRecEndDate


from
INBOUND_RAW.NETSUITE.TRANSACTION t
left join INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl on tl.transaction = t.id
left join INBOUND_RAW.NETSUITE.TRANSACTIONACCOUNTINGLINE tal on tal.transaction = t.id and tal.transactionline = tl.id

;

select top 10 * from SB_ERPTEAM.PUBLIC.REVPLANVIEW_REENGINEERED


;

CREATE OR REPLACE PROCEDURE SB_ERPTEAM.PUBLIC.USP_INSERT_JIRA_BACKLOG_SNAPSHOT()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS OWNER
AS '
BEGIN
    -- Insert the count of ''Jira Ticket'' into JiraERPBacklogSnapshot
    INSERT INTO SB_ERPTEAM.PUBLIC.JiraERPBacklogSnapshot
    SELECT COUNT(1), CURRENT_DATE(), ''Jira Ticket''
    FROM SB_ERPTEAM.PUBLIC.VW_JIRAISSUESBACKLOG
    WHERE IssueTypeB = ''Jira Ticket'';

        -- Insert the count of ''Jira Ticket'' into JiraERPBacklogSnapshot
    INSERT INTO SB_ERPTEAM.PUBLIC.JiraERPBacklogSnapshot
    SELECT COUNT(1), CURRENT_DATE(), ''Jira Project''
    FROM SB_ERPTEAM.PUBLIC.VW_JIRAISSUESBACKLOG
    WHERE IssueTypeB = ''Jira Project'';
    
    RETURN ''Insert completed successfully'';
END;
';



CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_REVPLANVIEW AS
-- update SB_ERPTEAM.PUBLIC.T_REVPLANVIEW
--     set
--             FirstStartDate = Cast(tl.custcol_rev_rec_start_date as DATE),
--             LastEndDate =    Cast(tl.custcol_rev_rec_end_date as DATE)   

--      from INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl

--         where OPExternalID = tl.custcol_arm_sourceexternalid

