/**
 * Created by yujian on 17-7-17.
 */
var textarea_view = {
    'textarea_list': function (obj_field, type, v) {
        if (v.length > 51) {
            v = v.slice(0, 50) + "......";
        }
        return "<td>" + v + "</td>"
    },
    'textarea_input': function (obj_field, type, v) {
        return "<td>" + v + "</td>"
    },
    'textarea_set': function (obj_field, type, v) {
        v = url.html_decode(v);

        return '<div class="am-form-group"><label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label><div class="am-u-sm-9">' +
            '<textarea  rows="10" id=' +
            obj_field.id + '_' + type + '_1 name=' +
            obj_field.id + ' placeholder="' +
            obj_field.placeholder + '" ' +
            obj_field.verify + '>' +
            v + '</textarea><small class="am-alert am-alert-danger" style="display: none;">' +
            obj_field.verify_msg + '</small></div></div>';
    },

    'editor_list': function (obj_field, type, v) {
        if (v.length > 51) {
            v = v.slice(0, 50) + "......";
            v = v.replace(/</g, "&lt;");
            v = v.replace(/>/g, "&gt;");
        }
        return "<td>" + v + "</td>"
    },
    'editor_input': function (obj_field, type, v) {
        return "<td></td>"
    },
    'editor_set': function (obj_field, type, v) {
        v = url.html_decode(v);
        return '<div class="am-form-group"><label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label><div class="am-u-sm-9">' +
            '<script type="text/plain" id=' + obj_field.id + '_' + type + ' style="width:1000px;max-height:500px;height:500px;overflow: auto" name=' + obj_field.id + '></script>' +
            '<script type="text/javascript">var um = UM.getEditor("' + obj_field.id + '_' + type + '",{toolbar:[\'undo redo | bold italic underline |forecolor backcolor | removeformat |\', \'insertorderedlist insertunorderedlist | cleardoc paragraph | fontsize\' , \'| justifyleft justifycenter justifyright justifyjustify |\', \'link unlink\', \'| horizontal preview fullscreen\']});' +
            'UM.getEditor("' + obj_field.id + '_' + type + '").setContent(\'' + v + '\');UM.clearCache("' + obj_field.id + '_' + type + '");</script>' +
            '<small class="am-alert am-alert-danger" style="display: none;">' +
            obj_field.verify_msg + '</small></div></div>';
    }
};