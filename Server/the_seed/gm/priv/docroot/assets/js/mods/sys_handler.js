var sys_handler = {
    game_list_info: function () {
        sys_sproto._P_game_list_info(function (data) {
            $("#content_tab_list").show();
            $("#content_tab_add").hide();
            $("#content_tab_edit").hide();
            $("#content_title").html("列表");
            tab_tpl.table_list(data);
        });
    },

    get_options: function (type) {
        sys_sproto._P_get_options(type, function (data) {
            if (type == 1) {
                tab_config.options_pms_roles = data.ret;
                tab_config.options_pms_roles.push(["all_special_character", "-请选择-"]);
            } else if (type == 2) {
                tab_config.options_channel = data.ret;
                tab_config.options_channel.unshift(["all_special_character", "-请选择-"]);
            } else if (type == 3) {
                tab_config.options_packet = data.ret;
            } else if (type == 11) {
                tab_config.options_prize_ids = data.ret;
                tab_config.options_prize_ids.unshift(["all_special_character", "-请选择-"]);
            } else if (type == 12) {
                tab_config.options_item_ids = data.ret;
                tab_config.options_item_ids.unshift(["all_special_character", "-请选择-"]);
            }  else if (type == 13) {
                tab_config.options_mail_prize_ids = data.ret;
            } else {
            }
        });

    },
    reset_tab: function (arg) {
        sys_sproto._P_reset_tab(arg, function (data) {
            alert("热更成功");
        });
    }
};