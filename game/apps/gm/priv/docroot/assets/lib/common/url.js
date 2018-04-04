/**
 * Created by yujian on 17-5-17.
 */

var url = {
    parse_url: function (key) {
        var reg = new RegExp("(^|&)" + key + "=([^&]*)(&|$)", "i");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return decodeURIComponent(r[2]);
        return null;
    },

    html_encode: function (arg) {
        var s = "";
        if (arg.length == 0) return "";
        s = arg.replace(/'/g, "apos;");//&apos;
        s = s.replace(/%60/g, "%2396%25;");//&#96;  尖重音符Acute accent
        s = s.replace(/op_state=on/g, "op_state=1");
        s = s.replace(/all_special_character/g, "");
        s = s.replace(/%0D%0A/g, "<br/>");
        return s;
    },

    html_decode: function (arg) {
        var s = "";
        if (arg.length == 0) return "";
        if (typeof(arg) == "number") return arg;
        s = arg.replace(/apos;/g, "'");
        s = s.replace(/#96%;/g, "`");
        s = s.replace(/<br\/>/g, "\r\n");
        return s;
    }
};
