var view_mgr = {
    obj_view: function (name, title) {
        $("#content_title").html(title);
        var obj = config.obj();
        if (name == "" || obj == undefined) {
            $("#content_tab_list").html("功能未开放！");
        } else if (obj.obj_type == "chart") {
            $("#chart").html(obj.html);
            obj.cb_fun();
            // $("#tab").hide();
        } else if (obj.obj_type == "excel") {
            window.open("excel/excel_" + name + ".html");
        } else {
            $("#chart").hide();
            tab_view.table(name, title);
        }
    }
};