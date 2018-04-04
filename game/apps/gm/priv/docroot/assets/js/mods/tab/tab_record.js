var tab_record = {
    id: {id: 'id', label: 'id', type: 'input'},
    uid: {id: 'uid', label: 'uid', type: 'input'},
    c_times: {id: 'c_times', label: '创建时间', type: 'times', placeholder: '必填', verify: 'minlength="1"', times_diff_day: -1},
    s_times: {id: 's_times', label: '开始时间', type: 'times', placeholder: '必填', verify: 'minlength="1"', times_diff_day: -1},
    e_times: {id: 'e_times', label: '结束时间', type: 'times', placeholder: '必填', verify: 'minlength="1"', times_diff_day: 0},
    stimes: {id: 'stimes', label: '开始时间', type: 'times', placeholder: '必填', verify: 'minlength="1"', times_diff_day: -1},
    etimes: {id: 'etimes', label: '结束时间', type: 'times', placeholder: '必填', verify: 'minlength="1"', times_diff_day: -1},
    op_state: {
        id: "op_state",
        label: "是否发布",
        type: "switch",
        options: [["all_special_character", "-请选择-"], ["0", "未发布"], ["1", "已发布"]]
    },
    channel_id: {
        id: "channel_id", label: "渠道名称", type: "select",
        options: function () {
            sys_handler.get_options("2");
            return tab_config.options_channel;
        }
    },
    channel_2_id: {
        id: "channel_id", label: "渠道名称", type: "select_2",
        options: function () {
            sys_handler.get_options("2");
            return tab_config.options_channel;
        }
    },
    packet_id: {
        id: "packet_id", label: "包名", type: "select",
        options: function () {
            sys_handler.get_options("3");
            return tab_config.options_packet;
        }
    },
    get_state: function (state_key, obj) {
        if (state_key == "op_state") {
            return obj.op_state;
        } else if (state_key == "state") {
            return obj.state;
        } else if (state_key == "status") {
            return obj.status;
        }
    },
    ad_place: {
        id: "ad_place",
        label: "权重值",
        edit_type: 'select',
        options: [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31], [32, 32], [33, 33], [34, 34], [35, 35], [36, 36], [37, 37], [38, 38], [39, 39], [40, 40], [41, 41], [42, 42], [43, 43], [44, 44], [45, 45], [46, 46], [47, 47], [48, 48], [49, 49], [50, 50],
            [51, 51], [52, 52], [53, 53], [54, 54], [55, 55], [56, 56], [57, 57], [58, 58], [59, 59], [60, 60], [61, 61], [62, 62], [63, 63], [64, 64], [65, 65], [66, 66], [67, 67], [68, 68], [69, 69], [70, 70], [71, 71], [72, 72], [73, 73], [74, 74], [75, 75], [76, 76], [77, 77], [78, 78], [79, 79], [80, 80], [81, 81], [82, 82], [83, 83], [84, 84], [85, 85], [86, 86], [87, 87], [88, 88], [89, 89], [90, 90], [91, 91], [92, 92], [93, 93], [94, 94], [95, 95], [96, 96], [97, 97], [98, 98], [99, 99],
            [100, 100]],
        verify: 'required data-am-selected="{searchBox: 1}"'
    },

    prize_type: {
        id: "type_id",
        label: "类型",
        type: "select",
        options: [
            ["all_special_character", "-请选择-"], ["121001", "个人天梯赛段位升级"], ["122001", "个人天梯赛精英赛参赛券奖励"], ["124001", "传说段位个人天梯赛奖励"], ["124002", "传说段位个人天梯赛奖励"], ["124003", "传说段位个人天梯赛奖励"], ["125002", "青铜Ⅱ个人天梯赛赛季奖励"], ["125003", "青铜Ⅲ个人天梯赛赛季奖励"], ["125004", "白银Ⅰ个人天梯赛赛季奖励"], ["125005", "白银Ⅱ个人天梯赛赛季奖励"], ["125006", "白银Ⅲ个人天梯赛赛季奖励"], ["125007", "黄金Ⅰ个人天梯赛赛季奖励"], ["125008", "黄金Ⅱ个人天梯赛赛季奖励"], ["125009", "黄金Ⅲ个人天梯赛赛季奖励"], ["125010", "黄金4个人天梯赛赛季奖励"], ["125011", "黄金5个人天梯赛赛季奖励"], ["125012", "白金Ⅰ个人天梯赛赛季奖励"], ["125013", "白金Ⅱ个人天梯赛赛季奖励"], ["125014", "白金Ⅲ个人天梯赛赛季奖励"], ["125015", "白金4个人天梯赛赛季奖励"], ["125016", "白金5个人天梯赛赛季奖励"], ["125017", "钻石Ⅰ个人天梯赛赛季奖励"], ["125018", "钻石Ⅱ个人天梯赛赛季奖励"], ["125019", "钻石Ⅲ个人天梯赛赛季奖励"], ["125020", "钻石4个人天梯赛赛季奖励"], ["125021", "钻石5个人天梯赛赛季奖励"], ["125022", "金钻1个人天梯赛赛季奖励"], ["125023", "金钻2个人天梯赛赛季奖励"], ["125024", "金钻3个人天梯赛赛季奖励"], ["125025", "金钻4个人天梯赛赛季奖励"], ["125026", "金钻5个人天梯赛赛季奖励"], ["125027", "紫钻1个人天梯赛赛季奖励"], ["125028", "紫钻2个人天梯赛赛季奖励"], ["125029", "紫钻3个人天梯赛赛季奖励"], ["125030", "紫钻4个人天梯赛赛季奖励"], ["125031", "紫钻5个人天梯赛赛季奖励"], ["125032", "紫金Ⅰ个人天梯赛赛季奖励"], ["125033", "紫金Ⅱ个人天梯赛赛季奖励"], ["125034", "紫金Ⅲ个人天梯赛赛季奖励"], ["125035", "紫金4个人天梯赛赛季奖励"], ["125036", "紫金5个人天梯赛赛季奖励"], ["125037", "大师1个人天梯赛赛季奖励"], ["125038", "大师2个人天梯赛赛季奖励"], ["125039", "大师3个人天梯赛赛季奖励"], ["125040", "大师4个人天梯赛赛季奖励"], ["125041", "大师5个人天梯赛赛季奖励"], ["125042", "王者1个人天梯赛赛季奖励"], ["125043", "王者2个人天梯赛赛季奖励"], ["125044", "王者3个人天梯赛赛季奖励"], ["125045", "王者4个人天梯赛赛季奖励"], ["125046", "王者5个人天梯赛赛季奖励"], ["125047", "史诗Ⅰ个人天梯赛赛季奖励"], ["125048", "史诗Ⅱ个人天梯赛赛季奖励"], ["125049", "史诗Ⅲ个人天梯赛赛季奖励"], ["125050", "史诗4个人天梯赛赛季奖励"], ["125051", "史诗5个人天梯赛赛季奖励"], ["125052", "传说段位按照排名发放奖励"], ["125053", "传说257~512"], ["125054", "传说129~256"], ["125055", "传说65~128"], ["125056", "传说33~64"], ["125057", "传说17~32"], ["125058", "传说9~16"], ["125059", "传说4~8"], ["125060", "传说3"], ["125061", "传说2"], ["125062", "传说1"], ["130001", "签到周1奖励"], ["130002", "签到周2奖励"], ["130003", "签到周3奖励"], ["130004", "签到周4奖励"], ["130005", "签到周5奖励"], ["130006", "签到周6奖励"], ["130007", "签到周7奖励"], ["131001", "签到累计三天奖励"], ["131002", "签到累计五天奖励"], ["131003", "签到累计七天奖励"]
        ]
    }
};

var tab_field = {
    label: null,         //标签
    id: null,            //字段名称
    v: null,             //字段内容
    type: null,          //字段类型
    tor: "string",          //type = "per", tor字段/minator字段
    minator: "string",
    fun:function(){alert("fun");},   //type == "fun"
    edit_type:null,
    options: null,      //type == "select",options有值
    placeholder: '',
    verify: '',         //验证类型是否正确 verify: "readonly"
    verify_msg: '',
    times_diff_day:0    //时间默认值
};