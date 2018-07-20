var tree_view = {
    pms_all: function (data, type, arg) {
        var html = "", btn = "";
        var list = tree_view.get_tree(0, data.ret);
        for (var m = 0; m < list.length; m++) {
            html += tree_view.pms_show(type, 0, 0, list[m][0], list[m][2], list[m][4], list[m][5], list[m][6], list[m][7]);
        }
        if (type == "edit") {
            html = html + "<li class=\"add_item\" id=\"0\">[+]</li>";
            btn = "<button type=\"button\" class=\"am-btn am-btn-danger\" onclick=\"account_handler.pms_del()\">删除</button>";
        } else {
            btn = "<button type=\"button\" class=\"am-btn am-btn-success\" onclick=\"account_handler.pms_update('" + arg + "')\">更新</button>";
        }
        $("#tree").html('<ul class="side_sub" style="display:inline-block;">' + html +
            '</ul><input type="hidden" id="add_item"><div style="padding-left: 270px; padding-bottom: 20px;">' +
            '<div class="am-btn-toolbar"><div class="am-btn-group am-btn-group-xs">' +
            '<button type="button" class="am-btn am-btn-default" onclick="tree_view.tree_cancle();">取消</button>' +
            btn + '</div></div></div>');
        tree_view.this_jquery();
    },
    //编辑|显示 upper：是否是某级
    pms_show: function (type, upper, index, id, name, is_check, pms_all, pms_this, list) {
        var index1 = index + 1;
        var html = "", html_check = "";
        if (is_check == 1) {
            html_check = '<input title="选择" name="' + id + '" type="checkbox" checked/> ';
        } else {
            html_check = '<input title="选择" name="' + id + '" type="checkbox"/>';
        }

        if (list == undefined) {
            if (index == 1) {
                html += '<li class="item">' + html_check + ' <span>' + name + '</span><ul><li class="add_item" id="' + id + '">[+]</li></ul></li>';
            } else {
                if (pms_all == "") {
                    html += '<li class="item">' + html_check + ' <span>' + name + '</span></li>';
                } else {
                    html += '<li class="item">' + html_check + ' <span>' + name + '</span>' + btns_view.checkbox_btns(id, pms_all, pms_this) + '</li>';
                }
            }
        } else {
            for (var m = 0; m < list.length; m++) {
                html += tree_view.pms_show(type, id, index1, list[m][0], list[m][2], list[m][4], list[m][5], list[m][6], list[m][7]);
            }
            if (upper == 0) {
                html = '<li class="item"><em class="arrow"></em>' + html_check + '<span>' + name + '</span><ul style=\"display: none;\">' + html;
            } else {
                html = '<li class="item"><em class="arrow select"></em>' + html_check + '<span>' + name + '</span><ul>' + html;
            }
            if (type == "edit") {
                html += "<li class=\"add_item\" id=\"" + id + "\">[+]</li></ul></li>";
            } else {
                html += "</ul></li>";
            }

        }
        return html;
    },

    this_jquery: function () {
        $("#tree").show();
        $("#error_bg").show();
        $("#tree :checkbox").click(function () {
            if ($(this).is(':checked')) {
                $(this).siblings("ul").find(":checkbox").prop("checked", true);
            } else {
                $(this).siblings("ul").find(":checkbox").prop("checked", false);
            }
        });

        $("#tree .arrow").click(function () {
            var css = $(this).attr("class");
            if (css == "arrow") {
                $(this).addClass("select");
                $(this).siblings("ul").show();
            } else {
                $(this).removeClass("select");
                $(this).siblings("ul").hide();
            }
        });

        $("#tree .tpl-pms-op > span > span").click(function () {
            var attr_css = $(this).attr("class");
            var css_split = attr_css.split(" ");
            if (css_split.length == 2) {
                $(this).removeClass(css_split[1]);
                $(this).find("input").val("off");
            } else {
                $(this).addClass(attr_css + "-click");
                $(this).find("input").val("on");
            }
        })
    },

    get_tree: function (top_id, data) {
        var list = new Array();
        for (var i = 0; i < data.length; i++) {
            if (data[i][1] == top_id) {
                var list1 = tree_view.get_tree(data[i][0], data);
                if (list1.length != 0) {
                    data[i].push(list1);
                }
                list.push(data[i]);
            }
        }
        return list;
    },
    tree_cancle: function () {
        $("#content_tab_list").show();
        $("#content_tab_edit").hide();
        $("#content_tab_add").hide();
        $("#tree").hide();
        $("#error_bg").hide();
    }
};