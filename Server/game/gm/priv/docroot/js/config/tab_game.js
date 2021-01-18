var tab_game = {
    'server_list': {
        key: "id",
        tab_record: [
            {id: "id", label: "服务器id", type: "input"},
            {id: "ip", label: "ip", type: "input"},
            {id: "port", label: "port", type: "input"},
            {id: "name", label: "服务器名称"},
            {id: "node", label: "服务器节点"},
            {id: "version", label: "版本号"},
            {id: "player_count", label: "在线数量"}
        ]
    },
    'config_tabs': {
        key: "tab_name",
        tab_record: [
            {id: "tab_name", label: "表名", type: "input"},
            {id: "obj_server", label: "游戏服模块名称", type: "input"},
            {id: "fight_server", label: "战斗服模块名称", type: "input"}
        ]
    }
};