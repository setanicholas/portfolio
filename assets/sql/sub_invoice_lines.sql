CREATE OR REPLACE PROCEDURE USP_SUBINVOICE_LINES()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

-- Create the SUBINVOICE_LINES table
CREATE OR REPLACE TABLE MY_SCHEMA.PUBLIC.SUBINVOICE_LINES
(
    SubInvoiceLineId            nchar(18), 
    InvoiceLineId               nchar(18), 
    InvoiceLineAmount           decimal(16,2), 
    InvoiceLineQuantity         int,
    InvoiceId                   nvarchar(255),
    ERPInvoiceId                nvarchar(255),
    ERPInvoiceNumber            nvarchar(255), 
    ERPLineId                   int, 
    ERPLineAmount               decimal(16,2),
    SILQuantity                 int, 
    SILSubtotal                 decimal(16,2), 
    SILStartDate                date, 
    SILEndDate                  date,
    CRMInvoiceLineProduct       nchar(18), 
    OrderProductId              nvarchar(255), 
    CRMProductName              nvarchar(510),
    ERPItemName                 nvarchar(510), 
    ERPItemId                   int,
    CRMTaxAmount                decimal(16,4),
    CRMGrossAmount              decimal(16,4),
    CRMTaxRate                  decimal(16,4),
    TaxCodeID                   nvarchar(255),
    TaxCodeName                 nvarchar(255),
    ERPOrderProductID           nvarchar(255),
    ExternalID                  nvarchar(255),
    RevElement                  nvarchar(255),
    RevRecRule                  nvarchar(255),
    CRMTransactionERPId         nvarchar(255),
    InvoiceStatus               nvarchar(255),
    InvoiceLineState            nvarchar(255),
    InvoiceLineNumberType       nvarchar(255),
    OrderProductMissingFlag     nvarchar(255),
    ERPInvoicePostingPeriod     date,
    ItemDescription             nvarchar(1000)
);

-- Insert data into SUBINVOICE_LINES
INSERT INTO MY_SCHEMA.PUBLIC.SUBINVOICE_LINES
(
    SubInvoiceLineId, 
    InvoiceLineId, 
    SILSubtotal, 
    SILQuantity, 
    SILStartDate, 
    SILEndDate,
    OrderProductId,
    CRMTaxAmount,
    CRMGrossAmount,
    CRMTaxRate
)
SELECT 
    s.id AS SubInvoiceLineId,
    s.crm_invoice_line_id,
    s.subtotal,
    s.quantity,
    s.start_date,
    s.end_date,
    s.order_product,
    s.tax_amount,
    CASE 
        WHEN s.tax_amount IS NOT NULL THEN (s.subtotal + s.tax_amount)
        ELSE s.subtotal
    END,
    CASE
        WHEN s.subtotal <> 0 THEN (s.tax_amount / s.subtotal) * 100
        ELSE 0
    END
FROM RAW_DATA.CRM.SUB_INVOICE_LINE s
WHERE EXISTS (
    SELECT crm_invoice_line_id
    FROM RAW_DATA.CRM.SUB_INVOICE_LINE s2
    WHERE s2.crm_invoice_line_id = s.crm_invoice_line_id
    GROUP BY crm_invoice_line_id
    HAVING COUNT(1) > 1
);

-- Update SUBINVOICE_LINES with CRM Invoice and Order details
UPDATE MY_SCHEMA.PUBLIC.SUBINVOICE_LINES
SET 
    InvoiceId = i.crm_erp_id,
    InvoiceLineAmount = l.subtotal,
    InvoiceLineQuantity = l.quantity,
    CRMInvoiceLineProduct = l.product,
    CRMTransactionERPId = i.crm_erp_id,
    ERPInvoicePostingPeriod = ap.startdate
FROM RAW_DATA.CRM.INVOICE i 
JOIN RAW_DATA.CRM.INVOICE_LINE l ON l.crm_invoice_id = i.Id
JOIN RAW_DATA.CRM.ORDER_ITEM oi ON l.order_product_id = oi.Id
JOIN RAW_DATA.ERP.CONTRACT_LINES cl ON cl.externalid = oi.id
JOIN RAW_DATA.CRM.PRODUCT p ON p.Id = oi.product_id
JOIN RAW_DATA.ERP.ITEM it ON it.Id = p.erp_item_id
JOIN RAW_DATA.CRM.ORDERS o ON o.id = i.crm_order_id
JOIN RAW_DATA.CRM.LEGAL_ENTITY le ON le.id = o.Legal_Entity_id
JOIN RAW_DATA.FLAT_FILES.TAX_CODE_SUB tc ON tc.subsidiary_id = le.erp_id
JOIN RAW_DATA.ERP.TRANSACTION t ON CAST(t.id AS nvarchar(255)) = i.crm_erp_id
JOIN RAW_DATA.ERP.ACCOUNTING_PERIOD ap ON ap.id = t.postingperiod
WHERE l.Id = InvoiceLineId;

-- Update SUBINVOICE_LINES with ERP transaction details
UPDATE MY_SCHEMA.PUBLIC.SUBINVOICE_LINES
SET 
    ERPInvoiceId = t.Id,
    ERPInvoiceNumber = t.TranId,
    ERPLineId = l.id,
    ERPLineAmount = (l.netamount + l.quantitybilled),
    InvoiceStatus = t.status
FROM RAW_DATA.ERP.TRANSACTION t
JOIN RAW_DATA.ERP.TRANSACTION_LINE l ON t.Id = l.transaction
JOIN RAW_DATA.ERP.TRANSACTION_ACCOUNTING_LINE ta ON ta.transaction = t.Id AND ta.transactionline = l.Id
JOIN RAW_DATA.ERP.CONTRACT_LINES cl ON cl.externalid = OrderProductId
LEFT JOIN RAW_DATA.ERP.ITEM i ON i.Id = cl.custrecord_item
JOIN RAW_DATA.FLAT_FILES.TAX_CODE_SUB tc ON tc.subsidiary_id = cl.custrecord_subsidiary
WHERE cl.externalid = OrderProductId
  AND t.id = InvoiceId;

-- Update SUBINVOICE_LINES with additional ERP item details
UPDATE MY_SCHEMA.PUBLIC.SUBINVOICE_LINES
SET 
    CRMProductName = i.displayname,
    ERPOrderProductID = cl.name,
    ERPItemName = i.itemid,
    ERPItemId = i.id,
    TaxCodeID = tc.tax_code_internal_id,
    TaxCodeName = tc.tax_code_name,
    ExternalID = cl.externalid,
    RevElement = re.recordnumber,
    RevRecRule = i.revenuerecognitionrule,
    ItemDescription = i.description
FROM RAW_DATA.ERP.CONTRACT_LINES cl
LEFT JOIN RAW_DATA.ERP.ITEM i ON i.Id = cl.custrecord_item
LEFT JOIN RAW_DATA.FLAT_FILES.TAX_CODE_SUB tc ON tc.subsidiary_id = cl.custrecord_subsidiary
LEFT JOIN RAW_DATA.ERP.TRANSACTION_LINE l ON cl.id = l.custcol_reference_contractline
LEFT JOIN RAW_DATA.ERP.REVENUE_ELEMENT re ON cl.custrecord_revenue_element = re.id
WHERE OrderProductId = cl.externalid;

-- Create the InvoiceLines table
CREATE OR REPLACE TABLE MY_SCHEMA.PUBLIC.InvoiceLines
(
    SubInvoiceLineId            nchar(18), 
    InvoiceLineId               nchar(18), 
    InvoiceLineAmount           decimal(16,2), 
    InvoiceLineQuantity         int,
    InvoiceId                   nvarchar(255),
    ERPInvoiceId                nvarchar(255), 
    ERPInvoiceNumber            nvarchar(255), 
    ERPLineId                   int, 
    ERPLineAmount               decimal(16,2),
    SILQuantity                 int, 
    SILSubtotal                 decimal(16,2), 
    SILStartDate                date, 
    SILEndDate                  date,
    CRMInvoiceLineProduct       nchar(18), 
    OrderProductId              nvarchar(255), 
    CRMProductName              nvarchar(510),
    ERPItemName                 nvarchar(510), 
    ERPItemId                   int,
    CRMTaxAmount                decimal(16,4),
    CRMGrossAmount              decimal(16,4),
    CRMTaxRate                  decimal(16,4),
    TaxCodeID                   nvarchar(255),
    TaxCodeName                 nvarchar(255),
    ERPOrderProductID           nvarchar(255),
    ExternalID                  nvarchar(255),
    RevElement                  nvarchar(255),
    RevRecRule                  nvarchar(255),
    CRMTransactionERPId         nvarchar(255),
    InvoiceStatus               nvarchar(255),
    InvoiceLineState            nvarchar(255),
    InvoiceLineNumberType       nvarchar(255),
    OrderProductMissingFlag     nvarchar(255),
    ERPInvoicePostingPeriod     date,
    ItemDescription             nvarchar(1000)
);

-- Insert data into InvoiceLines
INSERT INTO MY_SCHEMA.PUBLIC.InvoiceLines
(
    SubInvoiceLineId, 
    InvoiceLineId, 
    SILSubtotal, 
    SILQuantity, 
    SILStartDate, 
    SILEndDate,
    OrderProductId,
    CRMTaxAmount,
    CRMGrossAmount,
    CRMTaxRate,
    InvoiceLineState
)
SELECT 
    s.id,
    s.id,
    CASE WHEN s.invoice_line_state = 'Merged' THEN 0 ELSE s.subtotal END,
    CASE WHEN s.invoice_line_state = 'Merged' THEN 0 ELSE s.quantity END,
    s.start_date,
    s.end_date,
    s.order_product,
    CASE WHEN s.invoice_line_state = 'Merged' THEN 0 ELSE s.tax_amount END,
    CASE WHEN s.invoice_line_state = 'Merged' THEN 0 
         WHEN s.tax_amount IS NOT NULL THEN (s.subtotal + s.tax_amount)
         ELSE s.total_amount
         END,
    CASE WHEN s.invoice_line_state = 'Merged' THEN 0 
         WHEN s.subtotal <> 0 THEN (s.tax_amount / s.subtotal) * 100
         ELSE 0
         END,
    s.invoice_line_state
FROM RAW_DATA.CRM.INVOICE_LINE s;

-- Update InvoiceLines with CRM Invoice and Order details
UPDATE MY_SCHEMA.PUBLIC.InvoiceLines
SET     
    InvoiceId = CASE
        WHEN TRY_CAST(i.crm_erp_id AS INT) IS NOT NULL THEN CAST(i.crm_erp_id AS INT)
        ELSE NULL
    END,
    InvoiceLineAmount = l.subtotal,
    InvoiceLineQuantity = l.quantity,
    CRMInvoiceLineProduct = l.product,
    CRMTransactionERPId = i.crm_erp_id,
    ERPInvoicePostingPeriod = ap.startdate
FROM RAW_DATA.CRM.INVOICE i 
JOIN RAW_DATA.CRM.INVOICE_LINE l ON l.crm_invoice_id = i.Id
JOIN RAW_DATA.CRM.ORDER_ITEM oi ON l.order_product_id = oi.Id
JOIN RAW_DATA.ERP.CONTRACT_LINES cl ON cl.externalid = oi.id
JOIN RAW_DATA.CRM.PRODUCT p ON p.Id = oi.product_id
JOIN RAW_DATA.ERP.ITEM it ON it.Id = p.erp_item_id
JOIN RAW_DATA.CRM.ORDERS o ON o.id = i.crm_order_id
JOIN RAW_DATA.CRM.LEGAL_ENTITY le ON le.id = o.Legal_Entity_id
JOIN RAW_DATA.FLAT_FILES.TAX_CODE_SUB tc ON tc.subsidiary_id = le.erp_id
JOIN RAW_DATA.ERP.TRANSACTION t ON CAST(t.id AS nvarchar(255)) = i.crm_erp_id
JOIN RAW_DATA.ERP.ACCOUNTING_PERIOD ap ON ap.id = t.postingperiod
WHERE l.Id = InvoiceLineId;

-- Update InvoiceLines with ERP transaction details
UPDATE MY_SCHEMA.PUBLIC.InvoiceLines
SET 
    ERPInvoiceId = t.Id,
    ERPInvoiceNumber = t.TranId,
    ERPLineId = l.id,
    ERPLineAmount = (l.netamount + l.quantitybilled),
    InvoiceStatus = t.status,
    OrderProductMissingFlag = CASE 
                                 WHEN l.custcol_sourceexternalid IS NOT NULL 
                                      AND l.custcol_reference_contractline IS NULL 
                                 THEN '0' 
                                 ELSE '1' 
                               END
FROM RAW_DATA.ERP.TRANSACTION t
JOIN RAW_DATA.ERP.TRANSACTION_LINE l ON t.Id = l.transaction
JOIN RAW_DATA.ERP.TRANSACTION_ACCOUNTING_LINE ta ON ta.transaction = t.Id AND ta.transactionline = l.Id
JOIN RAW_DATA.ERP.CONTRACT_LINES cl ON cl.externalid = l.custcol_sourceexternalid
LEFT JOIN RAW_DATA.ERP.ITEM i ON i.Id = cl.custrecord_item
JOIN RAW_DATA.FLAT_FILES.TAX_CODE_SUB tc ON tc.subsidiary_id = cl.custrecord_subsidiary
WHERE cl.externalid = OrderProductId
  AND t.id = InvoiceId;

-- Update InvoiceLines with additional ERP item details
UPDATE MY_SCHEMA.PUBLIC.InvoiceLines
SET         
    CRMProductName = i.displayname,
    ERPOrderProductID = cl.name,
    ERPItemName = i.itemid,
    ERPItemId = i.id,
    TaxCodeID = tc.tax_code_internal_id,
    TaxCodeName = tc.tax_code_name,
    ExternalID = cl.externalid,
    RevElement = re.recordnumber,
    RevRecRule = i.revenuerecognitionrule,
    ItemDescription = i.description
FROM RAW_DATA.ERP.CONTRACT_LINES cl
LEFT JOIN RAW_DATA.ERP.ITEM i ON i.Id = cl.custrecord_item
LEFT JOIN RAW_DATA.FLAT_FILES.TAX_CODE_SUB tc ON tc.subsidiary_id = cl.custrecord_subsidiary
LEFT JOIN RAW_DATA.ERP.TRANSACTION_LINE l ON cl.id = l.custcol_reference_contractline
LEFT JOIN RAW_DATA.ERP.REVENUE_ELEMENT re ON cl.custrecord_revenue_element = re.id
WHERE OrderProductId = cl.externalid;

-- Update InvoiceLines for line number type
UPDATE MY_SCHEMA.PUBLIC.InvoiceLines
SET 
    InvoiceLineNumberType = CASE WHEN ERPLineId IS NOT NULL AND InvoiceLineState = 'Regular' THEN '1' ELSE '0' END;

-- Combine InvoiceLines and SUBINVOICE_LINES into the SIL table
CREATE OR REPLACE TABLE MY_SCHEMA.PUBLIC.SIL
(
    SubInvoiceLineId            nchar(18), 
    InvoiceLineId               nchar(18), 
    InvoiceLineAmount           decimal(16,2), 
    InvoiceLineQuantity         int,
    InvoiceId                   nvarchar(255),
    ERPInvoiceId                nvarchar(255),
    ERPInvoiceNumber            nvarchar(255), 
    ERPLineId                   int, 
    ERPLineAmount               decimal(16,2),
    SILQuantity                 int, 
    SILSubtotal                 decimal(16,2), 
    SILStartDate                date, 
    SILEndDate                  date,
    CRMInvoiceLineProduct       nchar(18), 
    OrderProductId              nvarchar(255), 
    CRMProductName              nvarchar(510),
    ERPItemName                 nvarchar(510), 
    ERPItemId                   int,
    CRMTaxAmount                decimal(16,4),
    CRMGrossAmount              decimal(16,4),
    CRMTaxRate                  decimal(16,4),
    TaxCodeID                   nvarchar(255),
    TaxCodeName                 nvarchar(255),
    ERPOrderProductID           nvarchar(255),
    ExternalID                  nvarchar(255),
    RevElement                  nvarchar(255),
    RevRecRule                  nvarchar(255),
    CRMTransactionERPId         nvarchar(255),
    InvoiceStatus               nvarchar(255),
    InvoiceLineState            nvarchar(255),
    InvoiceLineNumberType       nvarchar(255),
    OrderProductMissingFlag     nvarchar(255),
    ERPInvoicePostingPeriod     date,
    ItemDescription             nvarchar(1000)
);

INSERT INTO MY_SCHEMA.PUBLIC.SIL
SELECT
    *
FROM MY_SCHEMA.PUBLIC.InvoiceLines
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM MY_SCHEMA.PUBLIC.SUBINVOICE_LINES
        WHERE CONCAT(InvoiceId, ERPOrderProductID) = CONCAT(InvoiceLines.InvoiceId, InvoiceLines.ERPOrderProductID)
    )
UNION
SELECT
    *
FROM MY_SCHEMA.PUBLIC.SUBINVOICE_LINES;

-- Update SIL with the latest invoice status from ERP transactions
UPDATE MY_SCHEMA.PUBLIC.SIL
SET InvoiceStatus = t.status
FROM RAW_DATA.ERP.TRANSACTION t
WHERE t.id = InvoiceId;

-- Create the SIL_IMPORT table for reporting
CREATE OR REPLACE TABLE MY_SCHEMA.PUBLIC.SIL_IMPORT AS
SELECT
    ERPOrder
