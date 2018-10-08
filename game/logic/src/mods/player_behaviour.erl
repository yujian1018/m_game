%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 玩家模块，通用行为规范
%%% 每一个模块都会有的功能：加载数据(当没有数据时，创建数据,创建角色时触发）， 上线初始化信息，下线处理，地图中他人看到的自己的信息
%%%
%%% @end
%%% Created : 24. 六月 2016 下午2:55
%%%-------------------------------------------------------------------

-module(player_behaviour).

-include("logic_pub.hrl").

-export([
    load_data/1,
    online/1,
    online_send_data/1,
    terminate/1,
    save_data/1,
    handler_call/2
]).

%% 事件
-export([
    event_lvup/1,
    event_lvup_vip/1,
    event_zero_refresh/1,
    event_create_role/1
]).


%% @doc 加载数据(当没有数据时，创建数据,创建角色时触发）
-callback load_data(Uid :: integer()) -> {Sql :: binary(), Fun :: fun()} | {<<>>, ?undefined} | {list(), list()}.


%% @doc 上线初始化信息
-callback online(Uid :: integer()) -> State :: #{}.


%% @doc 发送信息给客户端,考虑玩家需要迁移服务器的情况。不用下发数据给客户端
-callback online_send_data(Uid :: integer()) -> State :: #{}.


%% @doc 数据持久化
-callback save_data(Uid :: integer()) -> Sql :: binary() | <<>> | list().


%% @doc 下线处理
-callback terminate(Uid :: integer()) -> ok.
%%
%%%% @doc 地图中他人看到的自己的信息,各个模块可能都会有信息
%%%% 举例：别人能看到自己的：角色、装备、工会、称号信息。
%%-callback view_data(Term :: binary()) -> Term :: binary().


%% @doc 其他进程发送到该模块的信息
-callback handler_msg(Uid :: integer(), FromPid :: pid(), FromModule :: atom(), Msg :: term()) -> term().
-callback handler_call(Uid :: integer(), Msg :: term()) -> term().

load_data(Uid) ->
    {SqlAll, FunAll} = lists:foldl(
        fun(Mod, {SqlAcc, FunAcc}) ->
            case Mod:load_data(Uid) of
                {<<>>, _} -> {SqlAcc, FunAcc};
                {Sql, Fun} when is_list(Sql) -> {Sql ++ SqlAcc, Fun ++ FunAcc};
                {Sql, Fun} -> {[Sql | SqlAcc], [Fun | FunAcc]}
            end
        end,
        {[], []},
        ?ALL_PLAYER_MODS),
    SqlRet = ?rpc_db_call(db_mysql, ed, [iolist_to_binary(lists:reverse(SqlAll))]),
    lists:foldl(fun(Fun, SqlRetAcc) -> Fun(SqlRetAcc) end, SqlRet, lists:reverse(FunAll)).


online(Uid) ->
    lists:map(fun(Mod) -> Mod:online(Uid) end, ?ALL_PLAYER_MODS).


online_send_data(Uid) ->
    lists:map(fun(Mod) -> Mod:online_send_data(Uid) end, ?ALL_PLAYER_MODS).


save_data(Uid) ->
    SqlAll = lists:map(
        fun(Mod) ->
            Sql = Mod:save_data(Uid),
            Sql
        end, ?ALL_PLAYER_MODS),
    case ?rpc_db_call(db_mysql, ed, [iolist_to_binary(SqlAll)]) of
        {error, Err} -> ?ERROR("save_data err:~p~n", [[erlang:get(?uid), Err]]);
        _ -> ok
    end.


terminate(Uid) ->
    lists:map(fun(Mod) -> Mod:terminate(Uid) end, ?ALL_PLAYER_MODS).


handler_call(Uid, Msg) ->
    lists:map(fun(Mod) -> Mod:handler_call(Uid, Msg) end, ?ALL_PLAYER_MODS).


event_lvup(Uid) -> handler_call(Uid, ?event_lvup).
event_lvup_vip(Uid) -> handler_call(Uid, ?event_lvup_vip).
event_zero_refresh(Uid) -> handler_call(Uid, ?event_zero_refresh).
event_create_role(Uid) -> handler_call(Uid, ?event_create_role).

