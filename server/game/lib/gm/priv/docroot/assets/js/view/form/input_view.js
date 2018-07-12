/**
 * Created by yujian on 17-7-17.
 */
var input_view = {
    'input_list': function (obj_field, type, v) {
        if (v.length > 51) {
            v = v.slice(0, 50) + "......";
        }
        return "<td>" + v + "</td>"
    },
    'input_input': function (obj_field, type, v) {
        return '<th><input type="text" name="' + obj_field.id + '" class="am-form-field" id="' + obj_field.id + '"></th>';
    },
    'input_set': function (obj_field, type, v) {
        return '<div class="am-form-group"><label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label><div class="am-u-sm-9">' +
            '<input type="text" class="tpl-form-input" name=' +
            obj_field.id + ' id=' +
            obj_field.id + '_' +
            type + ' placeholder="' +
            obj_field.placeholder + '" ' +
            obj_field.verify + ' value="' +
            v + '"><small class="am-alert am-alert-danger" style="display: none;">' +
            obj_field.verify_msg + '</small></div></div>';
    },
    'hidden_list': function (obj_field, type, v) {
        return '<th style="display:none;">' + obj_field.v + '</th>';
    },
    'hidden_input': function (obj_field, type, v) {
        return '<th style="display:none;"><input type=\"hidden\" name=' + obj_field.id + ' id=' + obj_field.id + ' value=' + obj_field.v + '></th>';
    },
    'hidden_set': function (obj_field, type, v) {
        return '<input type=\"hidden\" name=' + obj_field.id + ' id=' + obj_field.id + '_' + type + ' value=' + v + '>';
    },

    'undefined_list': function (obj_field, type, v) {
        if (v.length > 51) {
            v = v.slice(0, 50) + "......";
        }
        return "<td>" + v + "</td>"
    },

    'undefined_input': function (obj_field, type, v) {
        return '<th></th>';
    },

    'undefined_set': function (obj_field, type, v) {
        return '';
    }
};