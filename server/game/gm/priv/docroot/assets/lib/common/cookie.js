/**
 * Created by yujian on 17-5-17.
 */
var cookie = {
    //删除cookie
    exit: function () {
        cookie.set("account", "", -1);
        cookie.set("password", "", -1);
    },

    //设置cookie
    set: function (key, value, expiredays) {
        var exdate = new Date();
        exdate.setDate(exdate.getDate() + expiredays);
        document.cookie = key + "=" + decodeURI(value) +
            ((expiredays == null) ? "" : ";Path=/;expires=" + exdate.toGMTString())
    },

    //获取cookie
    get: function (key) {
        if (document.cookie.length > 0) {
            var c_start = document.cookie.indexOf(key + "=");
            if (c_start != -1) {
                c_start = c_start + key.length + 1;
                var c_end = document.cookie.indexOf(";", c_start);
                if (c_end == -1) c_end = document.cookie.length;
                return decodeURIComponent(document.cookie.substring(c_start, c_end))
            }
        }
        return "";
    }
};