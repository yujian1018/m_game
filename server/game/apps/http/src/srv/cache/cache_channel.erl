%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2017 上午10:39
%%%-------------------------------------------------------------------
-module(cache_channel).

-behaviour(cache_srv).
-include("http_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").

-export([
    get_mod/1,
    select/0,
    refresh/0
]).

-record(cache_channel, {
    channel_id,
    call_mod
}).


load_cache() ->
    [
        #cache_mate{
            name = cache_channel,
            key_pos = #cache_channel.channel_id
        }
    ].


get_mod(ChannelId) ->
    case ets:lookup(cache_channel, ChannelId) of
        [] ->
            case ets:lookup(cache_channel, -999) of
                [] ->
                    ?ERROR("no channel_mod:~p~n", [ChannelId]),
                    ?return_err(?ERR_ARG_ERROR, <<"不存在channel_id"/utf8>>);
                [VO] -> VO#cache_channel.call_mod
            end;
        [VO] -> VO#cache_channel.call_mod
    end.


select() ->
    ?rpc_db_call(db_mysql, ea, [<<"SELECT channel_id, call_mod from channel;">>]).


refresh() ->
    Data = select(),
    FunFoldl =
        fun([ChannelId, CallMod], {RecordsAcc, IdsAcc}) ->
            CallModAtom = binary_to_atom(CallMod, 'utf8'),
            {
                [#cache_channel{channel_id = ChannelId, call_mod = CallModAtom} | RecordsAcc],
                [ChannelId | IdsAcc]
            }
        end,
    {AllRecords, AllIds} = lists:foldl(FunFoldl, {[], []}, Data),
    cache_srv:reset_record(cache_channel, AllRecords, AllIds).