var account_handler = {
    login: function (account, password) {
        account_sproto._P_login(account, password, function (data) {
            console.log("111", account, password, data);
            cookie.set("account", account, 3);
            cookie.set("password", password, 3);
            cookie.set("nick", data.new_account_name, 365);
            cookie.set("account_id", data.account_id, 3);
            window.location.href = "../../../index.html";
        });
    },

    pms_get: function (top_pms_id, cb) {
        account_sproto._P_pms_get(top_pms_id, cb);
    },

    pms_all: function () {
        var data = account_sproto._P_pms_all();
        var pms = tree_view.get_tree(0, data.ret);
        var selects = [["all_special_character", "-请选择-"], ["0", "顶级菜单"]];
        for (var m = 0; m < pms.length; m++) {
            var pms_arr = pms[m];
            selects.push([pms_arr[0], pms_arr[2]]);
            if (pms_arr[3] != undefined) {
                for (var n = 0; n < pms_arr[3].length; n++) {
                    selects.push([pms_arr[3][n][0], "&nbsp;&nbsp;&nbsp;&nbsp;" + pms_arr[3][n][2]]);
                }
            }
        }
        tab_config.options_pms_tree = selects;
    },

    pms_edit: function (arg) {
        account_sproto._P_pms_edit(arg, function (data) {
            tree_view.pms_all(data, null, arg);
        });
    },

    pms_update: function (arg) {
        var form_data = $("#tree").serialize();
        account_sproto._P_pms_update(arg + "&" + form_data, function (data) {
            tree_view.tree_cancle();
            alert("更新成功！");
        });
    }
};