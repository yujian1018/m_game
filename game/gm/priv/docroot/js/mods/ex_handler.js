var ex_handler = {
    orders_recharge: function (msg, arg) {
        if (confirm(msg)) {
            ex_proto._P_orders_recharge(arg, function (data) {
                alert("补单成功！");
                tab_handler.tab_list();
            })
        }
    }
};