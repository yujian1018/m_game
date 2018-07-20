var page_tpl = {
    page: function (arg) {
        $("#c_page").val(arg);
        tab_handler.tab_list();
    },
    alert_page_click: function (page, company_id) {
        $("#alert_page_id").val(page);
        tab_sproto_ex.list_company_amount_log(page, company_id);
    },

    alert_page_log_2: function (page, id) {
        $("#alert_page_id").val(page);
        tab_sproto_ex.list_interview_log(page, id);
    },
    alert_page_log_3: function (page, id) {
        $("#alert_page_id").val(page);
        tab_sproto_ex.discovery_list_1(page, id);
    },
    page_html: function (count, max_page) {
        var c_page = parseInt($("#c_page").val());
        var pages = page_tpl.page_num(c_page, max_page);

        var html = "";
        if (pages == null) {
            html = "<li class=\"disabled\"><a href=\"javascript:void(1);\">首页</a></li>" +
                "<li class=\"disabled\"><a href=\"javascript:void(1);\">上一页</a></li>" +
                "<li class=\"disabled\"><a href=\"javascript:void(1);\">下一页</a></li>" +
                "<li class=\"disabled\"><a href=\"javascript:void(1);\">末页</a></li>";

        } else {
            $.each(pages, function (i, item) {
                if (item < c_page) {
                    html += "<li><a href=\"javascript:page_tpl.page(" + item + ")\">" + item + "</a></li>";
                } else if (item == c_page) {
                    html += "<li class=\"disabled\"><a href=\"javascript:;\">" + item + "</a></li>";
                } else {
                    html += "<li class=\"duration\"><a href=\"javascript:page_tpl.page(" + item + ")\">" + item + "</a></li>";
                }
            });
            var priv_page, next_page;
            if (c_page > 2) {
                priv_page = c_page - 1;
            } else {
                priv_page = 1;
            }
            if (parseInt(c_page) < max_page) {
                next_page = c_page + 1;
            } else {
                next_page = c_page;
            }
            html = "<li><a href=\"javascript:page_tpl.page(1)\">首页</a></li>" +
                "<li><a href=\"javascript:page_tpl.page(" + priv_page + ")\">上一页</a></li>" +
                html +
                "<li><a href=\"javascript:page_tpl.page(" + next_page + ")\">下一页</a></li>" +
                "<li><a href=\"javascript:page_tpl.page(" + max_page + ")\">末页(" + max_page + ")</a></li>";
        }
        $("#pages").html(html);
        $("#pages_count").html(count);
    },

    alert_page_html: function (company_id, max_page) {
        var c_page = $("#alert_page_id").val();
        var pages = page_tpl.page_num(c_page, max_page);

        var html = "";
        if (pages == null) {
            html = "<li class=\"disabled\"><a href=\"javascript:void(1);\">1</a></li>";
        } else {
            $.each(pages, function (i, item) {
                if (item < c_page) {
                    html += "<li><a href=\"javascript:page_tpl.alert_page_click(" + item + ", '" + company_id + "')\">" + item + "</a></li>";
                } else if (item == c_page) {
                    html += "<li class=\"disabled\"><a href=\"javascript:;\">" + item + "</a></li>";
                } else {
                    html += "<li class=\"duration\"><a href=\"javascript:page_tpl.alert_page_click(" + item + ", '" + company_id + "')\">" + item + "</a></li>";
                }
            });
        }
        $("#alert_pages").html(html);
    },

    page_num: function (c_page, max_page) {
        c_page = parseInt(c_page);
        var pages = new Array();
        if (c_page <= 2 && max_page >= 5) {
            pages = new Array(1, 2, 3, 4, 5);
            return pages;
        }
        else if (c_page > max_page) {
            return null;
        }

        else if (max_page < 5) {
            for (var i = 0; i < max_page; i++) {
                pages[i] = i + 1;
            }
            return pages;

        }
        else if (c_page >= (max_page - 3) && max_page >= 5) {
            pages[0] = max_page - 4;
            pages[1] = max_page - 3;
            pages[2] = max_page - 2;
            pages[3] = max_page - 1;
            pages[4] = max_page;
            return pages;

        }
        else {
            pages[0] = c_page - 2;
            pages[1] = c_page - 1;
            pages[2] = c_page;
            pages[3] = c_page + 1;
            pages[4] = c_page + 2;
            return pages;

        }
    }
};

