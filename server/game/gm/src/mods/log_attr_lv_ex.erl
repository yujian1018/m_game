%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 16. 十一月 2017 下午12:29
%%%-------------------------------------------------------------------
-module(log_attr_lv_ex).


-include("gm_pub.hrl").

-export([
    select/6
]).


select(_Mod, List, _StartIndex, _SortKey, _SortType, _SqlEx) ->
    CTimes =
        case list_can:get_arg(<<"from_times">>, List) of
            <<"">> -> integer_to_binary(erl_time:zero_times() - 86400);
            TimesBin -> integer_to_binary(erl_time:time2timer(TimesBin))
        end,
    ToTimes =
        case list_can:get_arg(<<"to_times">>, List) of
            <<"">> -> integer_to_binary(erl_time:zero_times() - 86400);
            TimesBin2 -> integer_to_binary(erl_time:time2timer(TimesBin2))
        end,
    Sql =
        case list_can:get_arg(<<"channel_id">>, List, <<"-999">>) of
            <<"-999">> -> <<"SELECT b.lv FROM ",
                (?DYNAMIC_POOL)/binary, ".attr AS a, `log_attr_lv` AS b WHERE a.c_times >=",
                CTimes/binary, " AND a.c_times <", CTimes/binary, "+86400 AND a.uid = b.`uid` AND b.`c_times` >= ",
                ToTimes/binary, " AND b.`c_times` < ", ToTimes/binary, "+86400;">>;
            
            ChannelId -> <<"SELECT b.lv FROM ",
                (?DYNAMIC_POOL)/binary, ".attr AS a, `log_attr_lv` AS b WHERE a.c_times >=",
                CTimes/binary, " AND a.c_times <", CTimes/binary, "+86400 AND a.channel_id = '",
                ChannelId/binary, "' and  a.uid = b.`uid` AND b.`c_times` >= ",
                ToTimes/binary, " AND b.`c_times` < ", ToTimes/binary, "+86400;">>
        end,
    Data = erl_mysql:execute(pool_log_1, Sql),
    {Totle, Data2} = lists:foldl(
        fun([Lv], {Index, Acc}) ->
            case lists:keytake(Lv, 1, Acc) of
                false ->
                    {Index + 1, [{Lv, 1} | Acc]};
                {value, {_, V}, R} ->
                    {Index + 1, [{Lv, V + 1} | R]}
            end
        end, {0, []}, Data),
    {Totle, [{[{<<"from_times">>, CTimes}, {<<"to_times">>, ToTimes}, {<<"channel_id">>, list_can:get_arg(<<"channel_id">>, List)}, {<<"lv">>, Lv}, {<<"count_num">>, Num}]} || {Lv, Num} <- Data2]}.


