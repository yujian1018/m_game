%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 七月 2016 下午5:19
%%%-------------------------------------------------------------------
-module(log_login_srv).

-include("http_pub.hrl").

-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([add/2]).

-record(log, {log = [], count = 0}).

add(Uidi, Num) ->
    ?MODULE ! {Uidi, Num}.

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    process_flag(trap_exit, true),
    
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {ok, #log{}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, ?timeout_mi_5}, State) ->
    save_data(State#log.log),
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {noreply, State#log{log = [], count = 0}};


handle_info({Udid, Num}, State) ->
    Count = State#log.count,
    Data = State#log.log,
    NewState =
        case lists:keytake(Udid, 1, Data) of
            false ->
                State#log{count = Count + 1, log = [{Udid, [{Num, erl_time:now()}]} | Data]};
            {value, {Udid, List}, V} ->
                case lists:keyfind(Num, 1, List) of
                    false ->
                        State#log{count = Count, log = [{Udid, [{Num, erl_time:now()} | List]} | V]};
                    _ ->
                        State
                end
        end,
    NewState2 =
        if
            NewState#log.count =:= 200 ->
                save_data(State#log.log),
                State#log{log = [], count = 1};
            true ->
                NewState
        end,
    {noreply, NewState2}.


terminate(_Reason, State) ->
    save_data(State#log.log).


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


save_data(Data) ->
    if
        Data =:= [] -> ok;
        true ->
            Sql = lists:foldl(
                fun({Uidi, List}, Acc) ->
                    {NewInsertK, NewInsertV, NewUpdate} = log_login_insert(List, <<>>, <<>>, <<>>),
                    if
                        Acc =:= <<>> ->
                            <<"insert into log_login_log (udid, ",
                                NewInsertK/binary, ") values ('", Uidi/binary, "', ",
                                NewInsertV/binary, ") ON DUPLICATE KEY UPDATE ",
                                NewUpdate/binary, ";">>;
                        true ->
                            <<Acc/binary, "insert into log_login_log (udid, ",
                                NewInsertK/binary, ") values ('", Uidi/binary, "', ",
                                NewInsertV/binary, ") ON DUPLICATE KEY UPDATE ",
                                NewUpdate/binary, ";">> end
                end, <<>>, Data),
            ?rpc_db_call(db_mysql, call_el, [Sql])
    
    end.


log_login_insert([], InsertK, InsertV, UpdateV) -> {InsertK, InsertV, UpdateV};
log_login_insert([{K, V} | R], InsertK, InsertV, UpdateV) ->
    NewV = integer_to_binary(V),
    {NewInsertK, NewInsertV, NewUpdateV} =
        if
            InsertK =:= <<>> ->
                {
                    <<"t", K/binary, "_times">>,
                    NewV,
                    <<"t", K/binary, "_times = ", NewV/binary>>
                };
            true ->
                {
                    <<InsertK/binary, ", t", K/binary, "_times">>,
                    <<InsertV/binary, ", '", NewV/binary, "'">>,
                    <<UpdateV/binary, ", t", K/binary, "_times = ", NewV/binary>>
                }
        end,
    log_login_insert(R, NewInsertK, NewInsertV, NewUpdateV).
