/**
 * @NApiVersion 2.x
 * @NScriptType ScheduledScript
 * @Author Nick Seta
 * @Description Runs once per month to update all customers with new subsidiaries to prevent sync errors
 */

define(['N/search', 'N/record', 'N/email', 'N/runtime'],
    function(search, record, email, runtime) {

        function updateCustomers(context) {

            var searchResults = search.create({
                type: "subsidiary",
                filters: [
                    ['addNewCustomer', 'is', 'Yes']
                ],
                columns: [
                    search.createColumn({ name: "internalid", label: "internalId" }),
                    search.createColumn({ name: "custrecord_scg_add_to_new_cust", label: "addToNewCustomer" })
                ]
            });

            var resultRange = searchResults.run().getRange({
                start: 0,
                end: 1000
            });

            var resultLength = resultRange.length;

            if (resultLength > 0) {
                log.debug('Search Results Found', 'SUCCESS');


                for (var x = 0; x < resultLength; x++) {
                    var internalId = resultRange[x].getValue({
                        name: 'internalid'
                    });

                    // Perform actions with the internalId, such as updating customers
                    // ...

                }

                log.debug('Sub Internal ID', internalId);
            } else {
                log.debug('Search Results', 'No results found.');
            }
        }

        return {
            updateCustomers: updateCustomers
        };
    });
