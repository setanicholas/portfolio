CREATE OR REPLACE PROCEDURE SB_ERPTEAM.PUBLIC.USP_T_CS_CASES()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Create or replace the main table for revenue plan view
CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_CS_CASES AS


SELECT 

c.id,
c.case_number,
c.account_id,
c.product_id,
c.type,
c.status,
c.origin,
c.subject,
c.priority,
c.is_closed,
c.closed_date,
c.is_escalated,
c.owner_id,
c.customer_asset_c,
c.department_c,
c.escalation_date_c,
//c.escalation_details_c,
c.ESCALATION_FOLLOW_UP_COMPLETED_C,
c.ESCALATION_FOLLOW_UP_DATE_C,
c.Escalation_Details_Comments_c,
c.ESCALATION_INITIATOR_C,
c.ESCALATION_OWNER_C,
c.ESCALATION_REASON_C,
c.ESCALATION_SOURCE_C,
c.ESCALATION_STATUS_C,
c.PRODUCT_FAMILY_C,
c.PRODUCT_LINE_SUPPORT_C,
c.PRODUCT_LINE_C,
c.SEVERITY_C,
c.METHOD_OF_DISCOVERY_C,
c.FIRST_CLOSE_DATE_C,
c.X_18_DIGIT_CASE_ID_C,
c.VIRTUAL_ASSET_C,
c.OWNER_DEPARTMENT_C,
c.ACCOUNT_OWNER_C,
c.FORMULACASE_OWNER_NAME_C,
c.DAYOF_WEEK_CASE_CREATED_C,
c.OWNER_IS_COMMUNITY_USER_C,
c.X_18_D_ACCOUNT_C,
c.FORMULAACCOUNT_NAME_C,
c.CASE_OWNER_MANAGER_EMAIL_C,
a.NAME,
CASE 
    WHEN (c.Record_Type_Id = '0122S0000002UQ1QAM' 
          AND c.status <> 'Closed' 
          AND a.name NOT LIKE '%Mifflin%' 
          AND c.parent_id IS NULL 
          AND (c.subject LIKE '%collections%'
               OR c.subject LIKE '%Collections%' 
               OR c.type = 'Collections')) 
    THEN 'Yes'
    ELSE 'No'
END AS NONPAY_CASES,
u.name as Owner_Name,
concat('https://glsft2.lightning.force.com/',c.id) as Case_URL,
case when Escalation_Details_Comments_c like '%Top75Collections%' THEN 'Top 75' ELSE 'Not Top 75' END as Is_Top_75


FROM INBOUND_RAW.SALESFORCE.CASE c 
JOIN INBOUND_RAW.SALESFORCE.ACCOUNT a on a.id = c.account_id
JOIN INBOUND_RAW.SALESFORCE.USER u on u.id = c.owner_id
//LEFT JOIN join INBOUND_RAW.SALESFORCE.CASE c on c.id = r.Case_c

//where NONPAY_CASES = 1
//WHERE c.Department_c = 'Customer Success'


;


    RETURN 'Table SB_ERPTEAM.PUBLIC.T_CS_CASES created successfully';

END;
$$;

select count(id) from SB_ERPTEAM.PUBLIC.T_CS_CASES 
