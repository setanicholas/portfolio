CREATE OR REPLACE PROCEDURE USP_T_AT_RISK()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

CREATE OR REPLACE TABLE SB_ERPTEAM.PUBLIC.T_COLLECTIONS_AT_RISK AS


SELECT

a.id as AccountID,
r.SUBJECT_C as AtRiskSubject,
r.CREATED_DATE,
r.AT_RISK_REASON_C,
r.Renewal_Opportunity_c,
r.Opportunity_c,
r.Opportunity_Line_Item_c,
r.Renewal_Opportunity_Amount_c,
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
c.ESCALATION_FOLLOW_UP_DETAILS_COMMENTS_C,
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
r.id as AtRiskID,
r.name as AtRiskName,
c.id as CaseID,
r.At_Risk_Status_c,
c.description,
concat('https://glsft2.lightning.force.com/',r.id) as At_Risk_URL,
case when
    ((r.At_Risk_Status_c = 'Open' or c.status <> 'Closed') and c.id is not null)
        AND 
            ((r.AT_RISK_REASON_C = 'Collections / Non-pay')
            OR ((c.Escalation_Details_Comments_c like '%collections' OR c.Escalation_Details_Comments_c like '%Collections'))
            OR (c.description like '%collections' OR c.description like '%Collections'))

THEN 'At Risk with Case'
ELSE 'Not At Risk with Case'
    END
        AS At_Risks_with_cases_for_Collections





from INBOUND_RAW.SALESFORCE.AT_RISK_C r
join INBOUND_RAW.SALESFORCE.ACCOUNT a on a.id = r.account_c
left join INBOUND_RAW.SALESFORCE.CASE c on c.id = r.Case_c

;
    RETURN 'Table SB_ERPTEAM.PUBLIC.T_COLLECTIONS_AT_RISK created successfully';
END;
$$;


//

select count(id) from SB_ERPTEAM.PUBLIC.T_COLLECTIONS_AT_RISK where At_Risks_with_cases_for_Collections = 'At Risk with Case'
;

select At_Risks_with_cases_for_Collections, At_Risk_Status_c, status, id, AT_RISK_REASON_C, Escalation_Details_Comments_c, description from SB_ERPTEAM.PUBLIC.T_COLLECTIONS_AT_RISK where At_Risks_with_cases_for_Collections = 'At Risk with Case' order by at_risk_status_c
;
describe table SB_ERPTEAM.PUBLIC.T_COLLECTIONS_AT_RISK  