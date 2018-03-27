var chart_handler = {
    chart_index: function () {
        chart_sproto.chart_1(function (data) {
            if (data.all_times != [] && data.all_times != undefined) {
                chart_view.chart_index(data.all_times);
            }
        });
    },
    chart_lv: function () {
        chart_view.chart_lv(data);

        // var arg = $("#form_list").serialize();
        // chart_sproto.chart_lv(url.html_encode(arg), function (data) {
        //     if (data.all_times != [] && data.all_times != undefined) {
        //         chart_view.chart_lv(data);
        //     }
        // });
    }
};