var account_sproto = {
    _P_login: function (account, password, cb) {
        network.ajax("/api/account_sproto/account_login?account_name=" + account + "&account_pwd=" + password, cb);
    },

    _P_pms_get: function (top_pms_id, cb) {
        network.ajax("/api/account_sproto/get_pms?top_pms_id=" + top_pms_id, cb);
    },

    _P_pms_all: function (cb) {
        network.ajax("/api/account_sproto/pms_my_all", cb);
    },

    _P_pms_edit: function (arg, cb) {
        network.ajax("/api/account_sproto/pms_all?" + arg, cb);
    },

    _P_pms_update: function (arg, cb) {
        network.post("/api/account_sproto/pms_update", arg, cb);
    }
};