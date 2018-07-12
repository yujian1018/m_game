%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 一月 2017 上午11:10
%%%-------------------------------------------------------------------
-module(load_report_data_center_d).

-export([
    echarts_1/2
]).

echarts_1(-1, -1) ->
    echarts_1(1, -999);


echarts_1(_PacketId, ChannelId) ->
    ZeroTime = integer_to_binary(erl_time:zero_times()),
    erl_mysql:execute(pool_log_1, [<<"select times, c_accounts, recharge_amount, recharge_accounts, recharge_count, login_roles from report_data_center_d where times >=", ZeroTime/binary, " and channel_id = ", (integer_to_binary(ChannelId))/binary, ";">>]).

