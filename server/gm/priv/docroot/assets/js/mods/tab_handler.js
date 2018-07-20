var tab_handler = {
    tab_list: function () {
        var arg = $("#form_list").serialize();
        tab_sproto._P_tab_list("tab_name=" + config.get_tab_name() + "&" + url.html_encode(arg), function (data) {
            $("#content_tab_list").show();
            $("#content_tab_add").hide();
            $("#content_tab_edit").hide();
            tab_tpl.table_list(data);
        });


    },

    tab_add: function (func) {
        var arg = $("#form_add").serialize();
        tab_sproto._P_tab_add("tab_name=" + config.get_tab_name() + "&" + url.html_encode(arg), function (data) {
            $("#content_tab_add").hide();
            $("#content_tab_edit").hide();
            if (typeof(eval(func)) == "function") {
                func();
            } else {
                tab_handler.tab_list();
            }
        });

    },

    tab_lookup: function (arg) {
        $("#content_tab_list").hide();
        $("#content_tab_add").hide();
        var obj = config.obj();
        tab_sproto._P_tab_lookup("tab_name=" + config.get_tab_name() + "&" + arg, function (data) {
            var form_edit = "";
            for (var n = 0; n < obj.tab_record.length; n++) {
                form_edit += tab_tpl.form_edit(obj.tab_record[n], "edit", data.ret);
            }
            var html = '<div class="tpl-form-body tpl-form-line"><form class="am-form tpl-form-line-form" id="form_edit">' + form_edit +
                '<div class="am-form-group"><div class="am-u-sm-9 am-u-sm-push-3">' +
                '<button type="submit" class="am-btn am-btn-primary tpl-btn-bg-color-success">更新</button>&nbsp;&nbsp;&nbsp;' +
                '<button type="button" class="am-btn am-btn-default" onclick="tab_tpl.form_cancel();">返回</button></div></div></form></div>';

            $("#content_tab_edit").html(html);
            $("#content_tab_edit").show();
            $("#content_title").html("编辑");
            tab_view.validator("#form_edit", function () {
                tab_handler.tab_update();
            });
        });
    },

    tab_update: function () {
        var arg = $("#form_edit").serialize();
        arg = url.html_encode(arg);
        tab_sproto._P_tab_update("tab_name=" + config.get_tab_name() + "&" + arg, function (data) {
            $("#content_tab_add").hide();
            $("#content_tab_edit").hide();
            tab_handler.tab_list();
        });

    },

    tab_set: function (msg) {
        if (msg == undefined) {
            msg = "确定要修改状态吗！";
        }
        if (confirm(msg)) {
            var arg = $("#form_set_state").serialize();
            arg = url.html_encode(arg);
            tab_sproto._P_tab_set("tab_name=" + config.get_tab_name() + "&" + arg, function (data) {
                tab_view.tab_state_cancle();
                tab_handler.tab_list();
            });

        }
    },

    tab_reset: function (msg, arg) {
        if (confirm(msg)) {
            tab_sproto._P_tab_reset("tab_name=" + config.get_tab_name() + "&" + arg, function (data) {
                alert("更新成功！");
                tab_handler.tab_list();
            });
        }
    },

    tab_del: function (arg) {
        if (confirm("确定要删除吗！")) {
            tab_sproto._P_tab_del("tab_name=" + config.get_tab_name() + "&" + arg, function (data) {
                tab_handler.tab_list();
            });
        }
    }
};