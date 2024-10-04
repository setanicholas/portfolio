CREATE OR REPLACE VIEW SB_ERPTEAM.PUBLIC.VW_COLLECTIONS_AMOUNT AS 
SELECT DISTINCT
    t.id AS TranID, 
    SUM(
        COALESCE(tl.creditforeignamount, 0) * COALESCE(cex.averagerate, 0) 
        - COALESCE(tl.debitforeignamount, 0) * COALESCE(cex.averagerate, 0)
    ) AS TotalLineAmountUSD,
    AVG(
        COALESCE(rt.applied_to_transaction_amount_remaining, 0) * COALESCE(cex.averagerate, 0)
    ) AS AmountRemaining,
    t.duedate AS DueDate,
    pc.id as PhoneCallID,
    pc.custevent_ar_collection_status as ARCollectionStatus,
    pc.status,
    pc.assigned,
    acc.type,
    e.entityid as Organizer,
    concat('https://5172601.app.netsuite.com/app/common/entity/custjob.nl?id=', c.id) as CustomerURL
    
FROM INBOUND_RAW.NETSUITE.TRANSACTION t

JOIN INBOUND_RAW.NETSUITE.TRANSACTIONLINE tl ON tl.transaction = t.id
JOIN INBOUND_RAW.NETSUITE.ACCOUNTINGPERIOD p ON p.id = t.postingperiod
JOIN SB_ERPTEAM.NS_TEST.INVTRANSTATUS ts ON ts.id = t.status
JOIN INBOUND_RAW.NETSUITE.SUBSIDIARY s ON s.id = tl.subsidiary
LEFT JOIN INBOUND_RAW.NETSUITE.ITEM i ON i.id = tl.item
LEFT JOIN INBOUND_RAW.NETSUITE.REVENUERECOGNITIONRULE rrr ON rrr.id = i.revenuerecognitionrule
LEFT JOIN INBOUND_RAW.NETSUITE.CUSTOMER c ON c.id = t.entity

LEFT JOIN (
    SELECT 
        pc1.company as Company,
        MAX(pc1.CREATEDDATE) AS MaxCreatedDate
    FROM INBOUND_RAW.NETSUITE.PHONECALL pc1
    WHERE pc1.status = 'SCHEDULED'
    GROUP BY pc1.company
) latest_pc ON latest_pc.company = c.id

LEFT JOIN INBOUND_RAW.NETSUITE.PHONECALL pc ON pc.company = c.id AND pc.CREATEDDATE = latest_pc.MaxCreatedDate

LEFT JOIN INBOUND_RAW.NETSUITE.CURRENCY cur ON cur.id = t.currency
LEFT JOIN INBOUND_RAW.NETSUITE.EMPLOYEE emp ON emp.id = t.custbody_lastmodifiedby
LEFT JOIN SB_ERPTEAM.NS_TEST.USDCONVERSIONBYPERIOD cex ON cex.periodcurrency = CONCAT(p.id, cur.name)
FULL JOIN INBOUND_RAW.ENT_DATA_FLAT_FILES._2023_10_26_SETA_TEST_PAYMENTS_RESULTS rt ON rt.APPLIED_TO_INTERNAL_ID = t.id
LEFT JOIN INBOUND_RAW.SALESFORCE.ACCOUNT acc on acc.id = c.externalid
LEFT JOIN INBOUND_RAW.NETSUITE.EMPLOYEE e on e.id = pc.assigned

WHERE 
    EXISTS (
        SELECT 1
        FROM INBOUND_RAW.NETSUITE.TRANSACTIONSTATUS ts2
        WHERE ts2.TRANTYPE = 'CustInvc'
    )
    AND t.type = 'CustInvc' 
    AND tl.mainline = 'F' 
    AND (tl.creditforeignamount <> 0 OR tl.debitforeignamount <> 0)
    

GROUP BY
    t.id, t.duedate, pc.id, pc.custevent_ar_collection_status, pc.status, pc.assigned, acc.type, e.entityid, c.id
    
;

select * from SB_ERPTEAM.PUBLIC.VW_COLLECTIONS_AMOUNT

;


select 

t.id,
t.type,
pc.id

from INBOUND_RAW.NETSUITE.TRANSACTION t

JOIN INBOUND_RAW.NETSUITE.PHONECALL pc on pc.transaction = t.id

;
describe table INBOUND_RAW.NETSUITE.PHONECALL