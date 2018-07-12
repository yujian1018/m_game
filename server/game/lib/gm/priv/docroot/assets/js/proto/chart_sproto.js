var chart_sproto = {
    chart_1: function (cb) {
        network.ajax("/api/chart_sproto/chart_index", cb)
    },
    chart_lv: function (arg, cb) {
        network.ajax("/api/chart_sproto/chart_lv?" + arg, cb)
    }
};