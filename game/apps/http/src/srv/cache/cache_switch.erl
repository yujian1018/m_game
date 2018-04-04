%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2017 上午10:36
%%%-------------------------------------------------------------------
-module(cache_switch).

-behaviour(cache_srv).
-include("http_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").

-export([
    get_v/1,
    select/0,
    refresh/0
]).

-record(cache_switch, {
    channel_id,
    switchs
}).


load_cache() ->
    [
        #cache_mate{
            name = cache_switch,
            key_pos = #cache_switch.channel_id
        }
    ].


get_v(ChannelId) ->
    case ets:lookup(cache_switch, ChannelId) of
        [] ->
            case ets:lookup(cache_switch, -999) of
                [] -> <<"">>;
                [VO] -> VO#cache_switch.switchs
            end;
        [VO] -> VO#cache_switch.switchs
    end.

select() ->
    ?rpc_db_call(db_mysql, ea, [<<"SELECT channel_id, switchs from switch WHERE op_state = 1;">>]).


refresh() ->
    Data = select(),
    FunFoldl =
        fun([ChannelId, Switchs], {RecordsAcc, IdsAcc}) ->
            {
                [#cache_switch{channel_id = ChannelId, switchs = Switchs} | RecordsAcc],
                [ChannelId | IdsAcc]
            }
        end,
    {AllRecords, AllIds} = lists:foldl(FunFoldl, {[], []}, Data),
    cache_srv:reset_record(cache_switch, AllRecords, AllIds).