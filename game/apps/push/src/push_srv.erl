%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc event:1 表示大转盘推送。当天没领取，并且12点不在线  key:{1,channel_id, {2017,9,23}} v:uins
%%% event:2 表示月卡推送，当天没在线，并且14点 key:{1,channel_id, {2017,9,23}} v:uins
%%% Created : 23. 九月 2017 下午2:55
%%%-------------------------------------------------------------------
-module(push_srv).


-behaviour(gen_server).

-include("push_pub.hrl").

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
    create_uid/2,
    add_uid/2,
    del_uid/2,
    push_data/1
]).

create_uid(Event, Uin) -> ?MODULE ! {create, Event, Uin}.
add_uid(Event, Uin) -> ?MODULE ! {add, Event, Uin}.
del_uid(Event, Uin) -> ?MODULE ! {del, Event, Uin}.
push_data(EventId) -> ?MODULE ! {push_data, EventId}.


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    DiffTime = erl_time:zero_times() + 86400 - erl_time:now(),
    erlang:start_timer(DiffTime * 1000, self(), zero_time),
    {ok, #{all_uids => load_db:all_uids(), card_uids => load_db:card_uids(), online_uids_1 => ordsets:new(), online_uids_2 => ordsets:new()}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, zero_time}, State) ->
    DiffTime = erl_time:zero_times() + 86400 - erl_time:now(),
    erlang:start_timer(DiffTime * 1000, self(), zero_time),
    {noreply, State#{all_uids => load_db:all_uids(), card_uids => load_db:card_uids(), online_uids_1 => ordsets:new(), online_uids_2 => ordsets:new()}};


handle_info({add, Event, Uin}, State) ->
    NewState =
        if
            Event =:= 1 ->
                #{online_uids_1 := Uids1} = State,
                State#{online_uids_1 => ordsets:add_element(Uin, Uids1)};
            Event =:= 2 ->
                #{online_uids_2 := Uids2} = State,
                State#{online_uids_2 => ordsets:add_element(Uin, Uids2)};
            true ->
                State
        end,
    {noreply, NewState};

handle_info({del, Event, Uin}, State) ->
    NewState =
        if
            Event =:= 1 ->
                #{online_uids_1 := Uids1} = State,
                State#{online_uids_1 => ordsets:del_element(Uin, Uids1)};
            Event =:= 2 ->
                #{online_uids_2 := Uids2} = State,
                State#{online_uids_2 => ordsets:del_element(Uin, Uids2)};
            true ->
                State
        end,
    {noreply, NewState};

handle_info({push_data, Event}, State) ->
    push_event(Event, State),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


push_event(1, #{all_uids := SetsAll, online_uids_1 := Sets1}) ->
    Sets = ordsets:subtract(SetsAll, Sets1),
    app_push(Sets, 1, ?PUSH_MSG_2_EN);

push_event(2, #{card_uids := SetsAll, online_uids_2 := Sets1}) ->
    Sets = ordsets:subtract(SetsAll, Sets1),
    app_push(Sets, 2, ?PUSH_MSG_3_EN).


app_push(Sets, Event, Msg) ->
    FunFoldl = fun(Uin, {Index, Acc}) ->
        if
            Index =:= 1000 ->
                app_push:httpc(?encode(Acc), Event, Msg),
                {1, [integer_to_binary(Uin)]};
            true ->
                {Index + 1, [integer_to_binary(Uin) | Acc]}
        end
               end,
    case ordsets:fold(FunFoldl, {0, []}, Sets) of
        {_Index, []} -> ok;
        {_Index, Data} -> app_push:httpc(?encode(Data), Event, Msg)
    end.