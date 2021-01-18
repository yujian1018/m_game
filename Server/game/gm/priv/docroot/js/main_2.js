
$(function () {
    var path_split = window.location.pathname.split("/");
    var path = path_split[path_split.length - 1];
    var pms_id, title_name;
    if (path == "index.html") {
        pms_id = 1;
        title_name = "总览";
    } else if (path == "game.html") {
        pms_id = 2;
        title_name = "游戏服列表";
    } else if (path == "account.html") {
        pms_id = 3;
        title_name = "账户管理";
    } else if (path == "gm.html") {
        pms_id = 4;
        title_name = "gm工具";
    } else if (path == "data.html") {
        pms_id = 5;
        title_name = "数据中心";
    } else {
        index_view.head();
        index_view.footer();

    }
    config.path = path;
    if (!isNaN(pms_id)) {
        index_view.head();
        index_view.footer();
        nav_left_view.nav_left(pms_id);

        var tab_name = config.get_tab_name();
        view_mgr.obj_view(tab_name, title_name);
    }
});