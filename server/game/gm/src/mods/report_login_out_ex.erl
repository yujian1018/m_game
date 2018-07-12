%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 09. 十一月 2017 下午3:04
%%%-------------------------------------------------------------------
-module(report_login_out_ex).


-include("gm_pub.hrl").

-export([
    select/6
]).


select(_Mod, List, _StartIndex, _SortKey, _SortType, _SqlEx) ->
    lists:map(fun({K, V}) -> report_asset_gold:to_index(K, V) end, List),
    Times =
        case list_can:get_arg(<<"c_times">>, List) of
            <<"">> -> integer_to_binary(erl_time:zero_times() - 86400);
            TimesBin -> integer_to_binary(erl_time:time2timer(TimesBin))
        end,
    Sql = <<"select layer_id, v, count_roles from report_login_out where c_times >= ", Times/binary, " and c_times < ", Times/binary, " + 86400 and channel_id = -999;">>,
    Data = erl_mysql:execute(pool_log_1, Sql),
    
    PrizeRet = [[A, B] || {A, B, _C} <- lists:sublist(lists:reverse(lists:keysort(2, [list_to_tuple(I) || I <- Data])), 3)],
    jiffy:encode({[
        {<<"code">>, 200},
        {<<"ret">>, Data},
        {<<"asset_count_prize">>, lists:sum([Num || [_, Num, _] <- Data, Num > 0])},
        {<<"asset_count_cost">>, PrizeRet}
    ]}).

