/**
 * @NApiVersion 2.x
 * @NScriptType Restlet
 * @NModuleScope Public
 */
define(['N/search'], function (search) {
    function doGet(context) {
        try {
            // 1) Load Saved Search by ID
            var mySearch = search.load({
                id: '00000' // Replace with your Saved Search ID
            });

            // 2) Run Search & Gather Results
            var resultsArray = [];
            var pagedData = mySearch.runPaged({ pageSize: 1000 });

            // Loop through all pages of results
            for (var i = 0; i < pagedData.pageRanges.length; i++) {
                var page = pagedData.fetch({ index: i });
                page.data.forEach(function (result) {
                    // Gather all columns dynamically
                    var columns = result.columns;
                    var resultObj = {};

                    columns.forEach(function (col) {
                        var colLabel = col.label || col.name;
                        resultObj[colLabel] = result.getValue(col);
                    });

                    resultsArray.push(resultObj);
                });
            }

            return resultsArray;

        } catch (e) {
            return { error: e.message };
        }
    }

    return {
        get: doGet
    };
});

