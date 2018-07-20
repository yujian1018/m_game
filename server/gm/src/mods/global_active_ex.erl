%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 三月 2017 下午5:00
%%%-------------------------------------------------------------------
-module(global_active_ex).

-include("gm_pub.hrl").

-export([update/2]).

update(_TabName, Args) ->
    Id = list_can:exit_v_not_null(<<"id">>, Args),
    STimesBin = list_can:exit_v_not_null(<<"s_times">>, Args),
    ETimesBin = list_can:exit_v_not_null(<<"e_times">>, Args),
    STimes = erl_time:time2timer(STimesBin),
    ETimes = erl_time:time2timer(ETimesBin),
    Now = erl_time:now(),
    if
        STimes < ETimes andalso Now + 300 + 5 =< ETimes ->
            [SYear, SMon, SDay, SHour, SMi, _SS] = binary:split(STimesBin, [<<"-">>, <<" ">>, <<":">>], [global]),
            [EYear, EMon, EDay, EHour, EMi, _ES] = binary:split(ETimesBin, [<<"-">>, <<" ">>, <<":">>], [global]),
            erl_mysql:execute(pool_static, <<"update global_cron set `year` = '", SYear/binary, "', `month` = '",
                SMon/binary, "', `day` = '", SDay/binary, "', `hour` = '", SHour/binary, "', `minite` = '", SMi/binary,
                "' where id = '", Id/binary, "' and `event` = 1;update global_cron set `year` = '", EYear/binary, "', `month` = '",
                EMon/binary, "', `day` = '", EDay/binary, "', `hour` = '", EHour/binary, "', `minite` = '", EMi/binary,
                "' where id = '", Id/binary, "' and `event` = 0;">>),
            R2 = [{K, V} || {K, V} <- Args, V =/= <<>>],
            FunFoldl =
                fun({K, V}, Record) ->
                    {Index, NewV} = global_active:to_index(K, V),
                    setelement(Index, Record, NewV)
                end,
            VO = lists:foldl(FunFoldl, global_active:record(), R2),
            global_active:update(VO);
        true -> error
    end,
    0.
    