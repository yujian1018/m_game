%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 03. 十一月 2017 下午2:03
%%%-------------------------------------------------------------------
-module(recharge_rank_ex).


-include("gm_pub.hrl").

-export([
    select/6
]).


select(_Mod, List, _StartIndex, _SortKey, _SortType, _SqlEx) ->
    STimes =
        case list_can:get_arg(<<"s_times">>, List) of
            <<>> -> integer_to_binary(erl_time:zero_times() - 86400);
            STimesBin -> integer_to_binary(erl_time:time2timer(STimesBin))
        end,
    ETimes =
        case list_can:get_arg(<<"e_times">>, List) of
            <<>> -> integer_to_binary(erl_time:zero_times());
            ETimesBin -> integer_to_binary(erl_time:time2timer(ETimesBin))
        end,
    
    Sql1 =
        case list_can:get_arg(<<"channel_id">>, List, <<"-999">>) of
            <<"-999">> ->
                <<"SELECT channel_id, uid, SUM(rmb), max(s_times) FROM orders WHERE s_times >= ", STimes/binary, " and e_times < ", ETimes/binary, " and state = 2 and uin not in (select uin from white_list) GROUP BY uid, channel_id order by sum(rmb) desc limit 0, 50;">>;
            ChannelId ->
                <<"SELECT channel_id, uid, SUM(rmb), max(s_times) FROM orders WHERE s_times >= ", STimes/binary, " and e_times < ", ETimes/binary, " and state = 2 and channel_id = ", ChannelId/binary, " and uin not in (select uin from white_list) GROUP BY uid order by sum(rmb) desc limit 0, 50;">>
        end,
    Json =
        case erl_mysql:execute(pool_account_1, Sql1) of
            [] ->
                [{<<"code">>, 200}, {<<"max_page">>, 0},
                    {<<"count">>, 0},
                    {<<"ret">>, []}];
            Data ->
                Arg =
                    lists:foldl(
                        fun([_ChannelId, Uid, _AllRmb, STimesInt], ArgBin) ->
                            if
                                ArgBin =:= <<>> ->
                                    <<"(a.uid = ", (integer_to_binary(Uid))/binary, " and a.s_times = ", (integer_to_binary(STimesInt))/binary, " and a.uin = b.uin and b.uid = c.uid)">>;
                                true ->
                                    <<ArgBin/binary, "or (a.uid = ", (integer_to_binary(Uid))/binary, " and a.s_times = ", (integer_to_binary(STimesInt))/binary, " and a.uin = b.uin and b.uid = c.uid)">>
                            end
                        end,
                        <<>>,
                        Data),
                Ret = erl_mysql:execute(pool_dynamic_1, <<"SELECT a.uid, a.currency_type, a.rmb, c.vip_lv, c.c_times FROM dz_account.orders as a, player as b, attr as c WHERE ", Arg/binary, ";">>),
                Ret1 = [list_to_tuple(I) || I <- Ret],
                RetJson = lists:foldl(
                    fun([ChannelId, Uid, AllRmb, STimesInt], Acc) ->
                        {_, CurrencyType, Rmb, VipLv, CTimes} = lists:keyfind(Uid, 1, Ret1),
                        [{[{<<"s_times">>, STimes}, {<<"e_times">>, ETimes}, {<<"c_times">>, CTimes}, {<<"channel_id">>, ChannelId},
                            {<<"uid">>, Uid}, {<<"all_rmb">>, AllRmb}, {<<"last_s_times">>, STimesInt},
                            {<<"currency_type">>, CurrencyType}, {<<"rmb">>, Rmb}, {<<"vip_lv">>, VipLv}]} | Acc]
                    end,
                    [],
                    Data),
                
                [{<<"code">>, 200}, {<<"max_page">>, 1},
                    {<<"count">>, 50},
                    {<<"ret">>, lists:reverse(RetJson)}]
        
        end,
    jiffy:encode({Json}).

