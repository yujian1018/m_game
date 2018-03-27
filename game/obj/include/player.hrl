%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 28. 七月 2017 下午12:17
%%%-------------------------------------------------------------------


%% @doc 不要随便修改初始化模块的位置
-define(ALL_PLAYER_MODS, [
    attr_handler,
    online_handler,
    item_handler,
    mail_handler,
    turntable_handler,
    career_handler,
    mtt_handler,
    task_handler,
    guide_handler,
    eip_handler,
    buff_handler,
    fund_handler,
    room_handler,
    active_handler,
    card_handler,
    vip_handler
]).



-define(ALL_ALLOW_TAB, [
    <<"config_attr">>,
    <<"config_item">>,
    <<"config_lvup">>,
    <<"config_lvup_vip">>,
    <<"config_mail">>,
    <<"config_shop">>,
    <<"config_task">>,
    <<"config_vip">>,
    <<"global_active">>,
    <<"global_active_gift">>,
    <<"global_active_prize">>,
    <<"global_config">>,
    <<"global_cost">>,
    <<"err_code_cn">>,
    <<"global_prize">>
]).
