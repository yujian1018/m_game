%%%
%%% @doc 玩家在线表
%%% Created : 15. 十二月 2015 下午2:45
%%%-------------------------------------------------------------------

-module(player_mgr).

-behaviour(gen_server).

-include("erl_pub.hrl").

-export([
    get/1,
    add/2,
    del/2,
    total_player/0,
    abcast/2,
    get_uids/0
]).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(ETS_MGR_PLAYER, ets_mgr_player).
-define(ALL_PLAYER_PID, all_player_pid).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


%% 添加一个玩家
add(Pid, Uid) ->
    Set2 = case ets:lookup(?ETS_MGR_PLAYER, ?ALL_PLAYER_PID) of
               [] ->
                   sets:add_element(Pid, sets:new());
               [{?ALL_PLAYER_PID, S1}] ->
                   sets:add_element(Pid, S1)
           end,
    true = ets:insert(?ETS_MGR_PLAYER, {Pid, Uid}),
    true = ets:insert(?ETS_MGR_PLAYER, {Uid, Pid}),
    ets:insert(?ETS_MGR_PLAYER, {?ALL_PLAYER_PID, Set2}),
    redis_online:set(Uid, Pid, node()).

%% 删除一个玩家
del(Pid, Uid) ->
    case ets:member(?ETS_MGR_PLAYER, Uid) of
        true ->
            NewSets = case ets:lookup(?ETS_MGR_PLAYER, ?ALL_PLAYER_PID) of
                          [] -> sets:new();
                          [{?ALL_PLAYER_PID, Sets}] ->
                              sets:del_element(Pid, Sets)
                      end,
            ets:insert(?ETS_MGR_PLAYER, {?ALL_PLAYER_PID, NewSets}),
            ets:delete(?ETS_MGR_PLAYER, Uid),
            ets:delete(?ETS_MGR_PLAYER, Pid);
        false ->
            ok
    end,
%%    ?DEBUG("del uid:~p~n", [[Pid, PlayerId, self()]]),
    redis_online:del(Uid).


%% 获得当前玩家总数
total_player() ->
    case ets:info(?ETS_MGR_PLAYER, size) of
        0 -> 0;
        Size -> round((Size - 1) / 2)
    end.


%% 本台服务器上的玩家
abcast(Mod, Arg) ->
    ?MODULE ! {abcast, Mod, Arg}.


get_uids() ->
    case ets:select(?ETS_MGR_PLAYER, [{{'$1', '$2'}, [{is_integer, '$1'}], ['$1']}], 100) of
        '$end_of_table' -> [];
        {Ids, _} ->
            Len = length(Ids),
            R1 = erl_random:random(Len),
            R2 = erl_random:random(Len),
            R3 = erl_random:random(Len),
            R4 = erl_random:random(Len),
            R5 = erl_random:random(Len),
            [lists:nth(I, Ids) || I <- lists:usort([R1, R2, R3, R4, R5])]
    end.

get(Uid) ->
    case ets:lookup(?ETS_MGR_PLAYER, Uid) of
        [] -> false;
        [{Uid, Pid}] -> Pid
    end.


init([]) ->
    ?ets_new(?ETS_MGR_PLAYER, 1),
    ?INFO("~p init done~n", [?MODULE]),
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {ok, #{}}.


handle_call(_Msg, _From, State) ->
    {reply, ok, State}.


handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({abcast, Mod, Arg}, State) ->
    case ets:lookup(?ETS_MGR_PLAYER, ?ALL_PLAYER_PID) of
        [] -> ok;
        [{?ALL_PLAYER_PID, Sets}] ->
            sets:fold(
                fun(Pid, Acc) ->
                    case is_process_alive(Pid) of
                        true ->
                            Pid ! ?mod_msg(Mod, Arg);
                        false ->
                            ok
                    end,
                    Acc
                end,
                [],
                Sets)
    end,
    {noreply, State};

handle_info({timeout, _TimerRef, ?timeout_mi_5}, State) ->
%%    {ok, ServerId} = application:get_env(?obj, server_id),
%%    catch log_pub:s_count(total_player(), ServerId),
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {noreply, State};

handle_info(_Error, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    case ets:lookup(?ETS_MGR_PLAYER, ?ALL_PLAYER_PID) of
        [] -> ok;
        [{?ALL_PLAYER_PID, Sets}] ->
            sets:fold(
                fun(Pid, Acc) ->
                    case is_process_alive(Pid) of
                        true ->
                            ?send_to_client(Pid, {stop, ?ERR_MAINTAIN_SYSTEM});
                        false ->
                            ok
                    end,
                    Acc
                end,
                [],
                Sets)
    end,
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
