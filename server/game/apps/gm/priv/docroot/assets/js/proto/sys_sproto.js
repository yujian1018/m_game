var sys_sproto = {
    _P_game_list_info: function (cb) {
        network.ajax("/api/sys_sproto/game_list_info", cb);
    },

    _P_get_options: function (type, cb) {
        network.ajax("/api/sys_sproto/get_options?type=" + type, cb);
    },

    _P_reset_tab: function (arg, cb) {
        network.ajax("/api/sys_sproto/update_config_tab?tab_name=" + arg, cb);
    }
};