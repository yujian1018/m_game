/**
 * Created by yujian on 17-7-17.
 * times_diff_day = "reset"||"yesterday"||"today"
 */
var datepicker_view = {
    'times_list': function (obj_field, type, v) {
        return "<td>" + time_lib.now_to_times(v) + "</td>"
    },
    'times_input': function (obj_field, type, v) {
        return form_datepicker_view.times(obj_field.id, obj_field.times_diff_day);
    },
    'times_set': function (obj_field, type, v) {
        if (v != undefined && v != 0) {
            v = time_lib.now_to_times(v);
        }
        return form_datepicker_view.times_edit(obj_field.label, obj_field.id + '_' + type, obj_field.id,
            obj_field.placeholder, v, obj_field.verify, obj_field.verify_msg, "", obj_field.times_diff_day);
    },
    'datetime_list': function (obj_field, type, v) {
        return "<td>" + time_lib.now_to_times(v) + "</td>"
    },
    'datetime_input': function (obj_field, type, v) {
        return form_datepicker_view.date_time(obj_field.id, obj_field.times_diff_day);
    },
    'datetime_set': function (obj_field, type, v) {
        return form_datepicker_view.times_edit(obj_field.label, obj_field.id + '_' + type, obj_field.id,
            obj_field.placeholder, v, obj_field.verify, obj_field.verify_msg, "", obj_field.times_diff_day);
    },

    'date_list': function (obj_field, type, v) {
        return "<td>" + time_lib.now_to_times(v) + "</td>"
    },
    'date_input': function (obj_field, type, v) {
        return form_datepicker_view.date(obj_field.id, obj_field.times_diff_day);
    },
    'date_set': function (obj_field, type, v) {
        return form_datepicker_view.times_edit(obj_field.label, obj_field.id + '_' + type, obj_field.id,
            obj_field.placeholder, v, obj_field.verify, obj_field.verify_msg, '{format: \'YYYY-MM-DD\'}', obj_field.times_diff_day);
    }
};

var form_datepicker_view = {
    'date': function (id, times_diff_day) {
        if (times_diff_day != null) {
            to_date = 'var date = time_lib.to_date(' +
                times_diff_day + ');var $new_date = $("#' + id + '").datetimepicker({format: \'YYYY-MM-DD\'});$new_date.data("DateTimePicker").date(date);';
        } else {
            to_date = '$("#' + id + '").datetimepicker({format: \'YYYY-MM-DD\'});';
        }
        return '<th><input type="text" name="' + id + '" class="am-form-field" id="' + id + '">' +
            '<script type="application/javascript">' + to_date + '</script></th>';
    },
    'date_time': function (id, times_diff_day) {
        var to_date = "";
        if (times_diff_day != null) {
            to_date = 'var date = time_lib.to_date(' +
                times_diff_day + ');var $new_date = $("#' + id + '").datetimepicker();$new_date.data("DateTimePicker").date(date);';
        } else {
            to_date = '$("#' + id + '").datetimepicker();';
        }
        return '<th><input type="text" name="' + id + '" class="am-form-field" id="' +
            id + '"><script type="application/javascript">' + to_date + '</script></th>';
    },
    'times': function (id, times_diff_day) {
        var to_date = "";
        if (times_diff_day != null) {
            to_date = 'var date = time_lib.to_date(' +
                times_diff_day + ');var $new_date = $("#' + id + '_begin").datetimepicker();$new_date.data("DateTimePicker").date(date);';
        } else {
            to_date = '$("#' + id + '_begin").datetimepicker();';
        }
        return '<th><input type="text" name="' +
            id + '_begin" class="am-form-field date" id="' +
            id + '_begin"> <input type="text" name="' +
            id + '_end" class="am-form-field date" id="' +
            id + '_end">' +
            '<script type="application/javascript">$("#' +
            id + '_end").datetimepicker();' + to_date + '</script></th>';
    },
    'times_edit': function (label, id, name, placeholder, value, verify, verify_msg, arg, times_diff_day) {
        var to_date = "";
        if (times_diff_day != null) {
            to_date = 'var date = time_lib.to_date(' +
                times_diff_day + ');var $reset_date = $("#' + id + '").datetimepicker(' +
                arg + ');$reset_date.data("DateTimePicker").date(date);';
        }
        return '<div class="am-form-group"><label class="am-u-sm-3 am-form-label">' +
            label + '</label><div class="am-u-sm-9"><input type="text" id=' +
            id + ' name=' +
            name + ' class="am-form-field tpl-form-no-bg" placeholder="' +
            placeholder + '" ' +
            verify + ' value="' +
            value + '"><small class="am-alert am-alert-danger" style="display: none;">' +
            verify_msg + '</small><script type="application/javascript">var $reset_date = $("#' + id + '").datetimepicker(' + arg + ');' +
            to_date + '</script></div></div>';
    }
};