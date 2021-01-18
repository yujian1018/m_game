%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 27. 十一月 2017 下午3:55
%%%-------------------------------------------------------------------
-module(card_ex).


-include("gm_pub.hrl").

-export([
    select/6
]).


select(_Mod, List, StartIndex, _SortKey, _SortType, _SqlEx) ->
    Sql =
        case list_can:get_arg(<<"uid">>, List) of
            <<"">> ->
                case list_can:get_arg(<<"channel_id">>, List, <<"-999">>) of
                    <<"-999">> ->
                        <<"select count(*) from card;select (a.uid in(select uid from dz_account.white_list)), b.channel_id, b.uid, b.vip_lv, a.card_type, a.deadline_times from card as a, attr as b where a.uid = b.uid limit ",
                            (integer_to_binary(StartIndex))/binary, ", 60; ;">>;
                    ChannelId ->
                        <<"select count(*) from card as a, attr as b where a.uid = b,uid and b.channel_id = ",
                            ChannelId/binary, ";select (a.uid in(select uid from dz_account.white_list)), b.channel_id, b.uid, b.vip_lv, a.card_type, a.deadline_times from card as a, attr as b where a.uid = b.uid and b.channel_id = ",
                            ChannelId/binary, " limit ", (integer_to_binary(StartIndex))/binary, ", 60; ;">>
                end;
            UidBin ->
                <<"select 1; select (a.uid in(select uid from dz_account.white_list)), b.channel_id, b.uid, b.vip_lv, a.card_type, a.deadline_times from card as a, attr as b where a.uid = ", UidBin/binary, " and a.uid = b.uid;">>
        end,
    [[[Count]], Ret] = erl_mysql:execute(pool_dynamic_1, Sql),
    
    {Count, lists:map(
        fun([IsWhiteList, CHANNEL_ID, UID, VIP_LV, CARD_TYPE, DEADLINE_TIMES]) ->
            {[{<<"is_whitelist">>, IsWhiteList}, {<<"channel_id">>, CHANNEL_ID}, {<<"uid">>, UID}, {<<"vip_lv">>, VIP_LV}, {<<"card_type">>, CARD_TYPE}, {<<"deadline_times">>, DEADLINE_TIMES}]}
        end, Ret)}.