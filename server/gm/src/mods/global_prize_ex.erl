%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 邮件奖励配置
%%%
%%% Created : 01. 十二月 2017 下午2:46
%%%-------------------------------------------------------------------
-module(global_prize_ex).

-include("gm_pub.hrl").

-export([
    select/6
]).


select(_Mod, List, StartIndex, _SortKey, _SortType, _SqlEx) ->
    Sql =
        case list_can:get_arg(<<"prize_id">>, List) of
            <<"">> ->
                <<"select count(*) from global_prize where prize_id >= 100701001 and prize_id < 100799999; select `prize_id`, `prize`, `comment` from global_prize where prize_id >= 100701001  and prize_id < 100799999 limit ", (integer_to_binary(StartIndex))/binary, ", 60;">>;
            PrizeId ->
                <<"select 1; select `prize_id`, `prize`, `comment` from global_prize where prize_id == ", PrizeId/binary, " limit ", (integer_to_binary(StartIndex))/binary, ", 60;">>
        end,
    global_prize:select(Sql).