/**
 * Created by yujian on 17-5-24.
 */
var index_view = {
    head: function () {
        var html_head = '<meta http-equiv="X-UA-Compatible" content="IE=edge">'
            + '<meta name="viewport" content="width=device-width, initial-scale=1">'
            + '<meta name="renderer" content="webkit">'
            + '<meta http-equiv="Cache-Control" content="no-siteapp"/>'
            + '<link rel="icon" type="image/png" href="/img/favicon.png">'
            + '<link rel="apple-touch-icon-precomposed" href="/assets/i/app-icon72x72@2x.png">'
            + '<meta name="apple-mobile-web-app-title" content="主页"/>'

            + '<link rel="stylesheet" href="https://cdn.bootcss.com/amazeui/2.7.2/css/amazeui.min.css"/>'
            + '<link rel="stylesheet" href="/assets/css/amazeui.datetimepicker-se.min.css"/>'
            + '<link rel="stylesheet" href="/assets/css/app.css">'
            + '<script src="/assets/deps/amazeui.datetimepicker-se.min.js"></script>' +
            '<link href="/assets/deps/umeditor/themes/default/css/umeditor.css" type="text/css" rel="stylesheet">' +
            // '<script type="text/javascript" src="assets/deps/umeditor/third-party/jquery.min.js"></script>' +
            '<script type="text/javascript" src="/assets/deps/umeditor/third-party/template.min.js"></script>' +
            '<script type="text/javascript" charset="utf-8" src="/assets/deps/umeditor/umeditor.config.js"></script>' +
            '<script type="text/javascript" charset="utf-8" src="/assets/deps/umeditor/umeditor.min.js"></script>' +
            '<script type="text/javascript" src="/assets/deps/umeditor/lang/zh-cn/zh-cn.js"></script>';
        // + '<script src="assets/deps/iscroll.js"></script>';
        $("head").append(html_head);
    },

    header: function (account, arg) {
        return '<div class="am-topbar-brand"><a href="javascript:;" class="tpl-logo"><img src="/img/logo.png" alt=""></a></div>'
            + '<div class="am-icon-list tpl-header-nav-hover-ico am-fl am-margin-right"></div>'
            + '<div class="am-collapse am-topbar-collapse" id="topbar-collapse">'
            + '<ul class="am-nav am-nav-pills am-topbar-nav am-topbar-right admin-header-list tpl-header-list">'
            + arg
            // + '<li class="am-dropdown" data-am-dropdown="" data-am-dropdown-toggle="">'
            // + '<a class="am-dropdown-toggle tpl-header-list-link" href="javascript:;">'
            // + '<span class="am-icon-comment-o"></span> 消息 <span class="am-badge tpl-badge-danger am-round">.</span>'
            // + '</a>'
            // + '</li>'
            + '<li class="am-dropdown" data-am-dropdown data-am-dropdown-toggle>'
            + '<a class="am-dropdown-toggle tpl-header-list-link" href="javascript:;">'
            + '<span class="tpl-header-list-user-nick">' + account + '</span>'
            + '<span class="tpl-header-list-user-ico"> <img src="assets/img/user01.png"></span>'
            + '</a>'
            + '<ul class="am-dropdown-content">'
            + '<li><a href="#"><span class="am-icon-bell-o"></span> 资料</a></li>'
            + '<li><a href="login.html?act=exit"><span class="am-icon-power-off"></span> 退出</a></li>'
            + '</ul>'
            + '</li>'
            + '<li>'
            + '<a href="login.html?act=exit" class="tpl-header-list-link">'
            + '<span class="am-icon-sign-out tpl-header-list-ico-out-size"></span>'
            + '</a>'
            + '</li>'
            + '</ul>'
            + '</div><script type="application/javascript">$(function(){$(".tpl-header-nav-hover-ico").on("click", function () {$(".tpl-left-nav").toggle();$(".tpl-content-wrapper").toggleClass("tpl-content-wrapper-hover");}); $hrefs = $("#topbar-collapse .tpl-header-list li").find("a");$.each($hrefs, function (i, item) {var path_split = item.href.split("/");var path = path_split[path_split.length - 1];if (path == config.path){$(this).addClass("hover")}});});</script> '
    },

    footer: function () {
        var html = '<a id=\"export_excel\"></a><div id="error_bg"></div><div id="loading"><img src="/assets/img/loading.gif"></div>' +
            '<div class="am-modal am-modal-confirm" tabindex="-1" id="confirm_warn">' +
            '<div class="am-modal-dialog"><div class="am-modal-hd">警告</div><div class="am-modal-bd">确定要删除这条记录吗？</div>' +
            '<div class="am-modal-footer"><span class="am-modal-btn" data-am-modal-cancel>取消</span>' +
            '<span class="am-modal-btn" data-am-modal-confirm>确定</span></div></div></div>';
        $("footer").html(html);
    },

    element_hidden: function () {
        $("header .am-icon-list").hide();
        $("#topbar-collapse .am-nav .am-dropdown").hide();
        $("#topbar-collapse .am-nav .am-dropdown").last().show();
    }
};