var excel_handler = {
    per: function () {
        var arg = $("#form_list").serialize();

        $("#table tr").each(function (index, element) {
            if ($(this).find("[rowspan]").length == 3) {
                $(this).find("td:eq(1)").html("0");
                $(this).find("td:eq(2)").html("0");
                $(this).find("td:eq(4)").html("0");
                $(this).find("td:eq(5)").html("0");
                $(this).find("td:eq(6)").html("");
            } else {
                $(this).find("td:eq(1)").html("0");
                $(this).find("td:eq(2)").html("0");
                $(this).find("td:eq(3)").html("");
            }
        });
        tab_sproto._P_tab_list("tab_name=" + config.get_tab_name() + "&" + url.html_encode(arg), function (data) {
            var count_prize = data.asset_count_prize, count_cost = data.asset_count_cost,
                type_count = 0, this_num = 0, new_index = 0;
            var max_index_prize = $("#asset_prize tr").length - 1;
            var max_index_cost = $("#asset_cost tr").length - 1;
            $("#asset_count_prize").html(count_prize);

            if (config.tab_name == "report_login_out") {
                var html = "";
                $.each(count_cost, function (i, item) {
                    html += config_layer[item[0]] + ":" + item[1] + "<br/>";
                });
                $("#asset_count_cost").html(html);
            } else {
                $("#asset_count_cost").html(count_cost);
            }
            var html = "";
            $.each(data.ret, function (i, item) {
                $("#" + item[0]).html(item[1]);
                $("#" + item[0]).siblings().last().html(item[2]);
                if (config.tab_name == "report_login_out") {
                        html += "<tr><td>" +config_layer[item[0]] + "</td><td>" + item[1] + "</td><td>" + math.eval_divide(item[1], count_prize, "%") + "%</td><td>"+item[2]+"</td></tr>";
                }
            });
            if (config.tab_name == "report_asset_gold" || config.tab_name == "report_asset_diamond"){
                var week_task_num = 0, week_task_role_num = 0, task_num = 0, task_role_num = 0;
                $.each(data.ret, function (i, item) {
                    if(item[0] == 100503001||item[0] == 100503002||item[0] == 100503003||item[0] == 100503004||
                    item[0] == 100503005||item[0] == 100503006||item[0] == 100503007||item[0] == 100503008||
                    item[0] == 100503009||item[0] == 100503010||item[0] == 100503011||item[0] == 100503012){
                        week_task_num += item[1];
                        week_task_role_num += item[2]
                    }else if(item[0] == 100501001||item[0] == 100501002||item[0] == 100501003||item[0] == 100501004||
                    item[0] == 100501005||item[0] == 100501006||item[0] == 100501007||item[0] == 100501008||
                    item[0] == 100501009||item[0] == 100501010||item[0] == 100501011||item[0] == 100501012||
                    item[0] == 100501013||item[0] == 100501014||item[0] == 100501015||item[0] == 100501016||
                    item[0] == 100501017||item[0] == 100501018||item[0] == 100501019||item[0] == 100501020||
                    item[0] == 100501021||item[0] == 100501022||item[0] == 100501023||item[0] == 100501024||
                    item[0] == 100501025||item[0] == 100501026||item[0] == 100501027||item[0] == 100501028||
                    item[0] == 100501029){
                        task_num += item[1];
                        task_role_num += item[2]
                    }
                });
                $("#100503001").html(week_task_num);
                $("#100503001").siblings().last().html(week_task_role_num);
                $("#100501001").html(task_num);
                $("#100501001").siblings().last().html(task_role_num);
            }

            $("#table_2 .table_2_tbody").html(html);

            $("#asset_prize tr").each(function (index, element) {
                var count = count_prize;
                if ($(this).find("[rowspan]").length == 3) {
                    this_num = parseInt($(this).find("td:eq(4)").html());
                    $(this).find("td:eq(5)").html(math.eval_divide(this_num, count, "%") + "%");
                    $("#asset_prize tr:eq(" + new_index + ")").find("td:eq(1)").html(type_count);
                    $("#asset_prize tr:eq(" + new_index + ")").find("td:eq(2)").html(math.eval_divide(type_count, count, "%") + "%");
                    if (index == max_index_prize) {
                        $("#asset_prize tr:eq(" + index + ")").find("td:eq(1)").html(this_num);
                        $("#asset_prize tr:eq(" + index + ")").find("td:eq(2)").html(math.eval_divide(this_num, count, "%") + "%");
                    }
                    type_count = this_num;
                    new_index = index;
                } else {
                    this_num = parseInt($(this).find("td:eq(1)").html());
                    $(this).find("td:eq(2)").html(math.eval_divide(this_num, count, "%") + "%");
                    type_count += this_num;
                    if (index == max_index_prize) {
                        $("#asset_prize tr:eq(" + new_index + ")").find("td:eq(1)").html(type_count);
                        $("#asset_prize tr:eq(" + new_index + ")").find("td:eq(2)").html(math.eval_divide(type_count, count, "%") + "%");
                    }
                }
            });

            type_count = 0;
            new_index = 0;
            $("#asset_cost tr").each(function (index, element) {
                var count = count_cost;
                if ($(this).find("[rowspan]").length == 3) {
                    this_num = parseInt($(this).find("td:eq(4)").html());
                    $(this).find("td:eq(5)").html(math.eval_divide(this_num, count, "%") + "%");
                    $("#asset_cost tr:eq(" + new_index + ")").find("td:eq(1)").html(type_count);
                    $("#asset_cost tr:eq(" + new_index + ")").find("td:eq(2)").html(math.eval_divide(type_count, count, "%") + "%");
                    if (index == max_index_prize) {
                        $("#asset_prize tr:eq(" + index + ")").find("td:eq(1)").html(this_num);
                        $("#asset_prize tr:eq(" + index + ")").find("td:eq(2)").html(math.eval_divide(this_num, count, "%") + "%");
                    }
                    type_count = this_num;
                    new_index = index;
                } else {
                    this_num = parseInt($(this).find("td:eq(1)").html());
                    $(this).find("td:eq(2)").html(math.eval_divide(this_num, count, "%") + "%");
                    type_count += this_num;
                    if (index == max_index_cost) {
                        $("#asset_cost tr:eq(" + new_index + ")").find("td:eq(1)").html(type_count);
                        $("#asset_cost tr:eq(" + new_index + ")").find("td:eq(2)").html(math.eval_divide(type_count, count, "%") + "%");
                    }
                }
            })
        });
    }
};