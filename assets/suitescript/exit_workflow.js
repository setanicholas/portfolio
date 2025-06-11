/**
 * @NApiVersion 2.x
 * @NScriptType UserEventScript
 * @NModuleScope SameAccount
 *
 */

define(['N/record', 'N/log', 'N/search'],
    function (record, log, search) {
    
        // ─── CONSTANTS ──────────────────────────────────────────────────────
        var CUSTOM_FIELD_ID   = 'custbody_exit_wf_automation_dummy';
        var KICKOFF_VALUE     = '2';
    
        var FULFILLABLE_TYPES = ['InvtPart','Assembly','Kit'];
        var LOCATION_FIELD_ID = 'location';
        var SUBS_DEFAULT_LOC_FIELD_ID = 'custrecord_default_loc';
    
        var SUB_CASH_ACCT_MAP = { '10':1125,'11':1126,'14':1127,'15':1128,'16':1129,'9':1130 };
        var AR_242            = 242;
    
        var DEFAULT_LOC_CACHE = {};
    
        // ─── MAIN ───────────────────────────────────────────────────────────
        function afterSubmit(ctx) {
            if (ctx.type !== ctx.UserEventType.CREATE) return;
    
            var soId = ctx.newRecord.id;
            var so   = loadSO(soId);
            if (so.getValue(CUSTOM_FIELD_ID) !== KICKOFF_VALUE) return;
    
            var soDate = so.getValue('trandate');
    
            try {
                var fulId = fulfillSO(so, soDate);
                if (fulId) log.audit('Fulfillment created', fulId);
    
                so = loadSO(soId);                              // refresh
                var invId = invoiceSO(so, soDate);
                if (invId) log.audit('Invoice created', invId);
    
                if (invId) {
                    var payId = payInvoice(invId, soDate);
                    if (payId) log.audit('Payment created', payId);
                }
    
                record.submitFields({
                    type  : record.Type.SALES_ORDER,
                    id    : soId,
                    values: (function(v){ v[CUSTOM_FIELD_ID] = '3'; return v; })({})
                });
                log.audit('Automation complete', soId);
    
            } catch (e) {
                log.error('Automation failed', stringify(e));
                throw e;
            }
        }
    
        // ─── HELPERS ────────────────────────────────────────────────────────
        function loadSO(id){
            return record.load({ type:record.Type.SALES_ORDER, id:id, isDynamic:false });
        }
    
        function getDefaultLocForSubs(subsId){
            if (!subsId) return null;
            if (DEFAULT_LOC_CACHE.hasOwnProperty(subsId)) return DEFAULT_LOC_CACHE[subsId];
    
            var locId = null;
            try {
                var subs = record.load({ type:record.Type.SUBSIDIARY, id:subsId, isDynamic:false });
                locId = +subs.getValue(SUBS_DEFAULT_LOC_FIELD_ID) || null;
            } catch(_){}
    
            if (!locId) {
                var res = search.create({
                    type:search.Type.LOCATION,
                    filters:[['subsidiary','anyof',subsId],'and',['isinactive','is','F']],
                    columns:['internalid']
                }).run().getRange({start:0,end:1});
                locId = res && res.length ? +res[0].getValue('internalid') : null;
            }
            DEFAULT_LOC_CACHE[subsId] = locId;
            return locId;
        }
    
        // ─── 1) Fulfillment ────────────────────────────────────────────────
        function fulfillSO(so, soDate){
            var ful;
            try {
                ful = record.transform({
                    fromType:record.Type.SALES_ORDER,
                    fromId  :so.id,
                    toType  :record.Type.ITEM_FULFILLMENT,
                    isDynamic:true
                });
            } catch(_){ return null; }
    
            ful.setValue('trandate', soDate);
    
            var headerLoc = so.getValue(LOCATION_FIELD_ID);
            if (headerLoc && !ful.getValue(LOCATION_FIELD_ID))
                ful.setValue(LOCATION_FIELD_ID, headerLoc);
    
            var fallback = getDefaultLocForSubs(so.getValue('subsidiary'));
    
            var done = 0, lineCount = ful.getLineCount('item');
            for (var i=0;i<lineCount;i++){
                ful.selectLine('item', i);
                var qtyRem = +ful.getCurrentSublistValue('item','quantityremaining')||0;
                var type   = ful.getCurrentSublistValue('item','itemtype');
                if (!(qtyRem>0 && FULFILLABLE_TYPES.indexOf(type)!==-1)){
                    ful.cancelLine('item'); continue;
                }
                ful.setCurrentSublistValue('item','itemreceive',true);
    
                if (!ful.getCurrentSublistValue('item',LOCATION_FIELD_ID)){
                    var soLineLoc = so.getSublistValue('item',LOCATION_FIELD_ID,i);
                    ful.setCurrentSublistValue(
                        'item', LOCATION_FIELD_ID, soLineLoc || headerLoc || fallback);
                }
                ful.commitLine('item'); done++;
            }
            if (!done) return null;
            ful.setValue('shipstatus','C');
            return ful.save({enableSourcing:true, ignoreMandatoryFields:false});
        }
    
        // ─── 2) Invoice (AR 242) ───────────────────────────────────────────
        function invoiceSO(so, soDate){
            if (so.getValue('orderstatus')!=='F') return null;
    
            var inv = record.transform({
                fromType:record.Type.SALES_ORDER,
                fromId  :so.id,
                toType  :record.Type.INVOICE,
                isDynamic:false
            });
            inv.setValue('trandate', soDate);
            inv.setValue('account' , AR_242);
            return inv.save({enableSourcing:true, ignoreMandatoryFields:false});
        }
    
        // ─── 3) Payment (dynamic, AR 242, explicit apply) ─────────────────
        function payInvoice(invId, soDate){
            var pay = record.transform({
                fromType:record.Type.INVOICE,
                fromId  :invId,
                toType  :record.Type.CUSTOMER_PAYMENT,
                isDynamic:true
            });
            pay.setValue('trandate', soDate);
    
            var subsId = pay.getValue('subsidiary');
            var cash   = SUB_CASH_ACCT_MAP[subsId];
            if (cash) pay.setValue('account', cash);
    
            pay.setValue('aracct', AR_242);          // must match invoice
    
            // ---- apply invoice line explicitly ----
            var lineCount = pay.getLineCount('apply'), applied=false;
            for (var i=0;i<lineCount;i++){
                pay.selectLine('apply', i);
                if (+pay.getCurrentSublistValue('apply','internalid') === +invId){
                    pay.setCurrentSublistValue('apply','apply',true);
                    pay.commitLine('apply'); applied=true; break;
                }
            }
            if (!applied) throw new Error('Invoice '+invId+' not on payment apply list.');
    
            return pay.save({enableSourcing:true, ignoreMandatoryFields:false});
        }
    
        function stringify(e){
            try { return JSON.stringify(e); }
            catch(_){ return (e && e.name ? e.name+': ':'')+(e && e.message ? e.message : e); }
        }
    
        return { afterSubmit: afterSubmit };
    });
    
