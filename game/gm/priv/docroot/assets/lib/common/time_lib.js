/**
 * Created by yujian on 17-5-17.
 */

var time_lib = {
    now_to_times: function (times) {
        if (times == "undefined") {
            return 0;
        } else if (times == "0") {
            return 0;
        } else if (times == 0) {
            return 0;
        } else {
            var now = new Date(parseInt(times) * 1000);
            var year = now.getFullYear();
            var month = now.getMonth() + 1;
            var date = now.getDate();
            var hour = now.getHours();
            var minute = now.getMinutes();
            var second = now.getSeconds();
            return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
        }
    },
    now_times: function () {
        var now = new Date();
        var year = now.getFullYear();
        var month = now.getMonth() + 1;
        var date = now.getDate();
        var hour = now.getHours();
        var minute = now.getMinutes();
        var second = now.getSeconds();
        return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
    },
    to_date: function (type) {
        var diff_time = 0;
        if (typeof(type) == "number") {
            diff_time = 86400000 * type;
        } else {
            return new Date();
        }
        var date = new Date();
        var h = date.getHours();
        var mi = date.getMinutes();
        var s = date.getSeconds();
        date.setTime(date.getTime() - (h * 3600 + mi * 60 + s) * 1000 + diff_time);
        return date;
    }
};