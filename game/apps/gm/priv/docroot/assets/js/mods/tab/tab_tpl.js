var tab_tpl = {
    table: function (obj) {
        var tab_input = "", tab_field = "", obj_feild = "";
        for (var i = 0; i < obj.tab_record.length; i++) {
            if (obj.tab_record[i].type == "select" || obj.tab_record[i].type == "select_2") {
                if (typeof(obj.tab_record[i].options) == "function") {
                    obj.tab_record[i].options_fun = obj.tab_record[i].options();
                }
            }
        }
        for (var i = 0; i < obj.tab_record.length; i++) {
            obj_feild = obj.tab_record[i];
            tab_input += form_view.form_view(form_view.type_input, obj_feild);
        }
        for (var i = 0; i < obj.tab_record.length; i++) {
            obj_feild = obj.tab_record[i];
            if (obj_feild.type == "hidden") {
                tab_field += "<th style='display:none'>" + obj_feild.label + "</th>";
            } else if (obj_feild.type == "null") {
                tab_field += "";
            } else {
                tab_field += "<th >" + obj_feild.label + "</th>";
            }
        }

        if (obj.all_pms != "" && obj.all_pms != undefined) {
            $.each(obj.all_pms.split("-"), function (i, pms_id) {
                var pms_items = pms_id.split(":");
                var pms_id2 = pms_items[0];
                var btn = btn_c['btn_' + pms_id2];
                if (btn != undefined) {
                    if (btn.type != "once") {
                        tab_config_op.is_edit = true;
                    }
                }
            });
        }
        if (tab_config_op.is_edit) {
            tab_input += '<th></th>';
            tab_field += '<th>操作</th>';
        }
        var tab_ex = "";
        if (obj.obj_type == "tab_count") {
            tab_ex = obj.html;
        }

        return '<div id="table"><form class="am-form" id="form_list"><table class="am-table am-table-hover am-table-bordered"><thead id="table_input"><tr>' + tab_input + '</tr></thead><thead id="table_field"><tr>' +
            tab_field + '</tr></thead><tbody id="table_list"></tbody></table>' +
            '<input type="hidden" name="form_list_sort_key" value=""><input type="hidden" name="form_list_sort" value="0"><input type="hidden" name="form_list_c_page" id="c_page" value="1">' +
            '</form></div><div class="am-cf" style="line-height: 54px;">共 <span id="pages_count" style="color:red;">0</span> 条记录<ul class="pagination" id="pages"></ul></div><div id="table_count">' +
            tab_ex + '</div>';
    },

    table_list: function (data) {
        var obj = config.obj();
        var tab_name = config.tab_name;
        var tab_tr = "";
        if (data.ret == "") {
            if (tab_config_op.is_edit) {
                tab_tr = '<tr><td colspan="' + obj.tab_record.length + 1 + '" class="am-text-center font-red">暂无数据</td></tr>';
            } else {
                tab_tr = '<tr><td colspan="' + obj.tab_record.length + '" class="am-text-center font-red">暂无数据</td></tr>';
            }
        } else {
            var pms_ids_old = new Array();
            if (obj.all_pms != "" && obj.all_pms != undefined) {
                $.each(obj.all_pms.split("-"), function (i, pms_id) {
                    var pms_items = pms_id.split(":");
                    var pms_id2 = pms_items[0];
                    var btn = btn_c['btn_' + pms_id2];
                    if (btn != undefined && btn.type != "once") {
                        pms_ids_old.push(pms_id);
                        if (pms_id2 == "9" || pms_id2 == "12") {
                            tab_config_op[pms_id2](obj, pms_items);
                        }
                    }
                });
            }
            $.each(data.ret, function (i, item) {
                var pms_ids = new Array();
                $.each(pms_ids_old, function (i, pms_id) {
                        var pms_items = pms_id.split(":");
                        var k = pms_items[1];
                        if (k == undefined) {
                            pms_ids.push(pms_id)
                        } else if (btn_view_st[tab_name + "_" + pms_items[0] + "_" + item[k]]) {
                            pms_ids.push(pms_items[0])
                        }
                    }
                );
                var td_all = tab_tpl.table_item(item, obj.tab_record);
                var td_btn = new Array();

                $.each(pms_ids, function (i, pms_id) {
                    if (pms_id != "10") {
                        var btn = btn_c['btn_' + pms_id];
                        var key_arg = "";
                        if (typeof(obj.key) == "string") {
                            key_arg = obj.key + "=" + item[obj.key];
                        } else {
                            $.each(obj.key, function (i, obj_key) {
                                if (key_arg == "") {
                                    key_arg += obj_key + "=" + item[obj_key];
                                } else {
                                    key_arg += "&" + obj_key + "=" + item[obj_key];
                                }
                            })
                        }
                        switch (pms_id) {
                            case "5":
                                btn.onclick = "tab_handler.tab_lookup('" + key_arg + "');";
                                break;
                            case "6":

                                btn.onclick = "tab_handler.tab_del('" + key_arg + "');";
                                break;
                            case "8":
                                btn.onclick = "account_handler.pms_edit('" + key_arg + "');";
                                break;
                            case "13":
                                btn.onclick = "sys_handler.reset_tab('" + item[obj.key] + "');";
                                break;
                            case "15":
                                btn.onclick = "ex_handler.orders_recharge('确定要补单吗！', '" + key_arg + "');";
                                break;
                            default:
                        }

                        if (pms_id == "9") {
                            $.each(tab_config_op.edit_state, function (i, state_key) {
                                btn_c['btn_9'].onclick = "tab_view.tab_set_view('" + state_key + "', '" + item[state_key] + "', '" + item[obj.key] + "')";
                                td_btn.push(tab_btns['btn_9']);
                            });
                        } else if (pms_id == "12") {
                            if (tab_config_op.edit_tree_lv > 1) {
                                $("#content_tab_list .am-btn-primary").attr("disabled", "disabled");
                                $("#content_tab_list .am-btn-default").attr("disabled", "disabled");
                            }
                            if (tab_config_op.edit_tree_lv < obj.tree_max_tree_lv) {
                                btn_c['btn_12'].onclick = 'tab_config_op.edit_tree_default_v = \'' + item[obj.key] + '\';$(\'#' + obj.tree_id + '\').val(\'' + item[obj.key] + '\');tab_config_op.edit_tree_lv=tab_config_op.edit_tree_lv+1;tab_handler.tab_list();';
                                td_btn.push(btn_c['btn_12'])
                            }
                        }
                        else {
                            td_btn.push(btn);
                        }
                    }

                });

                if (tab_config_op.is_edit) {
                    tab_tr += "<tr>" + td_all + "<td>" + btns_view.btns(td_btn) + "</td></tr>";
                } else {
                    tab_tr += "<tr>" + td_all + "</tr>";
                }
            });
        }
        $("#table_list").html(tab_tr);
        page_tpl.page_html(data.count, data.max_page);
        if (obj.obj_type == "tab_count") {
            obj.cb_fun(data);
        }
    },


    form_cancel: function () {
        $("#content_tab_add").hide();
        $("#content_tab_edit").hide();
        $("#content_tab_list").show();
        $("#content_title").html("列表");
    },

    form_clear: function (form_id) {
        $("#" + form_id + " input").val("");
        var $option = $("#" + form_id + "").find('option').eq(1);
        $option.attr("selected", true);
        $("#c_page").val("1");
    },

    form_edit: function (obj_field, op_type, item) {
        if (obj_field.v == undefined || obj_field.v == null || obj_field.v == '\N') {
            obj_field.v = '';
        }
        if (obj_field.placeholder == undefined || obj_field.placeholder == null) {
            obj_field.placeholder = '';
        }
        if (obj_field.verify == undefined || obj_field.verify == null || obj_field.verify == '') {
            obj_field.verify = ''
        } else {
            obj_field.verify = obj_field.verify + ' required';
        }
        if (obj_field.verify_msg == undefined || obj_field.verify_msg == null) {
            obj_field.verify_msg = '';
        }
        if (op_type == "add") {
            obj_field.v = '';
        }
        if (obj_field.edit_type != undefined) {
            return form_view.form_view(op_type, obj_field, item);
        } else {
            return form_view.form_view(op_type, obj_field, item);
        }
    },
    table_item: function (item, tab_record) {
        var table_item = "", obj_field;
        for (var i = 0; i < tab_record.length; i++) {
            obj_field = tab_record[i];
            if (item[obj_field.id] == undefined | item[obj_field.id] == "undefined") {
                item[obj_field.id] = "";
            }
            table_item += form_view.form_view(form_view.type_list, obj_field, item);
        }
        return table_item;
    }
};