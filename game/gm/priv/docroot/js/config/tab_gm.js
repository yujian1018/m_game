var tab_gm = {
    'bulletin': {
        key: "id",
        op_state: tab_record.op_state,
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            tab_record.channel_id,
            tab_record.stimes,
            tab_record.etimes,
            {id: "title", label: "标题", type: "input", placeholder: '输入标题', verify: 'minlength="2"'},
            {
                id: "icon",
                label: "icon",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["20", "宣传相关的喇叭图标"], ["1", "游戏相关的金币图标"], ["15", "实物兑奖的礼包图标"]]
            },
            {id: "content", label: "公告内容", type: "textarea", placeholder: '输入内容', verify: 'minlength="10"'},
            {
                id: "sort",
                label: "显示顺序",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["1", "优先级1"], ["2", "优先级2"], ["3", "优先级3"], ["4", "优先级4"], ["5", "优先级5"]]
            },
            tab_record.op_state
        ]
    },
    'notice_scroll': {
        key: "id",
        op_state: tab_record.op_state,
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            tab_record.channel_id,
            {id: "stimes", label: "开始时间", type: "times"},
            {id: "etimes", label: "结束时间", type: "times"},
            {
                id: "diff_time",
                label: "间隔时间(秒)",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["120", "120秒"], ["180", "180秒"], ["240", "240秒"], ["300", "300秒"], ["1800", "1800秒"]],
                verify: 'min="120"'
            },
            {id: "content", label: "跑马灯内容", type: "textarea"},
            tab_record.op_state
        ]
    },
    'channel_mng': {
        key: "id",
        op_state: tab_record.op_state,
        tab_record: [
            {id: "id", label: "渠道內部编号", type: "hidden"},
            {id: "version", label: "客户端版本号", type: "input", title: "客户端版本号"},
            tab_record.channel_id,
            {id: "game_ip", label: "服务器ip地址", type: "input"},
            {id: "game_port", label: "服务器端口号", type: "input"},
            tab_record.op_state
        ]
    },
    'mail_mng': {
        key: "id",
        op_state: tab_record.op_state,
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            tab_record.channel_id,
            {id: "a_times", label: "激活群发时间", type: "times"},
            {id: "d_times", label: "邮件超时时间", type: "times"},
            {id: "e_time", label: "下发邮件过期天数(天)", edit_type:"input"},
            {
                id: "type",
                label: "邮件类型",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["0", "普通邮件"], ["1", "福利邮件"], ["2", "补偿邮件"]]
            },
            {id: "mail_id", label: "标题", type: "hidden"},
            {id: "title", label: "标题", edit_type: "input"},
            {id: "content", label: "内容", edit_type: "textarea"},
            {id: "appendix", label: "附件", type: "select", options:function(){
                sys_handler.get_options("13");
                return tab_config.options_mail_prize_ids;
            }},
            {id: "limit", label: "邮件下发限制", edit_type: "input"},
            tab_record.op_state
        ]
    },
    'channel_url': {
        key: "channel_id",
        op_state: tab_record.op_state,
        tab_record: [
            tab_record.channel_id,
            {id: "url", label: "商店应用下载地址", type: "input"},
            tab_record.op_state
        ]
    },
    'web_global': {
        key: "id",
        op_state: tab_record.op_state,
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "k", label: "全局数据类型", type: "select", options: [["all_special_character", "-请选择-"], ["1", "维护公告"]]},
            {id: "v", label: "内容", type: "textarea"},
            tab_record.op_state
        ]
    },
    'channel': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "top_id", label: "top_id", type: "hidden"},
            {id: "channel_id", label: "渠道编号", type: "input"},
            {id: "channel_name", label: "渠道名称", type: "input"}
        ]
    },
    'packet': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "packet_id", label: "包编号", type: "input"},
            {id: "packet", label: "包名称", type: "input"}
        ]
    },
    'log_send_mail': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "uid", label: "玩家编号(uid)", type: "input"},
            tab_record.channel_id,
            tab_record.c_times,
            {
                id: "type",
                label: "邮件类型",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["0", "普通邮件"], ["1", "福利邮件"], ["2", "补偿邮件"]]
            },
            {id: "title", label: "邮件标题", type: "input"},
            {id: "content", label: "邮件内容", type: "textarea"},
            {id: "appendix", label: "附件", type: "input"}
        ]
    },
    'global_active': {
        key: "id",
        op_state: tab_record.op_state,
        tab_record: [
            {id: "id", label: "id", type: "input"},
            {id: "comment", label: "描述"},
            {
                id: "time_type",
                label: "活动类型",
                type: "select", edit_type: "null",
                options: [["all_special_character", "-请选择-"], ["-1", "活动未启动"], ["0", "限时活动"], ["1", "一次性活动"], ["2", "每日活动"]]
            },
            {
                id: "progress_type",
                label: "活动进度类型",
                type: "select", edit_type: "null",
                options: [["all_special_character", "-请选择-"], ["1", "奖励活动"], ["2", "累计活动"], ["3", "条件活动"]]
            },
            {
                id: "prize_type",
                label: "奖励类型",
                type: "select", edit_type: "null",
                options: [["all_special_character", "-请选择-"], ["0", "服务端发放"], ["1", "客户端领取"]]
            },
            tab_record.s_times,
            tab_record.e_times,
            {
                id: "op_state",
                label: "是否发布",
                type: "switch", edit_type: "null",
                options: [["all_special_character", "-请选择-"], ["0", "未发布"], ["1", "已发布"]]
            }
        ]
    },

    'white_list': {
        key: ["uin", "uid"],
        tab_record: [
            {id: "uin", label: "账户id", type: "input", verify: "minlength='1'"},
            {id: "uid", label: "角色id", type: "input", verify: "minlength='1'"}
        ]
    },

    'feedback': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "uid", label: "uid", type: "input", edit_type: "hidden"},
            {id: "auto_id", label: "auto_id", type: "input", edit_type: "hidden"},
            {id: "udid", label: "udid"},
            {id: "ip", label: "ip"},
            {id: "c_times", label: "创建时间", type: "times", edit_type: "null"},
            {id: "u_times", label: "更新时间", type: "times"},
            {id: "msg", label: "反馈信息", type: "textarea", verify: "readonly"},
            {id: "contact", label: "联系方式"},
            {
                id: "status",
                label: "状态",
                type: "select",
                edit_type: "null",
                options: [["all_special_character", "-请选择-"], ["0", "已反馈"], ["1", "已删除"]]
            },
            {
                id: "op_status",
                label: "操作状态",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["0", "已反馈"], ["1", "已查看"], ["2", "已处理"]]
            }
        ]
    },

    'ai_control': {
        key: "room_type",
        tab_record: [
            {
                id: "room_type",
                label: "房间号",
                type: "select",
                edit_type: "select",
                options: [["all_special_character", "-请选择-"],
                    ["1", "2000"], ["2", "4000"], ["3", "10K"], ["4", "20K"], ["5", "100K"],
                    ["6", "200K"], ["7", "400K"], ["8", "800K"], ["9", "1500K"], ["10", "3000K"]]
            },
            {id: "type", label: "ai难度控制(-100ai难度越低 --- 100ai难度越高)", type: "input", verify: "minlength='1'"},
            {id: "add_rating", label: "增加难度值", type: "input", verify: "minlength='1'"},
            {id: "max_rating", label: "最大难度值", type: "input", verify: "minlength='1'"},
            {id: "player_1", label: "1个玩家，最大ai数量", type: "input", verify: "minlength='1'"},
            {id: "player_2", label: "2个玩家，最大ai数量", type: "input", verify: "minlength='1'"},
            {id: "player_3", label: "3个玩家，最大ai数量", type: "input", verify: "minlength='1'"},
            {id: "player_4", label: ">=4个玩家，最大ai数量", type: "input", verify: "minlength='1'"}
        ]
    },

    'global_prize': {
            key: "prize_id",
            tab_record: [
                {id: "prize_id",label: "奖励id",type: "input", verify: "min=100701001 max=100799999"},
                {id: "prize", label: "奖励信息", type: "input", verify: "minlength='1'"},
                {id: "comment", label: "注释", type: "input", verify: "minlength='1'"}
            ]
        },

    'orders': {
        key: "order_id",
        tab_record: [
            {id: "order_id", label: "订单号", type: "input"},
            tab_record.channel_id,
            {id: "s_times", label: "订单生成时间", type: "times", times_diff_day: 0},
            {id: "e_times", label: "订单完成时间", type: "times"},
            {
                id: "state",
                label: "订单状态",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["0", "已创建订单"], ["1", "付款未发货"], ["2", "充值成功"], ["4", "取消支付"], ["5", "支付异常"]]
            },
            {
                id: "is_sandbox",
                label: "是否沙盒模式",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["0", "正式环境"], ["1", "测试环境"]]
            },
            {id: "uid", label: "角色id", type: "input"},
            {id: "goods_id", label: "商品id", type: "input"},
            {id: "goods_num", label: "商品数量", type: "input"},
            {id: "rmb", label: "rmb(分)", type: "input"},
            {id: "currency_type", label: "货币类型"},
            {id: "platform_id", label: "支付平台", type: "input"},
            {id: "attach", label: "附加信息"},
            {id: "out_order", label: "sdk订单号", type: "input"},
            {id: "order_num", label: "第三方订单号", type: "input"},
            {id: "out_order_info", label: "订单详情"}
        ]
    },

    'attr': {
        key: "uid",
        tab_record: [
            {id: "uid", label: "角色id", type: "input", verify: "readonly"},
            {
                id: "channel_id", label: "渠道名称", type: "select", edit_type: "hidden",
                options: function () {
                    sys_handler.get_options("2");
                    return tab_config.options_channel;
                }
            },
            {
                id: "is_ai",
                label: "是否为机器人",
                type: "select", edit_type: "null",
                options: [["all_special_character", "-请选择-"], ["0", "否"], ["1", "是"]]
            },
            {id: "name", label: "昵称"},
            {id: "gold", label: "金币", edit_type: "input", verify: 'min=0'},
            {id: "bank_poll", label: "战斗携带金币", edit_type: "input", verify: 'min=0'},
            {id: "diamond", label: "钻石", edit_type: "input", verify: 'min=0'},
            {id: "lv", label: "等级", edit_type: "input", verify: 'min=1 max=30'},
            {id: "exp", label: "经验值", edit_type: "input", verify: 'min=0'},
            {id: "infullmount", label: "充值总额(分)"},
            {id: "sng_score", label: "sng积分"},
            {id: "c_times", label: "角色创建时间", type: "times", edit_type: "null"},
            {id: "offline_times", label: "下线时间", type: "times", edit_type: "null"},
            {id: "vip_lv", label: "vip等级", edit_type: "input", verify: 'min=0 max=9'},
            {id: "vip_exp", label: "vip经验值", edit_type: "input", verify: 'min=0'}
        ]
    },
    'card': {
        key: "uid",
        tab_record: [
            tab_record.channel_id,
            {id: "uid", label: "角色id", type: "input"},
            {
                id: "is_whitelist",
                label: "是否白名单",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["0", "否"], ["1", "是"]]
            },
            {id: "vip_lv", label: "vip等级"},
            {
                id: "card_type",
                label: "月卡类型",
                type: "select",
                options: [["all_special_character", "-请选择-"], ["1", "周卡（4.99）"], ["2", "月卡（19.99）"], ["3", "月卡（49.99）"]]
            },
            {id: "deadline_times", label: "月卡截止时间", type: "times"}
        ]
    },
    'role_ban': {
        key: "uin",
        tab_record: [
            {id: "uin", label: "账户id", type: "input"},
            tab_record.channel_2_id,
            {id: "ban_times", label: "封号截止时间", type: "times"}
        ]
    },
    'player': {
        key: "uid",
        tab_record: [
            {id: "uid", label: "角色id", type: "input"},
            {id: "uin", label: "账户id", type: "input"}
        ]
    },

    'career': {
        key: "uid",
        tab_record: [
            {id: "uid", label: "角色id", type: "input"},
            {id: "win", label: "获胜次数"},
            {id: "lose", label: "输掉次数"},
            {id: "in_game", label: "进入牌局次数"},
            {id: "add_gold", label: "赢钱"},
            {id: "folp_add", label: "加注次数"},
            {id: "max_score", label: "最大牌型积分"},
            {id: "max_poker", label: "最大牌型"},
            {id: "max_win_gold", label: "最大赢钱数"},
            {id: "sng_champion", label: "最大赢钱数"},
            {id: "sng_second", label: "最大赢钱数"},
            {id: "sng_lose", label: "最大赢钱数"},
            {id: "mtt_num", label: "最大赢钱数"},
            {id: "mtt_win", label: "最大赢钱数"},
            {id: "mtt_max_rank", label: "最大赢钱数"},
            {id: "sng_1_score", label: "sng1大师分", edit_type: "input"},
            {id: "sng_2_score", label: "sng2大师分", edit_type: "input"},
            {id: "sng_3_score", label: "sng3大师分", edit_type: "input"},
            {id: "sng_4_score", label: "sng4大师分", edit_type: "input"},
            {id: "sng_5_score", label: "sng5大师分", edit_type: "input"},
            {id: "sng_6_score", label: "sng6大师分", edit_type: "input"}
        ]
    }
};