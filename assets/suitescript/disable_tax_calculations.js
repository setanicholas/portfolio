/**
 * @NApiVersion 2.x
 * @NScriptType UserEventScript
 */
define(['N/record', 'N/runtime', 'N/search', 'N/log'], function(record, runtime, search, log) {
    function beforeSubmit(context) {
        var newRecord = context.newRecord; // Get the new record
        var disableTaxCalc = true; // Always set to true initially

        if (context.type === context.UserEventType.CREATE) {
            // If the record is new, set disableTaxCalc to false
            disableTaxCalc = false;
            log.debug({
                title: 'Disable Tax Calculation',
                details: 'Record is new, disableTaxCalc set to false'
            });
        } else if (context.type === context.UserEventType.EDIT) {
            var oldRecord = context.oldRecord;

            // Retrieve the 'total' field values for new and old records
            var amountNewRecord = newRecord.getValue({ fieldId: 'total' });
            var amountOldRecord = oldRecord ? oldRecord.getValue({ fieldId: 'total' }) : null;

            // Retrieve the 'istaxable' field values for new and old records
            var isTaxableNew = newRecord.getValue({ fieldId: 'istaxable' });
            var isTaxableOld = oldRecord ? oldRecord.getValue({ fieldId: 'istaxable' }) : null;

            // Retrieve the posting period ID
            var postingPeriodId = newRecord.getValue({ fieldId: 'postingperiod' });
            var isPeriodOpen = checkIfPeriodIsOpen(postingPeriodId);

            log.debug({
                title: 'Record Values',
                details: 'isPeriodOpen: ' + isPeriodOpen +
                         ', amountNewRecord: ' + amountNewRecord +
                         ', amountOldRecord: ' + amountOldRecord +
                         ', isTaxableNew: ' + isTaxableNew +
                         ', isTaxableOld: ' + isTaxableOld
            });

            // Check if the posting period is open
            if (isPeriodOpen) {
                // Check if amount or taxable status has changed and taxable is true on new record
                if ((amountNewRecord != amountOldRecord || isTaxableNew != isTaxableOld) && isTaxableNew) {
                    disableTaxCalc = false;
                    log.debug({
                        title: 'Disable Tax Calculation',
                        details: 'Conditions met, disableTaxCalc set to false'
                    });
                }
            }
        }

        // Log the final value of disableTaxCalc
        log.debug({
            title: 'Final Disable Tax Calculation Value',
            details: 'disableTaxCalc: ' + disableTaxCalc
        });

        // **Added log statement here**
        log.debug({
            title: 'Setting Disable Tax Calculation Field',
            details: 'Setting custbody_ava_disable_tax_calculation to: ' + disableTaxCalc
        });

        // Set the 'custbody_ava_disable_tax_calculation' field accordingly using boolean value
        newRecord.setValue({
            fieldId: 'custbody_ava_disable_tax_calculation',
            value: disableTaxCalc // Use boolean true or false
        });
    }

    function checkIfPeriodIsOpen(postingPeriodId) {
        var isOpen = false;
        if (postingPeriodId) {
            try {
                // Lookup the accounting period's 'closed' field
                var periodFields = search.lookupFields({
                    type: 'accountingperiod',
                    id: postingPeriodId,
                    columns: ['periodname', 'closed']
                });

                // The 'closed' field is true if the period is closed
                isOpen = !periodFields.closed;
                log.debug({
                    title: 'Accounting Period Fields',
                    details: 'Period Name: ' + periodFields.periodname + ', Closed: ' + periodFields.closed
                });
            } catch (e) {
                log.error({
                    title: 'Error Retrieving Accounting Period',
                    details: e
                });
                // Default to false if there's an error
                isOpen = false;
            }
        }
        return isOpen;
    }

    return {
        beforeSubmit: beforeSubmit
    };
});
