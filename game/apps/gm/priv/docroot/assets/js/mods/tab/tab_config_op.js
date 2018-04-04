var tab_config_op = {
    is_edit: false,

    edit_tree_lv: 1,
    edit_tree_default_v: '0',

    edit_state: new Array(),


    reset_op: function () {
        tab_config_op.is_edit = false;
        tab_config_op.edit_tree_lv = 1;
        tab_config_op.edit_tree_default_v = "0";
        tab_config_op.edit_state = new Array();
    },

    '9': function (obj, my_pms) {
        var obj_st = my_pms[1];
        var record_item = tab_record.get_state(obj_st, obj);
        if (record_item != undefined) {
            var options = new Array();
            $.each(my_pms[2].split(","), function (i, my_pms_id) {
                for (var n = 0; n < record_item.options.length; n++) {
                    if (record_item.options[n][0] == my_pms_id) {
                        options.push([my_pms_id, record_item.options[n][1]]);
                        tab_config_op.is_edit = true;
                    }
                }
            });
            tab_config_op.edit_state = new Array();
            tab_config_op.edit_state.push(obj_st);
            record_item.options = options;
        }
    },
    '12': function (obj) {
        tab_config_op.is_edit = true;
        tab_config_op.edit_tree = obj.key;
        for (i = 0; i < obj.tab_record.length; i++) {
            if (obj.tab_record[i].id == obj.tree_id) {
                if (tab_config_op.edit_tree_default_v == "0") {
                    $("#" + obj.tree_id).val(obj.tree_default_id);
                    obj.tab_record[i].v = obj.tree_default_id;
                }
            } else {
                obj.tab_record[i].v = "";
            }
        }
    }
};
