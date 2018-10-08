%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 25. 九月 2017 下午12:20
%%%-------------------------------------------------------------------
-module(active_can).

-include("logic_pub.hrl").

-export([
    is_open/1
]).

is_open(ActiveId) ->
    case global_active:exit(ActiveId) of
        ?true -> ok;
        ?false -> ?return_err(?ERR_ACTIVE_NO_ID)
    end.
