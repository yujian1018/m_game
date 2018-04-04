%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 09. 八月 2017 上午11:16
%%%-------------------------------------------------------------------
-module(rank_mgr).

-behaviour(gen_server).

-include("obj_pub.hrl").

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
    refresh/0
]).

-record(state, {}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    refresh(),
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {ok, #state{}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({timeout, _TimerRef, ?timeout_mi_5}, State) ->
    refresh(),
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

refresh() ->
    Fun =
        fun(RankType) ->
            RankTypeBin = integer_to_binary(RankType),
            AllUids = redis_rank:get(RankTypeBin, 0, 49),
            Ranks = redis_obj_role:set_role_vo(AllUids, RankType),%是否在线获取数据，离线获取数据，写入redis，返回 uid,icon,nick,Score
            redis_set:set(RankTypeBin, Ranks)
        end,
    lists:map(Fun, rank_def:all_type_b()).