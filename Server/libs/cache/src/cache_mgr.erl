%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 设计错误，小数据量可以接受，目前没有好想法
%%% Created : 08. 十二月 2015 上午11:26
%%%-------------------------------------------------------------------
-module(cache_mgr).

-behaviour(gen_server).

-define(no_cache_behaviour, 1).
-include("cache_pub.hrl").

-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% state = #{cache_mate => #cache_mate{}}.


start_link(CacheConfig) ->
    gen_server:start_link({local, CacheConfig#cache_mate.name}, ?MODULE, CacheConfig, []).


init(CacheConfig) ->
    cache_behaviour:init(CacheConfig),
    cache_behaviour:load_file(CacheConfig),
    ?INFO("config table:~p load done", [CacheConfig#cache_mate.name]),
    {ok, #{config => CacheConfig}}.


handle_call({reset_md5, TabName, Md5}, _From, State) ->
    TabNameBin = list_to_binary(atom_to_list(TabName)),
    Reply =
        case ets:lookup(?cache_tab_md5, all_config) of
            [] ->
                ets:insert(?cache_tab_md5, {all_config, <<"{\"", TabNameBin/binary, "\":\"", Md5/binary, "\"}">>});
            [{all_config, Json}] ->
                {Obj} = jiffy:decode(Json),
                NewObj = lists:keystore(TabNameBin, 1, Obj, {TabNameBin, Md5}),
                NewJson = jiffy:encode({NewObj}),
                ets:insert(?cache_tab_md5, {all_config, NewJson})
        end,
    {reply, Reply, State};

handle_call({reset_cache, ConfigVO}, _From, State) ->
    Reply = case catch cache_behaviour:load_file(ConfigVO) of
                {'EXIT', Catch} ->
                    ?ERROR("reset_cache load_file err:~p~n", [Catch]),
                    {error, Catch};
                _ ->
                    ok
            end,
    {reply, Reply, State};

handle_call(_Request, _From, State) -> {reply, ok, State}.


handle_cast(_Request, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, State) -> State.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
