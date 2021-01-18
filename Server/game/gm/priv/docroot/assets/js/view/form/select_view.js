/**
 * Created by yujian on 17-7-17.
 */
var select_view = {
    'select_list': function (obj_field, type, v) {
        var is_member = false;
        var options = new Array();
        if (typeof(obj_field.options) == "function") {
            options = obj_field.options_fun;
        }else{
            options = obj_field.options;
        }
        for (var n = 0; n < options.length; n++) {
            if (v == options[n][0]) {
                is_member = true;
                return "<td>" + options[n][1] + "</td>";
            }
        }
        //遍历配置表，如果返回值在配置表之外，直接显示
        if (!is_member) {
            if (v == "undefined") {
                return '<th></th>';
            } else {
                return "<td>" + v + "</td>";
            }
        }
    },
    'select_input': function (obj_field, type, v) {
        var html = "", options = new Array();
        if (typeof(obj_field.options) == "function") {
            options = obj_field.options_fun;
        }else{
            options = obj_field.options;
        }
        for (var i = 0; i < options.length; i++) {
            html += "<option value=\"" + options[i][0] + "\">" + options[i][1] + "</option>";
        }
        return '<th><select name="' +
            obj_field.id + '" id="' +
            obj_field.id + '" ' + obj_field.verify + '>' +
            html + '</select><script type="application/javascript">$("#' +
            obj_field.id + '").selected({btnSize: \'xs\'});</script></th>';
    },
    'select_set': function (obj_field, type, v) {
        var html = "", options = new Array();
        if (typeof(obj_field.options) == "function") {
            options = obj_field.options_fun;
        }else{
            options = obj_field.options;
        }
        for (var i = 0; i < options.length; i++) {
            if (v == options[i][0]) {
                html += "<option value=\"" + options[i][0] + "\" selected>" + options[i][1] + "</option>";
            } else {
                html += "<option value=\"" + options[i][0] + "\">" + options[i][1] + "</option>";
            }
        }
        return '<div class="am-form-group"> <label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label> <div class="am-u-sm-9"><select id="' +
            obj_field.id + '_' + type + '" name="' +
            obj_field.id + '" ' + obj_field.verify + '>' +
            html + ' </select> <small class="am-alert am-alert-danger" style="display: none;">' +
            obj_field.verify_msg + '</small><script type="application/javascript">$("#' +
            obj_field.id + '_' + type + '").selected({btnSize: \'xs\'});</script></div></div>';
    },

    'select_2_list': function (obj_field, type, v) {
        var is_member = false;
        for (var n = 0; n < obj_field.options.length; n++) {
            if (v == obj_field.options[n][0]) {
                is_member = true;
                return "<td>" + obj_field.options[n][1] + "</td>";
            }
        }
        //遍历配置表，如果返回值在配置表之外，直接显示
        if (!is_member) {
            if (v == "undefined") {
                return '<th></th>';
            } else {
                return "<td>" + v + "</td>";
            }
        }
    },
    'select_2_input': function (obj_field, type, v) {
        return '<th></th>';
    },
    'select_2_set': function (obj_field, type, v) {
        var html = "";
        for (var i = 0; i < obj_field.options.length; i++) {
            if (v == obj_field.options[i][0]) {
                html += "<option value=\"" + obj_field.options[i][0] + "\" selected>" + obj_field.options[i][1] + "</option>";
            } else {
                html += "<option value=\"" + obj_field.options[i][0] + "\">" + obj_field.options[i][1] + "</option>";
            }
        }
        return '<div class="am-form-group"> <label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label> <div class="am-u-sm-9"><select id="' +
            obj_field.id + '_' + type + '" name="' +
            obj_field.id + '" ' + obj_field.verify + '>' +
            html + ' </select> <small class="am-alert am-alert-danger" style="display: none;">' +
            obj_field.verify_msg + '</small><script type="application/javascript">$("#' +
            obj_field.id + '_' + type + '").selected({btnSize: \'xs\'});</script></div></div>';
    },

    'select_3_list': function (obj_field, type, v) {
        var is_member = false;
        for (var n = 0; n < obj_field.options.length; n++) {
            if (v == obj_field.options[n][0]) {
                is_member = true;
                return "<td>" + obj_field.options[n][1] + "</td>";
            }
        }
        if (!is_member) {
            if (v == "undefined") {
                return '<th></th>';
            } else {
                return "<td>" + v + "</td>";
            }
        }
    },
    'select_3_input': function (obj_field, type, v) {
        var options_type = 5;
        if (obj_field.id == "job_position") {
            options_type = 5;
        } else if (obj_field.id == "cityid") {
            options_type = 4;
        }
        var html = "";
        for (var i = 0; i < obj_field.options.length; i++) {
            if (obj_field.options[i][0] == "") {
                html += "<option>" + obj_field.options[i][1] + "</option>";
            } else {
                html += "<option value=\"" + obj_field.options[i][0] + "\">" + obj_field.options[i][1] + "</option>";
            }
        }
        return '<th><select id="' + obj_field.id + '_3" data-am-selected="{searchBox: 1}">' + html + '</select>&nbsp;' +
            '<select  id="' + obj_field.id + '_2" data-am-selected="{searchBox: 1}"></select>&nbsp;' +
            '<select name="' + obj_field.id + '" id="' + obj_field.id + '" ' + obj_field.verify + '  data-am-selected="{searchBox: 1}"></select>' +
            '<script type="application/javascript">' +
            '$("#' + obj_field.id + '").selected({btnSize: \'xs\'});' +
            '$("#' + obj_field.id + '_2").selected({btnSize: \'xs\'});' +
            '$("#' + obj_field.id + '_3").selected({btnSize: \'xs\'});' +
            '$("#' + obj_field.id + '_3").on("change", function () {tab_options_ex.options_level = 2;proto_ex.get_options(' + options_type + ', $("#' + obj_field.id + '_3").val());$("#' + obj_field.id + '_2").html("");$.each(tab_options_ex.options_3_2, function (i, item) {$("#' + obj_field.id + '_2").append("<option value=" + item[0] + ">" + item[1] + "</option>");})});' +
            '$("#' + obj_field.id + '_2").on("change", function () {tab_options_ex.options_level = 3;proto_ex.get_options(' + options_type + ', $("#' + obj_field.id + '_2").val());$("#' + obj_field.id + '").html("");$.each(tab_options_ex.options_3_1, function (i, item) {$("#' + obj_field.id + '").append("<option value=" + item[0] + ">" + item[1] + "</option>");})});' +
            '</script></th>';
    },
    'select_3_set': function (obj_field, type, v, item) {
        var options_type = 5;
        if (obj_field.id == "job_position") {
            options_type = 5;
        } else if (obj_field.id == "cityid") {
            options_type = 4;
        }
        var value = "", value2 = "", v3 = "", v2 = "";
        if (v != "") {
            var values = item[obj_field.id + "_des"].split("-");
            value2 = values[1];
            value = values[2];
            v3 = item[obj_field.id + "_3"];
            v2 = item[obj_field.id + "_2"];
        }

        var html = "";
        for (var i = 0; i < obj_field.options.length; i++) {
            if (v3 == obj_field.options[i][0]) {
                html += "<option value=\"" + obj_field.options[i][0] + "\" selected>" + obj_field.options[i][1] + "</option>";
            } else {
                html += "<option value=\"" + obj_field.options[i][0] + "\">" + obj_field.options[i][1] + "</option>";
            }
        }
        return '<div class="am-form-group"> <label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label> <div class="am-u-sm-9">' +
            '<select id="' + obj_field.id + '_3_' + type + '" data-am-selected="{searchBox: 1}">' + html + ' </select>&nbsp;' +
            '<select id="' + obj_field.id + '_2_' + type + '" data-am-selected="{searchBox: 1}"></select>&nbsp;' +
            '<select name="' + obj_field.id + '" id="' + obj_field.id + '_' + type + '" ' + obj_field.verify + ' data-am-selected="{searchBox: 1}"></select>' +
            '<small class="am-alert am-alert-danger" style="display: none;">' + obj_field.verify_msg + '</small>' +
            '<script type="application/javascript">' +
            '$("#' + obj_field.id + '_3_' + type + '").selected({btnSize: \'xs\'});' +
            '$("#' + obj_field.id + '_2_' + type + '").selected({btnSize: \'xs\'});' +
            '$("#' + obj_field.id + '_' + type + '").selected({btnSize: \'xs\'});' +
            '$("#' + obj_field.id + '_2_' + type + '").append("<option value=' + v2 + '>' + value2 + '</option>");' +
            '$("#' + obj_field.id + '_' + type + '").append("<option value=' + v + '>' + value + '</option>");' +
            '$("#' + obj_field.id + '_3_' + type + '").on("change", function () {tab_options_ex.options_level = 2;proto_ex.get_options(' + options_type + ', $("#' + obj_field.id + '_3_' + type + '").val());$("#' + obj_field.id + '_2_' + type + '").html("");$.each(tab_options_ex.options_3_2, function (i, item) {$("#' + obj_field.id + '_2_' + type + '").append("<option value=" + item[0] + ">" + item[1] + "</option>");})});' +
            '$("#' + obj_field.id + '_2_' + type + '").on("change", function () {tab_options_ex.options_level = 3;proto_ex.get_options(' + options_type + ', $("#' + obj_field.id + '_2_' + type + '").val());$("#' + obj_field.id + '_' + type + '").html("");$.each(tab_options_ex.options_3_1, function (i, item) {$("#' + obj_field.id + '_' + type + '").append("<option value=" + item[0] + ">" + item[1] + "</option>");})});' +
            '</script></div></div>';
    }
};