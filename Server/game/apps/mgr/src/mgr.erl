%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 五月 2017 下午8:00
%%%-------------------------------------------------------------------
-module(mgr).

-include("mgr_pub.hrl").

-export([
    all_addrs/0,
    
    get_addr/2,
    
    exec_fun/4

]).

all_addrs() ->
    cache_server_version:addrs().


get_addr(SType, Version) ->
    cache_server_version:addrs(SType, Version).


exec_fun(?obj, Mod, Fun, Data) -> nodes_exec_fun(Mod, Fun, Data, <<"obj">>);
exec_fun(?http, Mod, Fun, Data) -> nodes_exec_fun(Mod, Fun, Data, <<"http">>);
exec_fun(?fight, Mod, Fun, Data) -> nodes_exec_fun(Mod, Fun, Data, <<"fight">>).


nodes_exec_fun(Mod, Fun, Data, Key) ->
    Fun = fun(Node) ->
        case binary:split(erlang:atom_to_binary(Node, unicode), Key) of
            [_] -> ok;
            _ -> rpc:call(Node, Mod, Fun, Data)
        end
          end,
    lists:foreach(Fun, nodes()).