%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 27. 六月 2017 下午8:09
%%%-------------------------------------------------------------------
-module(room_mgr).

-include_lib("cache/include/cache_mate.hrl").
-include("im_pub.hrl").


-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
    create/2, logout/1,
    
    add/2, tick/2,
    
    abcast/5
]).

-define(tab_name_1, room_mgr).

-record(room_mgr, {
    chat_id,
    max = 500,
    now_count = 0,
    member = [],
    off_times = 0
}).

load_cache() ->
    [
        #cache_mate{
            name = ?tab_name_1,
            key_pos = #room_mgr.chat_id
        }
    ].




create(Tid, Members) -> gen_server:call(?MODULE, {create, Tid, Members}).


logout(Tid) -> gen_server:call(?MODULE, {logout, Tid}).


add(Tid, Iid) ->
    case player_mgr:get(Iid) of
        false -> ?return_err(?ERR_NOT_ONLINE);
        Pid ->
            ?send_cast_msg(Pid, chat_handler, {add, Tid}),
            gen_server:call(?MODULE, {add, Tid, Iid, Pid})
    end.


tick(Tid, Iid) -> gen_server:call(?MODULE, {tick, Tid, Iid}).


abcast(FromUid, ChatId, MsgType, Msg, Attach) ->
    case ets:lookup(?tab_name_1, ChatId) of
        [Chat] ->
            case lists:member(FromUid, Chat#room_mgr.member) of
                false ->
                    ?return_err(?ERR_NOT_IN_CHAT);
                _ ->
                    Fun =
                        fun(Iid) ->
                            case player_mgr:get(Iid) of
                                false -> false;
                                Pid ->
                                    ?send_to_client(Pid, chat_sproto:encode(?PROTO_CHAT_ABCAST_TO_ROOM, [MsgType, Msg, Attach]))
                            end
                        end,
                    spawn(fun() -> [Fun(Iid) || Iid <- Chat#room_mgr.member] end)
            end;
        _ ->
            ?return_err(?ERR_NO_CHAT)
    end.


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    ?ets_new(?tab_name_1, #room_mgr.chat_id),
    {ok, #{}}.


handle_call({create, Tid, Members}, _From, State) ->
    NewTid =
        if
            Tid == <<>> -> erl_bin:uuid_bin();
            true -> Tid
        end,
    ets:insert(?tab_name_1, #room_mgr{chat_id = NewTid, member = Members}),
    erlang:start_timer(?TIMEOUT_MI_30, self(), {?timeout_mi_30, NewTid}),
    erlang:start_timer(?TIMEOUT_D_1, self(), {?timeout_d_1, NewTid}),
    {reply, Tid, State};

handle_call({add, Tid, Iid, _Pid}, _From, State) ->
    Ret =
        case ets:lookup(?tab_name_1, Tid) of
            [Chat] ->
                NowCount = Chat#room_mgr.now_count,
                if
                    NowCount + 1 =< Chat#room_mgr.max ->
                        case lists:member(Iid, Chat#room_mgr.member) of
                            false ->
                                ets:insert(?tab_name_1, Chat#room_mgr{now_count = NowCount + 1, member = [Iid | Chat#room_mgr.member], off_times = 0});
                            true ->
                                ets:insert(?tab_name_1, Chat#room_mgr{off_times = 0})
                        end;
                    true ->
                        {error, ?ERR_EXCEED_CHAT_NUM}
                end;
            _ ->
                {error, ?ERR_NO_CHAT}
        end,
    {reply, Ret, State};

handle_call({tick, Tid, Iid}, _From, State) ->
    Ret =
        case ets:lookup(?tab_name_1, Tid) of
            [Chat] ->
                Member = lists:delete(Iid, Chat#room_mgr.member),
                case Member of
                    [] ->
                        ets:insert(?tab_name_1, Chat#room_mgr{now_count = Chat#room_mgr.now_count - 1, member = [], off_times = erl_time:now()});
                    Member ->
                        ets:insert(?tab_name_1, Chat#room_mgr{now_count = Chat#room_mgr.now_count - 1, member = Member})
                end;
            _ ->
                {error, ?ERR_NO_CHAT}
        end,
    {reply, Ret, State};

handle_call({logout, ChatId}, _From, State) ->
    Ret =
        case ets:lookup(?tab_name_1, ChatId) of
            [_Chat] ->
                ets:delete(?tab_name_1, ChatId);
            _ ->
                {error, ?ERR_NO_CHAT}
        end,
    {reply, Ret, State};


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({timeout, _TimerRef, {?timeout_mi_30, Tid}}, State) ->
    case ets:lookup(?tab_name_1, Tid) of
        [Chat] ->
            case Chat#room_mgr.member of
                [] -> ets:delete(?tab_name_1, Tid);
                _ -> ok
            end;
        _ -> ok
    end,
    {noreply, State};

handle_info({timeout, _TimerRef, {?timeout_d_1, Tid}}, State) ->
    ets:delete(?tab_name_1, Tid),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
