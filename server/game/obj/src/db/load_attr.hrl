%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 19. 七月 2016 下午2:44
%%%-------------------------------------------------------------------

-define(tab_name, player_attr).
-define(tab_last_name, attr_20170728).

-record(attr_20170728, {
    uid,
    is_ai = 0, %0:不是机器人
    nick = <<>>,
    sex = 0,
    icon = <<>>,
    gold = 0,
    diamond = 0,
    lv = 0,
    exp = 0,
    sign = <<>>,
    gmt_offset = 28800,     %时区偏移量 8*3600
    address = <<>>,
    room_pid = <<>>,
    mtt_pid = <<>>,
    sng_score = 0,
    all_rmb = 0,
    bank_poll = 0,
    refresh_times = 0,      %刷新时间
    offline_times = 0,
    client_setting = <<>>,
    active_point = 0,       %活跃度
    active_rewards = [],       %活跃度奖励
    vip_lv = 0,
    vip_exp = 0,
    c_times
}).
