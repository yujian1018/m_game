/**
 * Created by yujian on 17-7-17.
 */
var form_view = {
    type_list: "list",
    type_input: "input",
    type_edit: "edit",
    type_add: "add",
    type_set: "set",

    form_view: function (type, obj_field, item) {
        if (obj_field.v == undefined || obj_field.v == null || obj_field.v == '\N') {
            obj_field.v = '';
        }
        var v = "";
        if (item != undefined && item[obj_field.id] != undefined) {
            v = item[obj_field.id];
        } else if (item != undefined && typeof(item) != "object") {
            v = item
        }
        var form_element = obj_field.type;

        if (type == "list") {
            if (obj_field.show_id != undefined) {
                v = item[obj_field.id];
            }
            return view_form_config[form_element + "_list"](obj_field, type, v, item);
        } else if (type == "input") {
            return view_form_config[form_element + "_input"](obj_field, type, v, item);
        } else {
            if (obj_field.edit_type != undefined) {
                form_element = obj_field.edit_type;
            }
            return view_form_config[form_element + "_set"](obj_field, type, v, item);
        }
    },

    'fun_list': function (obj_field, type, v, item) {
        return "<td>" + obj_field.fun(item) + "</td>";
    },
    'fun_input': function (obj_field, type, v) {
        return '<th></th>';
    },
    'fun_set': function (obj_field, type, v) {
        return '<th></th>';
    },
    'null_list': function (obj_field, type, v) {
        return '';
    },
    'null_input': function (obj_field, type, v) {
        return '';
    },
    'null_set': function (obj_field, type, v) {
        return '';
    },
    'per_list': function (obj_field, type, v, item) {
        return "<td>" + math.eval_divide(item[obj_field.tor], item[obj_field.minator], "%") + "%</td>";
    },
    'per_input': function (obj_field, type, v) {
        return '<th></th>';
    },
    'per_set': function (obj_field, type, v) {
        return '<th></th>';
    }
};