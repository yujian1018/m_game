%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 19. 七月 2016 下午2:42
%%%-------------------------------------------------------------------
-module(load_log_online).

-include("log_online_auto_sql.hrl").
-include("logic_pub.hrl").

-export([load_data/1, save_data/1]).

-export([
    get_times/1,
    day_refresh/1
]).


sql(Uid) ->
    Today = erl_time:zero_times(),
    <<"select `times`, `time` from `log_online` where `uid` = ", (integer_to_binary(Uid))/binary, " AND `times` = ", (integer_to_binary(Today))/binary, ";">>.


load_data(Uid) ->
    Fun =
        fun([VO | VOAcc]) ->
            Record = log_online_auto_sql:to_record(Uid, VO),
            log_online_auto_sql:insert(Record),
            VOAcc
        end,
    {sql(Uid), Fun}.


save_data(Uid) ->
    Record = log_online_auto_sql:lookup(Uid),
    UidBin = integer_to_binary(Uid),
    Now = erl_time:now(),
    LoginTimes = ?get(?login_times),
    ZeroTimes = erl_time:zero_times(),
    if
        Record#log_online.items =:= [] ->
            <<"INSERT INTO `log_online` (`times`, `uid`, `time`) VALUES (",
                (integer_to_binary(ZeroTimes))/binary, ",", UidBin/binary, ",", (integer_to_binary(Now - LoginTimes))/binary, ");">>;
        true ->
            Fun =
                fun(Item) ->
                    if
                        Item#?tab_last_name.times =:= ZeroTimes andalso Item#?tab_last_name.op == ?OP_ADD ->
                            Time = integer_to_binary(Now - LoginTimes + Item#?tab_last_name.time),
                            <<"insert into log_online ( `times`, uid, `time`) values ( '",
                                (integer_to_binary(Item#?tab_last_name.times))/binary, "','",
                                (integer_to_binary(Uid))/binary, "','",
                                Time/binary, "');">>;
                        Item#?tab_last_name.times =:= ZeroTimes ->
                            Time = integer_to_binary(Now - LoginTimes + Item#?tab_last_name.time),
                            <<"update log_online set `time` = '", Time/binary, "' where uid = ",
                                (integer_to_binary(Uid))/binary, " and `times` = '", (integer_to_binary(Item#?tab_last_name.times))/binary, "';">>;
                        Item#?tab_last_name.op == ?OP_ADD ->
                            Time = integer_to_binary(Now - LoginTimes + Item#?tab_last_name.time),
                            <<"insert into log_online ( `times`, uid, `time`) values ( '",
                                (integer_to_binary(Item#?tab_last_name.times))/binary, "','",
                                (integer_to_binary(Uid))/binary, "','",
                                Time/binary, "');">>;
                        Item#?tab_last_name.op == ?OP_UPDATE ->
                            Time = integer_to_binary(Now - LoginTimes + Item#?tab_last_name.time),
                            <<"update log_online set `time` = '", Time/binary, "' where uid = ",
                                (integer_to_binary(Uid))/binary, " and `times` = '", (integer_to_binary(Item#?tab_last_name.times))/binary, "';">>;
                        true ->
                            <<>>
                    end
                end,
            lists:map(Fun, Record#log_online.items)
    end.


day_refresh(Uid) ->
    Record = log_online_auto_sql:lookup(Uid),
    Now = erl_time:now(),
    LoginTimes = ?get(?login_times),
    ZeroTimes = erl_time:zero_times() - 86400,
    NewItem =
        case lists:keyfind(ZeroTimes, #?tab_last_name.times, Record#log_online.items) of
            false -> #?tab_last_name{times = ZeroTimes, time = Now - LoginTimes, op = ?OP_ADD};
            Item ->
                NewTime = Now - LoginTimes + Item#?tab_last_name.time,
                if
                    Item#?tab_last_name.op =:= ?OP_ADD -> Item#?tab_last_name{time = NewTime, op = ?OP_ADD};
                    true -> Item#?tab_last_name{time = NewTime, op = ?OP_UPDATE}
                end
        end,
    NewItem2 = #?tab_last_name{times = ZeroTimes + 86400, time = 0, op = ?OP_ADD},
    ?put(?login_times, Now),
    log_online_auto_sql:insert(Record#log_online{items = [NewItem, NewItem2]}).


get_times(Uid) ->
    Record = log_online_auto_sql:lookup(Uid),
    Now = erl_time:now(),
    LoginTimes = ?get(?login_times),
    ZeroTimes = erl_time:zero_times(),
    case lists:keyfind(ZeroTimes, #?tab_last_name.times, Record#log_online.items) of
        false -> Now - LoginTimes;
        Item -> Now - LoginTimes + Item#?tab_last_name.time
    end.
