var ex_proto = {
    _P_orders_recharge: function (arg, cb) {
        network.ajax("/api/ex_sproto/orders_recharge?" + arg, cb);
    }
};