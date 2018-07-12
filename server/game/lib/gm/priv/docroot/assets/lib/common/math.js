/**
 * Created by yujian on 17-5-17.
 */

var math = {
    eval_divide: function (Key, Value, action) {
        if (Key == 0) {
            return "0.00";
        } else if (Value == 0) {
            return "0.00";
        } else {
            if (action == "%") {
                return Math.abs(Number((Key / Value) * 100).toFixed(2));
            } else {
                return Math.abs(Number(Key / Value).toFixed(2));
            }
        }
    },
    format_float: function (num, pos) {
        var size = Math.pow(10, pos);
        return Math.round(num * size) / size;
    }
};