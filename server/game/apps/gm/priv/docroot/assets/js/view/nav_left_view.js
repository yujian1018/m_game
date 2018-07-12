/**
 * Created by yujian on 17-5-24.
 */
var nav_left_view = {
    nav_left: function (top_pms_id) {
        account_handler.pms_get(top_pms_id, function (data) {
            config.tab_name = "";
            var home_page, in_paths = false;
            home_page = data.top_pms[0].kv_list[0].url;
            var kv_list = data.top_pms[0].kv_list;
            for (var i = 0; i < kv_list.length; i++) {
                if (kv_list[i].url == config.path) {
                    in_paths = true;
                }
            }
            if (in_paths == false) {
                window.location.href = home_page;
            } else {
                var header_li = "";
                for (var n = 0; n < kv_list.length; n++) {
                    header_li += '<li class="am-dropdown"><a class="am-dropdown-toggle tpl-header-list-link" href="' +
                        kv_list[n].url + '"><span class="' +
                        kv_list[n].icon + '"></span> ' +
                        kv_list[n].name + '</a>';
                }
                $("header").html(index_view.header(cookie.get("nick"), header_li));

                var tab_name = data.pms[0].kv_list[0].tab;
                if (tab_name != undefined && tab_name != '\N' && tab_name != '') {
                    config.tab_name = tab_name;
                }
                var left_li = "", html_nav_left = "";
                for (var m = 0; m < data.pms.length; m++) {
                    kv_list = data.pms[m].kv_list;
                    var left_li2 = "";
                    for (var m2 = 0; m2 < kv_list.length; m2++) {
                        tab_config.set_pms(kv_list[m2].tab, kv_list[m2].pms_op);
                        left_li2 += '<li><a href="javascript:void(\'' +
                            kv_list[m2].tab + '\');" id="a_' + tab_name + '" onclick="tab_view.set_table(\'' +
                            kv_list[m2].tab + '\', \'' + kv_list[m2].name + '\')" ><i class="am-icon-angle-right"></i><span>' +
                            kv_list[m2].name + '</span></a></li>'
                    }
                    left_li += '<li class="tpl-left-nav-item"><a href="javascript:;" class="nav-link tpl-left-nav-link-list"><i class="am-icon-table"></i><span>' +
                        data.pms[m].name +
                        '</span><i class="am-icon-angle-right tpl-left-nav-more-ico am-fr am-margin-right"></i></a><ul class="tpl-left-nav-sub-menu">' +
                        left_li2 + '</ul></li>';

                }
                html_nav_left = '<div class="tpl-left-nav-title"></div>'
                    + '<div class="tpl-left-nav-list">'
                    + '<ul class="tpl-left-nav-menu">'
                    + left_li
                    + '</ul>'
                    + '</div>';
                $("#tpl-left-nav").html(html_nav_left);
                $(".tpl-left-nav-link-list").on("click", function () {
                    $(this).siblings(".tpl-left-nav-sub-menu").slideToggle(80).end().find(".tpl-left-nav-more-ico").toggleClass("tpl-left-nav-more-ico-rotate");
                });
                $(".tpl-left-nav-menu .tpl-left-nav-sub-menu:eq(0)").attr("style", "display: block;");
                $("#a_" + tab_name).addClass("active");
                $("#a_" + tab_name).parent("li").parent("ul").siblings("a").addClass("active");
            }
        });
    }
};