/**
 * Created by yujian on 17-7-17.
 */
var img_view = {
    'img_list': function (obj_field, type, v) {
        return "<td><img src='" + v + "' width='132'/></td>";
    },
    'img_input': function (obj_field, type, v) {
        return '<th></th>';
    },
    'img_set': function (obj_field, type, v) {
        return '<div class="am-form-group"><label class="am-u-sm-3 am-form-label">' +
            obj_field.label + '</label> <div class="am-u-sm-9"> <div class="am-form-group am-form-file"> <div class="tpl-form-file-img"> <div class="" id="preview_img_bg"></div> <img id="preview_img"' +
            'src=""></div><button type="button" class="am-btn am-btn-danger am-btn-sm"><i class="am-icon-cloud-upload"></i> 添加' +
            obj_field.label + '</button> <input type="hidden"name="' +
            obj_field.id + '" id="' +
            obj_field.id + '_edit" value = ' + v + '><input id="' +
            obj_field.id + '_img" type="file"  accept="image/*" multiple="" onchange="file.load(this, \'' + obj_field.id + '_edit\', \'preview_img\', \'preview_img_bg\');"></div></div></div><script type="application/javascript">$("#preview_img").attr("src", "' + v + '");</script>';
    }
};