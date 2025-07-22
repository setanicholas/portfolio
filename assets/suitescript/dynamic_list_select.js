/**
 * @NApiVersion 2.x
 * @NScriptType ClientScript
 * @author nicholasseta
 */

define(['N/currentRecord','N/ui/dialog'], function(cr, dialog){

    // ======= CONFIG: one place to edit =======
    // Parent (driver) field:
    var DRIVER = 'custentity_field_x';

    // When DRIVER changes, clear these:
    var RESET_FIELDS = [
        'custentity_field_y',
        'custentity_field_z'
    ];

    // Rules per driver value
    // allow: only these values are allowed (blank always ok)
    // disable: field IDs to gray out & clear
    var RULES = {
        '1': {
            allow: { 'custentity_field_y': ['1','2'], 
            'custentity_field_o':  ['1','2', ] },
            disable: ['custentity_field_n']
        },
        '2': {
            allow: { 'custentity_field_y': ['6','4'] },
            disable: []
        },
        '3': {
            allow: { 'custentity_field_z': ['1','2','3'] },
            disable: ['custentity_field_y']
        }
    };
    // ======= END CONFIG =======

    var _guard = false; // re-entry guard

    function pageInit(){ applyAll(); }

    function fieldChanged(ctx){
        if (ctx.fieldId === DRIVER){
            var rec = cr.get();
            RESET_FIELDS.forEach(function(fid){ setVal(rec, fid, ''); });
            applyAll();
        }
    }

    function validateField(ctx){
        var rec = cr.get();
        var fid = ctx.fieldId;
        var rules = activeRules(rec);
        var allowMap = rules.allow || {};

        // Only care about fields that have an allow-list
        if (!allowMap[fid]) return true;

        var val = asStr(rec.getValue({ fieldId: fid }));
        if (!val) return true; // blanks are fine

        if (allowMap[fid].indexOf(val) === -1){
            // do NOT setValue here = loop risk, just block
            dialog.alert({ title:'Not Allowed', message:'That value isn’t permitted for this field.' });
            return false;
        }
        return true;
    }

    function saveRecord(){
        var rec = cr.get();
        var rules = activeRules(rec);
        var bad = [];

        // Enforce disables & allow lists one last time
        (rules.disable || []).forEach(function(fid){
            if (rec.getValue({ fieldId: fid })) bad.push(fid);
        });
        Object.keys(rules.allow || {}).forEach(function(fid){
            var v = asStr(rec.getValue({ fieldId: fid }));
            if (v && rules.allow[fid].indexOf(v) === -1) bad.push(fid);
        });

        if (bad.length){
            dialog.alert({ title:'Fix Required', message:'Some fields have invalid/disabled values.' });
            return false;
        }
        return true;
    }

    // ---------- Helpers ----------
    function applyAll(){
        if (_guard) return;
        _guard = true;
        try {
            var rec = cr.get();
            var rules = activeRules(rec);

            // First re-enable everything we might manage
            Object.keys(RULES).forEach(function(k){
                (RULES[k].disable || []).forEach(function(fid){
                    disable(rec, fid, false);
                });
            });

            // Now disable current set
            (rules.disable || []).forEach(function(fid){
                disable(rec, fid, true, true);
            });
        } finally {
            _guard = false;
        }
    }

    function activeRules(rec){
        var key = asStr(rec.getValue({ fieldId: DRIVER }));
        return RULES[key] || { allow:{}, disable:[] };
    }

    function disable(rec, fieldId, isDis, clear){
        var f = rec.getField({ fieldId: fieldId });
        if (f){
            f.isDisabled = !!isDis;
            if (isDis && clear && rec.getValue({ fieldId: fieldId })){
                setVal(rec, fieldId, '');
            }
        } else {
            // Optional DOM fallback:
            // try { document.getElementById(fieldId).disabled = !!isDis; } catch(e){}
        }
    }

    function setVal(rec, fieldId, val){
        rec.setValue({ fieldId: fieldId, value: val, ignoreFieldChange: true });
    }

    function asStr(v){ return String(v || ''); }

    return {
        pageInit: pageInit,
        fieldChanged: fieldChanged,
        validateField: validateField,
        saveRecord: saveRecord
    };
});
