%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 03. 七月 2017 上午11:14
%%%-------------------------------------------------------------------
-module(sys_handler).

-include("gm_pub.hrl").

-export([
    is_reload_config/1,
    reload_tabs/1
]).

is_reload_config(Tab) ->
    case lists:member(Tab, ?IS_RELOAD_CONFIG) of
        true ->
            reload_tabs(Tab);
        false ->
            ok
    end.

reload_tabs(Tab) ->
    VO = config_tabs:lookup(Tab),
    ObjMod = VO#config_tabs.obj_server,
    FightMod = VO#config_tabs.fight_server,
    
    Update1 =
        if
            ObjMod =/= undefined andalso ObjMod =/= <<>> ->
                [{<<"obj">>, ObjMod, Tab}];
            true ->
                []
        end,
    Update2 =
        if
            FightMod =/= undefined andalso FightMod =/= <<>> ->
                [
                    {<<"normal">>, FightMod, Tab},
                    {<<"arena">>, FightMod, Tab}
                ];
            true ->
                []
        end,
    case global_rpc:rpc_mgr_server(?gm, mgr_server, exec_fun, [Update1 ++ Update2]) of
        {badrpc, nodedown} ->
            ?return_err(?ERR_ARG_ERROR);
        {error, _Err} ->
            ?return_err(?ERR_ARG_ERROR);
        _ ->
            200
    end.