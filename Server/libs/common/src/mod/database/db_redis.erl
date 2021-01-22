%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 16. 五月 2016 下午5:23
%%%-------------------------------------------------------------------
-module(db_redis).

-include("erl_pub.hrl").


-export([q/1, q/2, qp/1, qp/2]).


q(Command) ->
    eredis_pool:q(?pool_redis_1, Command).


q(Command, Timeout) ->
    eredis_pool:q(?pool_redis_1, Command, Timeout).


qp(Pipeline) ->
    eredis_pool:qp(?pool_redis_1, Pipeline).


qp(Pipeline, Timeout) ->
    eredis_pool:qp(?pool_redis_1, Pipeline, Timeout).