/**
 * Created by yujian on 17-7-17.
 */
var checkbox_view = {
    'checkbox_list': function (obj_field, type, v) {
        return "<td style=\"display:none;\"></td>"
    },
    'checkbox_input': function (obj_field, type, v) {
        return '<td style=\"display:none;\"></td>';
    },
    'checkbox_set': function (obj_field, type, v) {
        var html = "", checobox_list = v.split(",");
        for (var i = 0; i < obj_field.options.length; i++) {
            var is_checkbox = false;

            k = obj_field.options[i][0];
            v = obj_field.options[i][1];
            $.each(checobox_list, function (i, v_key) {
                if (v_key == k) {
                    is_checkbox = true;
                }
            });
            if (is_checkbox) {
                html += '<label class="am-checkbox-inline"><input type="checkbox" name="' + obj_field.id + '" value="' + k + '" checked="checked" ' + verify + '>' + v + '</label>';
            } else {
                html += '<label class="am-checkbox-inline"><input type="checkbox" name="' + obj_field.id + '" value="' + k + '" ' + verify + '>' + v + '</label>';
            }
        }
        return '<div class="am-form-group"> <label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label> <div class="am-u-sm-9">' +
            html + '<small class="am-alert am-alert-danger" style="display: none;">' +
            obj_field.verify_msg + '</small></div></div>';
    }
};