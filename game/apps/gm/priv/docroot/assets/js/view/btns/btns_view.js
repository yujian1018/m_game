var btns_view = {
    type_once: "once",

    load_btns: function (type, pms_ops) {
        var html_btns = "";
        if (pms_ops != "") {
            $.each(pms_ops.split("-"), function (i, pms_id) {
                var btn = btn_c['btn_' + pms_id];
                if (btn != undefined) {
                    if (btn.type == type) {
                        html_btns += btns_view.btn(btn);
                    }
                }
            });
        }
        return '<div class="am-btn-toolbar"><div class="am-btn-group am-btn-group-xs">' + html_btns + '</div></div>';
    },

    btns: function (btns) {
        var html_btns = "";
        $.each(btns, function (i, btn) {
            html_btns += btns_view.btn(btn);
        });
        return '<div class="am-btn-toolbar"><div class="am-btn-group am-btn-group-xs">' + html_btns + '</div></div>';
    },

    btn: function (btn) {
        return '<button type="button" class="am-btn ' + btn.css + '"onclick="' + btn.onclick + '"> <span class="' + btn.icon + '"></span> ' + btn.label + ' </button>';
    },

    checkbox_btns: function (pms_id, pms_all, pms_my) {
        var op_all_list = pms_all.split("-");
        var op_this_list = pms_my.split("-");
        span_btns = new Array();
        for (var i = 0; i < op_all_list.length; i++) {
            var op = op_all_list[i], has_pms = false;
            for (var n = 0; n < op_this_list.length; n++) {
                if (op == op_this_list[n]) {
                    has_pms = true;
                }
            }
            if (btn_c['btn_' + op] != undefined) {
                btn_c['btn_' + op].has_pms = has_pms;
                btn_c['btn_' + op].name = pms_id + '_' + op;
                span_btns.push(btn_c['btn_' + op]);
            }
        }
        return '<span class="tpl-pms-op">' + btns_view.span_btns(span_btns) + '</span>';
    },

    span_btns: function (btns) {
        var html_btns = "";
        $.each(btns, function (i, item) {
            html_btns += btns_view.span_btn(item);
        });
        return '<span class="tpl-pms-op">' + html_btns + '</span>';
    },

    span_btn: function (btn) {
        if (btn.checkbox_v == undefined) {
            btn.checkbox_v = "";
        }
        if (btn.has_pms) {
            return '<span class="' + btn.span_click_css + '"><i class="' + btn.icon + '"></i>' + btn.label + '<input type="hidden" name="' + btn.name + '" value="on"></span>';
        } else {
            return '<span class="' + btn.span_css + '"><i class="' + btn.icon + '"></i>' + btn.label + '<input type="hidden" name="' + btn.name + '" value="off"></span>';
        }
    }
};