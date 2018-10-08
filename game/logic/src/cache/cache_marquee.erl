%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 01. 八月 2016 上午9:32
%%%-------------------------------------------------------------------
-module(cache_marquee).

-behaviour(cache_srv).
-include_lib("cache/include/cache_mate.hrl").
-include("obj_pub.hrl").

-export([
    refresh/0
]).

-export([abcast_tick/1, lookup/1, select/0]).



-define(ETS_TAB, cache_marquee).

-record(cache_marquee, {
    id,
    channel_id,
    interval,
    content
}).


load_cache() ->
    [
        #cache_mate{
            name = ?ETS_TAB,
            keypos = #?ETS_TAB.id
        }
    ].


refresh() ->
    Data = select(),
    FunFoldl =
        fun([Id, ChannelId, DiffTime, Content], {Ids, ItemAcc}) ->
            if
                is_integer(DiffTime) andalso DiffTime >= 120 ->
                    {[Id | Ids], [#cache_marquee{id = Id, channel_id = ChannelId, interval = DiffTime, content = Content} | ItemAcc]};
                true ->
                    ?WARN("config diff_time need >= 120s~n"),
                    {Ids, ItemAcc}
            end
        end,
    {AllIds, InsertRecords} = lists:foldl(FunFoldl, {[], []}, Data),
    
    OldIds = cache_srv:reset_record(?ETS_TAB, InsertRecords, AllIds),
    AddIds = erl_list:diff(AllIds, OldIds, []),
    [erlang:start_timer(DiffTime * 1000, self(), {?MODULE, abcast_tick, Id}) || #cache_marquee{id = Id, interval = DiffTime} <- InsertRecords, lists:member(Id, AddIds)].


select() ->
    Now = integer_to_binary(erl_time:now()),
    ?rpc_db_call(db_mysql, es, [<<"SELECT `id`, `channel_id`, `interval`, `content` FROM global_marquee WHERE s_times <= ", Now/binary, " AND e_times > ", Now/binary, " AND op_state = 1;">>]).


abcast_tick(Id) ->
    case ets:lookup(?ETS_TAB, Id) of
        [] -> ok;
        [#cache_marquee{interval = DiffTime}] ->
            player_mgr:abcast(chat_handler, {abcast, Id}),
            erlang:start_timer(DiffTime * 1000, self(), {?MODULE, abcast_tick, Id})
    end.


lookup(Id) ->
    case ets:lookup(?ETS_TAB, Id) of
        [] -> [];
        [Record] ->
            {Record#cache_marquee.channel_id, Record#cache_marquee.content}
    end.