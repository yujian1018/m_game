var chart_view = {
    chart_index: function (data) {
        var chart1 = echarts.init(document.getElementById('chart_1'));
        var chart2 = echarts.init(document.getElementById('chart_2'));
        var xAxisData = [], Data1 = [], Data2 = [], Data3 = [], Data4 = [], Data5 = [];

        for (var i = 0; i < data.length; i++) {
            xAxisData[i] = time_lib.now_to_times(data[i].times).split(" ")[1];
            Data1[i] = data[i].c_accounts;
            Data2[i] = math.eval_divide(data[i].recharge_amout, 100, ".");
            Data3[i] = data[i].recharge_accounts;
            Data4[i] = data[i].recharge_count;
            Data5[i] = data[i].login_roles;
        }
        // 指定图表的配置项和数据
        var option = {
            title: {text: '今日数据'},
            tooltip: {trigger: 'axis'},
            legend: {data: ['注册总数', '充值玩家', '充值次数', '登陆数量']},
            grid: {left: '3%', right: '4%', bottom: '3%', containLabel: true},
            toolbox: {feature: {saveAsImage: {}}},
            xAxis: {data: xAxisData},
            yAxis: {},
            series: [
                {name: '注册总数', type: 'line', data: Data1},
                {name: '充值玩家', type: 'line', data: Data3},
                {name: '充值次数', type: 'line', data: Data4},
                {name: '登陆数量', type: 'line', data: Data5}
            ]
        };
        chart1.setOption(option);

        var option2 = {
            title: {text: '充值数据'},
            tooltip: {trigger: 'axis'},
            legend: {data: ['充值总数']},
            grid: {left: '3%', right: '4%', bottom: '3%', containLabel: true},
            toolbox: {feature: {saveAsImage: {}}},
            xAxis: {type: 'category', boundaryGap: false, data: xAxisData},
            yAxis: {type: 'value'},
            series: [{name: '充值总数(美金)', type: 'line', data: Data2}]
        };
        chart2.setOption(option2);
    },
    chart_lv: function (data) {
        var chart1 = echarts.init(document.getElementById('chart_all_lv'));
        option = {
            title: {
                text: '同名数量统计',
                subtext: '纯属虚构',
                x: 'center'
            },
            tooltip: {
                trigger: 'item',
                formatter: "{a} <br/>{b} : {c} ({d}%)"
            },
            legend: {
                type: 'scroll',
                orient: 'vertical',
                right: 10,
                top: 20,
                bottom: 20,
                data: ["1", "2", "3", "4", "5"]
            },
            series: [
                {
                    name: '姓名',
                    type: 'pie',
                    radius: '55%',
                    center: ['40%', '50%'],
                    data: [{name: "1", value: 100}, {name: "2", value: 100}, {name: "3", value: 100}, {
                        name: "4",
                        value: 100
                    }, {name: "5", value: 100}],
                    itemStyle: {
                        emphasis: {
                            shadowBlur: 10,
                            shadowOffsetX: 0,
                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                        }
                    }
                }
            ]
        };
        chart1.setOption(option);
    }
};
