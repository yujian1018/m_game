%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 01. 八月 2016 上午9:32
%%%-------------------------------------------------------------------
-module(cache_mail_mng).

-behaviour(cache_srv).
-include_lib("cache/include/cache_mate.hrl").
-include("logic_pub.hrl").

-export([
    refresh/0
]).

-export([all_ids/0, select/0]).


-define(ETS_TAB, cache_mail_mng).

-record(cache_mail_mng, {
    id,
    channel_id = -999,
    e_times,
    expires,
    mail_id,
    limit
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
        fun([Id, ChannelId, DTimes, ETime, MailId, Limit], {Ids, ItemAcc}) ->
            {[Id | Ids], [#cache_mail_mng{
                id = Id,
                channel_id = ChannelId,
                e_times = DTimes,
                expires = ETime,
                mail_id = MailId,
                limit = Limit} | ItemAcc]}
        end,
    {AllIds, InsertRecords} = lists:foldl(FunFoldl, {[], []}, Data),
    cache_srv:reset_record(?ETS_TAB, InsertRecords, AllIds).


select() ->
    Now = integer_to_binary(erl_time:now()),
    ?rpc_db_call(db_mysql, es, [<<"SELECT id, channel_id, e_times, expires, mail_id, `limit` FROM global_mail_mng WHERE a_times <= ", Now/binary, " AND (e_times = 0 OR e_times >= ", Now/binary, " AND op_state = 1 );">>]).


all_ids() ->
    case ets:lookup(?ETS_TAB, all_ids) of
        [] ->
            [];
        [{_, _, IdList1}] ->
            Now = erl_time:now(),
            FunFoldl =
                fun(Id, Acc) ->
                    case ets:lookup(?ETS_TAB, Id) of
                        [] -> Acc;
                        [MailObj] ->
                            if
                                MailObj#cache_mail_mng.e_times =< Now -> Acc;
                                true ->
                                    [{
                                        MailObj#cache_mail_mng.id,
                                        MailObj#cache_mail_mng.channel_id,
                                        MailObj#cache_mail_mng.expires,
                                        MailObj#cache_mail_mng.mail_id,
                                        MailObj#cache_mail_mng.limit} | Acc]
                            end
                    end
                end,
            lists:foldl(FunFoldl, [], IdList1)
    end.
