%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 22. 九月 2017 下午2:18
%%%-------------------------------------------------------------------
-module(attr_ex).

-include("gm_pub.hrl").

-export([
    select/6,
    update/2
]).


select(Mod, List, StartIndex, SortKey, SortType, SqlEx) ->
    IsOnline =
        case list_can:get_arg(<<"uid">>, List) of
            <<"">> -> false;
            UidBin ->
                case redis_online:is_online(UidBin) of
                    {ok, Node, _PidBin} ->
                        rpc:call(Node, load_attr, get_v_gm, [binary_to_integer(UidBin), _PidBin]);
                    _ -> false
                end
        end,
    if
        IsOnline =:= false ->
            tab_mod:default_select_list(Mod, List, StartIndex, SortKey, SortType, SqlEx);
        true ->
            [UID, ChannelId, IS_AI, NAME, SEX, ICON, GOLD, BANK_POLL, DIAMOND, LV, EXP, _ROOM_PID, ADDRESS, INFULLMOUNT, SNG_SCORE, SIGN, REFRESH_TIMES, OFFLINE_TIMES, GMT_OFFSET, CLIENT_SETTING, ACTIVE_POINT, ACTIVE_REWARDS, VIP_LV, VIP_EXP] = IsOnline,
            {1, [{[{<<"uid">>, UID}, {<<"channel_id">>, ChannelId}, {<<"is_ai">>, IS_AI}, {<<"name">>, NAME}, {<<"sex">>, SEX}, {<<"icon">>, ICON}, {<<"gold">>, GOLD}, {<<"diamond">>, DIAMOND}, {<<"lv">>, LV}, {<<"exp">>, EXP}, {<<"address">>, ADDRESS}, {<<"bank_poll">>, BANK_POLL}, {<<"infullmount">>, INFULLMOUNT}, {<<"sng_score">>, SNG_SCORE}, {<<"sign">>, SIGN}, {<<"refresh_times">>, REFRESH_TIMES}, {<<"offline_times">>, OFFLINE_TIMES}, {<<"gmt_offset">>, GMT_OFFSET}, {<<"client_setting">>, CLIENT_SETTING}, {<<"active_point">>, ACTIVE_POINT}, {<<"active_rewards">>, ACTIVE_REWARDS}, {<<"vip_lv">>, VIP_LV}, {<<"vip_exp">>, VIP_EXP}]}]}
    end.


update(_TabName, Args) ->
    UidBin = list_can:exit_v_not_null(<<"uid">>, Args),
    case redis_online:is_online(UidBin) of
        false -> false;
        _ ->
            ?return_err(?ERR_ONLINE, <<"玩家在线"/utf8>>)
    end,
    R2 = [{K, V} || {K, V} <- Args, V =/= <<>>],
    FunFoldl =
        fun({K, V}, Record) ->
            {Index, NewV} = attr:to_index(K, V),
            setelement(Index, Record, NewV)
        end,
    VO = lists:foldl(FunFoldl, attr:record(), R2),
    attr:update(VO).