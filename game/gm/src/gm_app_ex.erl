%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 05. 六月 2017 下午7:52
%%%-------------------------------------------------------------------
-module(gm_app_ex).

-export([init/0]).

init() ->
    eredis_pool:start(),
    ok.