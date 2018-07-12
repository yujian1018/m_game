var tab_sproto = {
    _P_tab_list: function (arg, cb) {
        network.ajax("/api/tab_sproto/tab_list?" + arg, cb);
    },

    _P_tab_add: function (arg, cb) {
        network.post("/api/tab_sproto/tab_add", arg, cb);
    },

    _P_tab_lookup: function (arg, cb) {
        network.ajax("/api/tab_sproto/tab_lookup?" + arg, cb);
    },

    _P_tab_update: function (arg, cb) {
        network.post("/api/tab_sproto/tab_update", arg, cb);
    },

    _P_tab_set: function (arg, cb) {
        network.ajax("/api/tab_sproto/tab_update?" + arg, cb);
    },

    _P_tab_reset: function (arg, cb) {
        network.ajax("/api/tab_sproto/tab_update?" + arg, cb);
    },

    _P_tab_del: function (arg, cb) {
        network.ajax("/api/tab_sproto/tab_delete?" + arg, cb);
    }
};