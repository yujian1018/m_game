%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 17. 十二月 2016 下午1:15
%%%-------------------------------------------------------------------
-module(version_can).

-include("erl_pub.hrl").

-export([get/2, set/1]).

get(Type, Version) ->
    case get(Type) of
        Version -> ?TRUE;
        NewVersion -> NewVersion
    end.

set(Type) ->
    Now = erl_time:now(),
    put(Type, Now),
    Now.