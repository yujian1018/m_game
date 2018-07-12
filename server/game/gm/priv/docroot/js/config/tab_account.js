var tab_account = {
    'log_gm_op': {
        key: "cmd",
        tab_record: [
            tab_record.id,
            {id: "cmd", label: "cmd", type: "input"},
            tab_record.uid,
            tab_record.c_times
        ]
    },
    'pms_all': {
        key: "id",
        tree_id: "top_id",
        tree_default_id: "0",
        tree_max_tree_lv: 3,
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "top_id", label: 'top_id', type: "hidden", v: 0},
            {id: "name", label: "名称", type: "input"},
            {id: "url", label: "链接地址", type: "input"},
            {id: "tab", label: "表名", type: "input"},
            {id: "pms_op", label: "权限", type: "input"}
        ]
    },
    'pms_role': {
        key: "role_id",
        tab_record: [
            {id: "role_id", label: "role_id", type: "hidden"},
            {id: "role_name", label: "角色名称", type: "input"}
        ]
    },
    'gm_account': {
        key: "id",
        tab_record: [
            {id: "id", label: "id", type: "hidden"},
            {id: "account_id", label: "账户名称", type: "input"},
            {id: "pwd", label: "密码", type: "input"},
            {
                id: "pms_role_id", label: "权限角色", type: "select",
                options: function () {
                    sys_handler.get_options("1");
                    console.log(tab_config.options_pms_roles);
                    return tab_config.options_pms_roles;
                }
            }
        ]
    }
};