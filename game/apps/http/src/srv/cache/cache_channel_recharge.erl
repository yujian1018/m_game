%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2017 上午10:41
%%%-------------------------------------------------------------------
-module(cache_channel_recharge).

-behaviour(cache_srv).
-include("http_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").

-export([
    get_mod/2,
    select/0,
    refresh/0
]).

-record(cache_channel_recharge, {
    key,    %{channel_id, recharge_id}
    call_mod
}).


load_cache() ->
    [
        #cache_mate{
            name = cache_channel_recharge,
            key_pos = #cache_channel_recharge.key
        }
    ].


get_mod(ChannelId, RechargeId) ->
    case ets:lookup(cache_channel_recharge, {ChannelId, RechargeId}) of
        [] ->
            ?ERROR("no channel_recharge_mod:~p~n", [[ChannelId, RechargeId]]),
            ?return_err(?ERR_ARG_ERROR, <<"不存在{channel_id, RechargeId}"/utf8>>);
        [VO] -> VO#cache_channel_recharge.call_mod
    end.


select() ->
    ?rpc_db_call(db_mysql, ea, [<<"SELECT channel_id, recharge_id, call_mod from channel_recharge;">>]).


refresh() ->
    Data = select(),
    FunFoldl =
        fun([ChannelId, RechargeId, CallMod], {RecordsAcc, IdsAcc}) ->
            CallModAtom = binary_to_atom(CallMod, 'utf8'),
            {
                [#cache_channel_recharge{key = {ChannelId, RechargeId}, call_mod = CallModAtom} | RecordsAcc],
                [{ChannelId, RechargeId} | IdsAcc]
            }
        end,
    {AllRecords, AllIds} = lists:foldl(FunFoldl, {[], []}, Data),
    cache_srv:reset_record(cache_channel_recharge, AllRecords, AllIds).

