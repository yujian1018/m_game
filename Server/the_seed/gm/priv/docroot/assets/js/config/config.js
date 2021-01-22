var config = {
    path: "index.html",
    tab_name: null,
    get_tab_name: function () {
        return config.tab_name;
    },

    obj: function () {
        if (config.path == "index.html") {
            return tab_index[config.get_tab_name()];
        } else if (config.path == "game.html") {
            return tab_game[config.get_tab_name()];
        } else if (config.path == "account.html") {
            return tab_account[config.get_tab_name()];
        } else if (config.path == "gm.html") {
            return tab_gm[config.get_tab_name()];
        } else if (config.path == "data.html") {
            return tab_data[config.get_tab_name()];
        }
    }
};
