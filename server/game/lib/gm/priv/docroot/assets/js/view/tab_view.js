/**
 * Created by yujian on 17-5-24.
 */
var tab_view = {
    set_table: function (name, title) {
        $(".tpl-left-nav-menu a").removeClass("active");
        config.tab_name = name;
        view_mgr.obj_view(name, title);
        $("#a_" + name).addClass("active");
        $("#a_" + name).parent("li").parent("ul").siblings("a").addClass("active");
    },

    table: function (tab_name, title_name) {
        var obj = config.obj();
        if (tab_name == "" || obj == undefined) {
            $("#content_tab_list").html("功能未开放！");
            $("#content_title").html(title_name);
        } else {
            tab_config_op.reset_op();
            var html = "";
            html += '<div style="margin-bottom: 20px;overflow: hidden;"><div class="am-cf">' + btns_view.load_btns(btns_view.type_once, obj.all_pms) + '</div></div>';

            html += tab_tpl.table(obj);

            $("#content_tab_list").html(html);
            $("#content_tab_list").show();
            $("#content_title").html(title_name);
            $("#content_tab_add").hide();
            $("#content_tab_edit").hide();
            if (tab_name == "server_list") {
                sys_handler.game_list_info();
            } else {
                // tab_sproto.tab_list();
            }

        }
    },

    content_tab_add: function () {
        $("#content_tab_list").hide();
        $("#content_tab_edit").hide();
        var obj = config.obj();
        var form_add = "";
        for (var i = 0; i < obj.tab_record.length; i++) {
            if (obj.tab_record[i].id == obj.tree_id) {
                var item;
                if ($("#" + obj.tree_id).val() == "") {
                    item = tab_config_op.edit_tree_default_v;
                } else {
                    item = $("#" + obj.tree_id).val();
                }
                form_add += tab_tpl.form_edit(obj.tab_record[i], "edit", item);

            } else if (obj.tab_record[i].type == "select" && typeof((obj.tab_record[i].options) == "string")) {
                form_add += tab_tpl.form_edit(obj.tab_record[i], "edit", obj.tab_record[i].v);
            } else {
                form_add += tab_tpl.form_edit(obj.tab_record[i], "add");
            }
        }
        var html = '<div class="tpl-form-body tpl-form-line"><form class="am-form tpl-form-line-form" id="form_add">' + form_add +
            '<div class="am-form-group"><div class="am-u-sm-9 am-u-sm-push-3">' +
            '<button type="submit" class="am-btn am-btn-primary tpl-btn-bg-color-success">提交</button>&nbsp;&nbsp;&nbsp;' +
            '<button type="button" class="am-btn am-btn-default" onclick="tab_tpl.form_cancel();">返回</button></div></div></form></div>';

        $("#content_tab_add").html(html);
        $("#content_tab_add").show();
        $("#content_title").html("添加");

        tab_view.validator("#form_add", function () {
            tab_handler.tab_add();
        });
    },


    tab_set_view: function (state_key, state, id) {
        obj = config.obj();
        var field_id = "", field_state, edit_tr = "";

        $.each(obj.tab_record, function (i, item) {
            if (item.id == obj.key) {
                field_id = item;
            }
        });
        field_state = tab_record.get_state(state_key, obj);
        edit_tr += tab_input_type['hidden']("set", field_id, id);
        edit_tr += tab_input_type['select']("set", field_state, state);

        var html = '<form class="am-form tpl-form-line-form" id="form_set_state" style="min-height:200px;">' + edit_tr +
            '<div class="am-form-group">' +
            '<div class="am-u-sm-9 am-u-sm-push-3">' +
            '<button type="button" class="am-btn am-btn-primary tpl-btn-bg-color-success" onclick="tab_sproto.tab_set()">提交</button></div></div></form>';
        $("#alert_content").html(html);
        $("#alert_title").html("状态修改");
        $("#error_bg").show();
        $("#alert_form").show();
    },


    tab_state_cancle: function () {
        $("#error_bg").hide();
        $("#alert_form").hide();
    },


    validator: function (form_id, sucfun) {
        $('' + form_id + '').validator({
            onValid: function (validity) {
                $(validity.field).closest('.am-form-group').find('.am-alert').hide();
            },
            onInValid: function (validity) {
                var $field = $(validity.field);
                var $alert = $field.closest('.am-form-group').find('.am-alert');
                // 使用自定义的提示信息 或 插件内置的提示信息
                var msg = $field.data('validationMessage') || this.getValidationMessage(validity);
                $alert.html(msg).show();
            },
            submit: function () {
                var formValidity = this.isFormValid();
                if (formValidity) {
                    sucfun();
                } else {
                    console.log('验证不成功')
                }
                return false;
            }
        });
    }
};
