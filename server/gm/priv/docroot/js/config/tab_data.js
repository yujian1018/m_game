var tab_data = {
    'report_data_center': {
        key: "id",
        obj_type: "tab_count",
        html: '<p>总创角数:<span id="count_roles" style="color:red;">0</span></p><p>总充值金额:<span id="count_roles" style="color:red;">0</span></p>',
        cb_fun: function (data) {
            $("#count_amount").html(data.count_amount);
            $("#count_roles").html(data.count_roles);
        },
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "times", label: "日期", type: "times", times_diff_day: -1},
            tab_record.channel_id,
            {id: "c_roles", label: "创角数量"},
            {id: "c_devices", label: "新注册设备数"},
            {id: "c_accounts", label: "帐号注册数"},
            {id: "c_guests", label: "游客注册数"},
            {id: "login_roles", label: "登陆角色数"},
            {id: "login_count", label: "登陆次数"},
            {
                id: "recharge_amount", label: "充值金额", type: "fun", fun: function (item) {
                return math.eval_divide(item["recharge_amount"], 100, "/");
            }
            },
            {id: "recharge_accounts", label: "充值用户数"},
            {id: "recharge_count", label: "充值次数"},
            {id: "recharge_per", label: "付费率", type: "per", tor: "recharge_accounts", minator: "login_roles"},
            {id: "new_recharge_accounts", label: "每日新付费用户数"},
            {
                id: "new_recharge_amount", label: "每日新用户充值金额", type: "fun", fun: function (item) {
                return math.eval_divide(item["new_recharge_amount"], 100, "/");
            }
            },
            {
                id: "arpau", label: "ARPAU", type: "fun", fun: function (item) {
                return math.eval_divide(item["recharge_amount"] / 100, item["login_roles"], "/");
            }
            },
            {
                id: "arppu", label: "ARPPU", type: "fun", fun: function (item) {
                return math.eval_divide(item["recharge_amount"] / 100, item["recharge_accounts"], "/")
            }
            },
            {id: "pcu", label: "PCU"},
            {
                id: "pcu_date", label: "最高在线时间", type: "fun", fun: function (item) {
                return time_lib.now_to_times(item["pcu_date"]);
            }
            },
            {id: "acu", label: "ACU"},
            {id: "acu_duration", label: "平均在线时长"}
        ]
    },

    'recharge_rank': {
        key: "s_times",
        tab_record: [
            {id: "s_times", label: "开始日期", type: "datetime", times_diff_day: -1},
            {id: "e_times", label: "结束日期", type: "datetime", times_diff_day: 0},
            tab_record.channel_id,
            {id: "uid", label: "角色ID"},
            {id: "c_times", label: "角色创建时间", type: "datetime"},
            {id: "vip_lv", label: "vip等级"},
            {id: "all_rmb", label: "总充值金额"},
            {id: "currency_type", label: "货币"},
            {id: "last_s_times", label: "最近一次充值时间", type: "times"},
            {id: "rmb", label: "最近一次充值额度"}
        ]
    },

    'report_retain': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "times", label: "日期", type: "times", times_diff_day: -2},
            tab_record.channel_id,
            {id: "count_roles", label: "创建角色数"},
            {id: "re_1", label: "2日留存数"},
            {id: "re_1_per", label: "2日留存率", type: "per", tor: "re_1", minator: "count_roles"},
            {id: "re_2", label: "3日留存数"},
            {id: "re_2_per", label: "3日留存率", type: "per", tor: "re_2", minator: "count_roles"},
            {id: "re_3", label: "4日留存数"},
            {id: "re_3_per", label: "4日留存率", type: "per", tor: "re_3", minator: "count_roles"},
            {id: "re_4", label: "5日留存数"},
            {id: "re_4_per", label: "5日留存率", type: "per", tor: "re_4", minator: "count_roles"},
            {id: "re_5", label: "6日留存数"},
            {id: "re_5_per", label: "6日留存率", type: "per", tor: "re_5", minator: "count_roles"},
            {id: "re_6", label: "7日留存数"},
            {id: "re_6_per", label: "7日留存率", type: "per", tor: "re_6", minator: "count_roles"},
            {id: "re_15", label: "15日留存数"},
            {id: "re_15_per", label: "15日留存率", type: "per", tor: "re_15", minator: "count_roles"},
            {id: "re_30", label: "30日留存数"},
            {id: "re_30_per", label: "30日留存率", type: "per", tor: "re_30", minator: "count_roles"}
        ]
    },

    'report_retain_udid': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "times", label: "日期", type: "times", times_diff_day: -2},
            tab_record.channel_id,
            {id: "count_roles", label: "创建设备数"},
            {id: "re_1", label: "2日留存数"},
            {id: "re_1_per", label: "2日留存率", type: "per", tor: "re_1", minator: "count_roles"},
            {id: "re_2", label: "3日留存数"},
            {id: "re_2_per", label: "3日留存率", type: "per", tor: "re_2", minator: "count_roles"},
            {id: "re_3", label: "4日留存数"},
            {id: "re_3_per", label: "4日留存率", type: "per", tor: "re_3", minator: "count_roles"},
            {id: "re_4", label: "5日留存数"},
            {id: "re_4_per", label: "5日留存率", type: "per", tor: "re_4", minator: "count_roles"},
            {id: "re_5", label: "6日留存数"},
            {id: "re_5_per", label: "6日留存率", type: "per", tor: "re_5", minator: "count_roles"},
            {id: "re_6", label: "7日留存数"},
            {id: "re_6_per", label: "7日留存率", type: "per", tor: "re_6", minator: "count_roles"},
            {id: "re_15", label: "15日留存数"},
            {id: "re_15_per", label: "15日留存率", type: "per", tor: "re_15", minator: "count_roles"},
            {id: "re_30", label: "30日留存数"},
            {id: "re_30_per", label: "30日留存率", type: "per", tor: "re_30", minator: "count_roles"}
        ]
    },

    'report_asset': {
        key: "times",
        obj_type: "tab_count",
        html: '<p>总金币数:<span id="count_gold" style="color:red;">0</span></p><p>总钻石数:<span id="count_diamond" style="color:red;">0</span></p>',
        cb_fun: function (data) {
            var gold_prize = 0, gold_cost = 0, diamond_prize = 0, diamond_cost = 0;
            $("#table_list tr").each(function (i, item) {
                gold_prize += parseInt($(this).find("td:eq(1)").html());
                gold_cost += parseInt($(this).find("td:eq(2)").html());
                diamond_prize += parseInt($(this).find("td:eq(3)").html());
                diamond_cost += parseInt($(this).find("td:eq(4)").html());
            })
            console.log(gold_prize, gold_cost);
            $("#count_gold").html(gold_prize + gold_cost);
            $("#count_diamond").html(diamond_prize + diamond_cost);
        },
        tab_record: [
            {id: "times", label: "日期", type: "times", times_diff_day: -1},
            {id: "gold_prize", label: "金币产出"},
            {id: "gold_cost", label: "金币消耗"},
            {id: "diamond_prize", label: "钻石产出"},
            {id: "diamond_cost", label: "钻石消耗"},
            {id: "count_share", label: "分享次数"},
            {id: "count_share2", label: "分享成功次数"},
            {id: "count_fight", label: "战斗次数"},
            {id: "count_turntable", label: "大转盘次数"},
            {id: "count_guide_1", label: "引导第一阶段"},
            {id: "count_guide_2", label: "引导第二阶段"},
            {id: "count_guide_3", label: "引导第三阶段"},
            {id: "count_guide_4", label: "引导第四阶段"},
            {id: "count_online_1", label: "在线奖励1"},
            {id: "count_online_2", label: "在线奖励2"},
            {id: "count_online_3", label: "在线奖励3"},
            {id: "count_online_4", label: "在线奖励4"},
            {id: "count_online_5", label: "在线奖励5"},
            {id: "count_online_6", label: "在线奖励6"},
            {id: "count_fund_1", label: "救济金奖励1"},
            {id: "count_fund_2", label: "救济金奖励2"},
            {id: "count_fund_3", label: "救济金奖励3"},
            {id: "count_fund_4", label: "救济金奖励4"}
        ]
    },

    'report_asset_gold': {
        obj_type: "excel"
    },
    'report_asset_diamond': {
        obj_type: "excel"
    },

    'report_lv': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "c_times", label: "日期", type: "datetime", times_diff_day: -1},
            tab_record.channel_id,
            {id: "lv", label: "等级"},
            {id: "count_num", label: "等级数量"}
        ]
    },

    'log_attr_lv': {
        key: "from_times",
        tab_record: [
            {id: "from_times", label: "创建日期", type: "datetime", times_diff_day: -1},
            {id: "to_times", label: "登陆日期", type: "datetime", times_diff_day: -1},
            tab_record.channel_id,
            {id: "lv", label: "等级"},
            {id: "count_num", label: "等级数量"}
        ]
    },

    'report_vip': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "c_times", label: "日期", type: "datetime", times_diff_day: -1},
            tab_record.channel_id,
            {id: "lv", label: "VIP等级"},
            {id: "count_num", label: "该等级VIP数量"}
        ]
    },

    'report_login_log': {
        key: "udid",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "times", label: "日期", type: "times", times_diff_day: -1},
            tab_record.channel_id,
            {id: "c0", label: "<font color='red'>启动应用</font>"},
            {id: "c1", label: "<font color='red'>强更完成</font>"},
            {
                id: "c1_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c0"] - item["c1"], item["c0"], "%") + "%";
            }
            },
            {id: "c2", label: "热更完成"},
            {
                id: "c2_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c1"] - item["c2"], item["c1"], "%") + "%";
            }
            },
            {id: "c3", label: "<font color='red'>加载资源完成</font>"},
            {
                id: "c3_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c2"] - item["c3"], item["c2"], "%") + "%";
            }
            },
            {id: "c4", label: "<font color='red'>登录界面打开完成</font>"},
            {
                id: "c4_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c3"] - item["c4"], item["c3"], "%") + "%";
            }
            },
            {id: "c5", label: "登陆按钮"},
            {
                id: "c5_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c4"] - item["c5"], item["c4"], "%") + "%";
            }
            },
            {id: "c51", label: "<font color='red'>链接服务器完成</font>"},
            {id: "c52", label: "获取静态表完成"},
            {
                id: "c52_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c51"] - item["c52"], item["c51"], "%") + "%";
            }
            },
            {id: "c53", label: "<font color='red'>登录游戏服完成</font>"},
            {
                id: "c53_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c52"] - item["c53"], item["c52"], "%") + "%";
            }
            },
            {id: "c54", label: "<font color='red'>loading完成</font>"},
            {
                id: "c54_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c53"] - item["c54"], item["c53"], "%") + "%";
            }
            },
            {id: "c101", label: "<font color='red'>进入到主界面完成</font>"},
            {
                id: "c101_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c54"] - item["c101"], item["c54"], "%") + "%";
            }
            },
            {id: "c102", label: "大转盘界面打开完成"},
            {
                id: "c102_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c101"] - item["c102"], item["c101"], "%") + "%";
            }
            },
            {id: "c103", label: "大转盘界面点击go按钮"},
            {
                id: "c103_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c102"] - item["c103"], item["c102"], "%") + "%";
            }
            },
            {id: "c104", label: "大转盘弹出奖励界面"},
            {
                id: "c104_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c103"] - item["c104"], item["c103"], "%") + "%";
            }
            },
            {id: "c105", label: "大转盘界面关闭"},
            {
                id: "c105_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c104"] - item["c105"], item["c104"], "%") + "%";
            }
            },
            {id: "c106", label: "首冲礼包界面打开完成"},
            {
                id: "c106_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c105"] - item["c106"], item["c105"], "%") + "%";
            }
            },
            {id: "c109", label: "首冲礼包界面关闭"},
            {
                id: "c109_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c106"] - item["c109"], item["c106"], "%") + "%";
            }
            },
            {id: "c110", label: "活动界面弹出"},
            {
                id: "c110_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c109"] - item["c110"], item["c109"], "%") + "%";
            }
            },
            {id: "c111", label: "活动界面关闭"},
            {
                id: "c111_per", label: "流失数占比", type: "fun", fun: function (item) {
                return math.eval_divide(item["c110"] - item["c111"], item["c110"], "%") + "%";
            }
            }
        ]
    },
    'report_login_out': {
        obj_type: "excel"
    },
    'report_data_ltv': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "times", label: "日期", type: "times", times_diff_day: -1},
            tab_record.channel_id,
            {id: "count_roles", label: "创建角色数"},
            {
                id: "ltv_1", label: "LTV_1", type: "fun", fun: function (item) {
                return math.eval_divide(item["ltv_1"], item["count_roles"], "/")
            }
            },
            {
                id: "ltv_2", label: "LTV_2", type: "fun", fun: function (item) {
                return math.eval_divide(item["ltv_2"], item["count_roles"], "/")
            }
            },
            {
                id: "ltv_3", label: "LTV_3", type: "fun", fun: function (item) {
                return math.eval_divide(item["ltv_3"], item["count_roles"], "/")
            }
            },
            {
                id: "ltv_4", label: "LTV_4", type: "fun", fun: function (item) {
                return math.eval_divide(item["ltv_4"], item["count_roles"], "/")
            }
            },
            {
                id: "ltv_5", label: "LTV_5", type: "fun", fun: function (item) {
                return math.eval_divide(item["ltv_5"], item["count_roles"], "/")
            }
            },
            {
                id: "ltv_6", label: "LTV_6", type: "fun", fun: function (item) {
                return math.eval_divide(item["ltv_6"], item["count_roles"], "/")
            }
            },
            {
                id: "ltv_15", label: "LTV_15", type: "fun", fun: function (item) {
                return math.eval_divide(item["ltv_15"], item["count_roles"], "/")
            }
            },
            {
                id: "ltv_30", label: "LTV_30", type: "fun", fun: function (item) {
                return math.eval_divide(item["ltv_30"], item["count_roles"], "/")
            }
            }

        ]
    },

    'report_asset_item': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "c_times", label: "日期", type: "datetime", times_diff_day: -1},
            tab_record.channel_id,
            {id: "item_id", label: "道具", type: "select", options: tab_config.options_item_ids},
            {id: "asset_id", label: "类型", type: "select", options: tab_config.options_prize_ids_item},
            {id: "v", label: "道具数量"},
            {id: "count_roles", label: "玩家数量"}
        ]
    },
    'report_asset_item_cost': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "c_times", label: "日期", type: "datetime", times_diff_day: -1},
            tab_record.channel_id,
            {id: "item_id", label: "道具", type: "select", options: tab_config.options_item_ids},
            {id: "asset_id", label: "类型", type: "select", options: tab_config.options_prize_ids_item},
            {id: "v", label: "道具数量"},
            {id: "count_roles", label: "玩家数量"}
        ]
    },

    'log_login_log': {
        key: "udid",
        tab_record: [
            {id: "udid", label: "udid"},
            {id: "uid", label: "角色id", type: "input"},
            tab_record.channel_id,
            {id: "ip", label: "ip", type: "input"},
            {id: "t0_times", label: "启动应用", type: "times", times_diff_day: -1},
            {id: "t1_times", label: "强更完成"},
            {id: "t2_times", label: "热更完成"},
            {id: "t3_times", label: "加载资源完成"},
            {id: "t4_times", label: "登录界面打开完成"},
            {id: "t5_times", label: "点击fb按钮"},
            {id: "t6_times", label: "点击游客按钮"},
            {id: "t51_times", label: "链接服务器完成"},
            {id: "t52_times", label: "获取静态表完成"},
            {id: "t53_times", label: "登录游戏服完成"},
            {id: "t54_times", label: "获取动态表完成"},
            {id: "t101_times", label: "进入到主界面完成"},
            {id: "t102_times", label: "大转盘界面打开完成"},
            {id: "t103_times", label: "大转盘界面点击go按钮"},
            {id: "t104_times", label: "大转盘弹出奖励界面"},
            {id: "t105_times", label: "大转盘界面关闭"},
            {id: "t106_times", label: "首冲礼包界面打开完成"},
            {id: "t107_times", label: "首冲礼包界面点击buy按钮"},
            {id: "t108_times", label: "首冲礼包弹出奖励界面"},
            {id: "t109_times", label: "首冲礼包界面关闭"},
            {id: "t110_times", label: "活动界面弹出"},
            {id: "t111_times", label: "活动界面关闭"}
        ]
    },

    'log_device': {
        key: "id",
        tab_record: [
            {id: "id", label: "id"},
            {id: "udid", label: "udid", type: "input"},
            {id: "uin", label: "账户id", type: "input"},
            {id: "device_pf", label: "设备渠道"},
            {id: "ip", label: "ip"},
            {id: "c_times", label: "创建时间", type: "times", times_diff_day: -1}
        ]
    },

    'log_login_op': {
        key: "id",
        tab_record: [
            {id: "id", label: "id"},
            {id: "uid", label: "uid", type: "input"},
            {
                id: "type",
                label: "登陆类型",
                type: "select_2",
                options: [["all_special_character", "-请选择-"], ["0", "登陆"], ["1", "登出"]]
            },
            {id: "v", label: "下线时界面"},
            {id: "c_times", label: "创建时间", type: "times", times_diff_day: -1}
        ]
    },

    'log_s_count': {
        key: "times",
        tab_record: [
            {id: "times", label: "统计时间", type: "times", times_diff_day: -1},
            {id: "server_id", label: "服务器id"},
            {id: "player_num", label: "角色数量"}
        ]
    },

    'log_attr_id_3': {
        key: "id",
        tab_record: [
            {id: "id", label: "id"},
            {id: "player_id", label: "玩家id", type: "input"},
            {
                id: "type_id",
                label: "类型",
                type: "select",
                options: function () {
                    sys_handler.get_options("11");
                    return tab_config.options_prize_ids;
                }
            },
            {id: "v", label: "金币数量"},
            {id: "times", label: "时间", type: "times", times_diff_day: -1}
        ]
    },

    'log_attr_id_5': {
        key: "id",
        tab_record: [
            {id: "id", label: "id"},
            {id: "player_id", label: "玩家id", type: "input"},
            {
                id: "type_id",
                label: "类型",
                type: "select",
                options: function () {
                    sys_handler.get_options("11");
                    return tab_config.options_prize_ids;
                }
            },
            {id: "v", label: "钻石数量"},
            {id: "times", label: "时间", type: "times", times_diff_day: -1}
        ]
    },

    'log_fight': {
        key: "id",
        tab_record: [
            {id: "id", label: "id"},
            {id: "uid", label: "uid", type: "input"},
            {
                id: "room_type",
                label: "房间类型",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["1", "普通房"], ["2", "SNG"], ["3", "MTT"]]
            },
            {id: "room_id", label: "具体的房间编号"},
            {id: "c_times", label: "创建时间", type: "times", times_diff_day: -1},
            {id: "is_win", label: "是否贏取"},
            {id: "log_gold_1", label: "台费"},
            {id: "log_gold_2", label: "抽水"},
            {id: "log_gold_3", label: "输赢金币"},
            {id: "play_count", label: "牌局次数"},
            {id: "play_rank", label: "本次排名"}
        ]
    },

    'log_invite': {
        key: "id",
        tab_record: [
            {id: "id", label: "id"},
            {id: "uid", label: "uid", type: "input"},
            tab_record.channel_id,
            {id: "css_type", label: "邀请类型"},
            tab_record.c_times,
            {
                id: "state", label: "邀请状态", type: "select",
                options: [["all_special_character", "-请选择-"], ["0", "点击按钮"], ["1", "邀请成功"]]
            }
        ]
    },
    'log_share': {
        key: "id",
        tab_record: [
            {id: "id", label: "id"},
            {id: "uid", label: "uid", type: "input"},
            tab_record.channel_id,
            {id: "css_type", label: "分享类型"},
            tab_record.c_times,
            {
                id: "state", label: "分享状态", type: "select",
                options: [["all_special_character", "-请选择-"], ["0", "点击按钮"], ["1", "分享成功"]]
            }
        ]
    },

    'log_task': {
        key: "uid",
        tab_record: [
            {id: "uid", label: "uid", type: "input"},
            {id: "chain_id", label: "任务链id"},
            {id: "index", label: "完成阶段"},
            {id: 'u_times', label: '更新时间', type: 'times', times_diff_day: -1}
        ]
    }


};
