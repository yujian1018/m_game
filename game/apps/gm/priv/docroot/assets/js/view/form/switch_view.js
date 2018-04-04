/**
 * Created by yujian on 17-7-17.
 */
var switch_view = {
    'switch_list': function (obj_field, type, v) {
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
    'switch_input': function (obj_field, type, v) {
        return '<th></th>';
    },
    'switch_set': function (obj_field, type, v) {
        var check = '';
        if (v == "1") {
            check = 'checked=""';
        }
        return ' <div class="am-form-group"><label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label><div class="am-u-sm-9"><div class="tpl-switch"><input type="checkbox" class="ios-switch bigswitch tpl-switch-btn"  ' +
            check + ' id="' +
            obj_field.id + '" name="' +
            obj_field.id + '"><div class="tpl-switch-btn-view"><div></div></div><small class="am-alert am-alert-danger" style="display: none;">' +
            obj_field.verify_msg + '</small></div></div><script type="application/javascript">$(".tpl-switch").find(".tpl-switch-btn-view").on("click", function() {$(this).prev(".tpl-switch-btn").prop("checked", function() {if ($(this).is(":checked")) {return false} else {return true}})});</script> </div>';
    }
};