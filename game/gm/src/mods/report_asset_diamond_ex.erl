%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 09. 十一月 2017 下午3:04
%%%-------------------------------------------------------------------
-module(report_asset_diamond_ex).


-include("gm_pub.hrl").

-export([
    select/6
]).


select(_Mod, List, _StartIndex, _SortKey, _SortType, _SqlEx) ->
    lists:map(fun({K, V}) -> report_asset_diamond:to_index(K, V) end, List),
    Times =
        case list_can:get_arg(<<"c_times">>, List) of
            <<"">> -> integer_to_binary(erl_time:zero_times() - 86400);
            TimesBin -> integer_to_binary(erl_time:time2timer(TimesBin))
        end,
    ChannelId =
        case list_can:get_arg(<<"channel_id">>, List) of
            <<"">> -> <<"-999">>;
            ChannelIdBin -> ChannelIdBin
        end,
    Sql = <<"select asset_id, v, count_roles from report_asset_diamond where c_times >= ", Times/binary, " and c_times < ", Times/binary, " + 86400 and channel_id = ", ChannelId/binary, ";">>,
    Data = erl_mysql:execute(pool_log_1, Sql),
    jiffy:encode({[
        {<<"code">>, 200},
        {<<"ret">>, Data},
        {<<"asset_count_prize">>, lists:sum([Num || [_, Num, _] <- Data, Num > 0])},
        {<<"asset_count_cost">>, lists:sum([Num || [_, Num, _] <- Data, Num < 0])}
    ]}).

