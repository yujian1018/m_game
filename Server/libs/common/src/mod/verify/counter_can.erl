%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 计数器
%%%
%%% Created : 17. 十二月 2016 下午1:15
%%%-------------------------------------------------------------------
-module(counter_can).

-include("erl_pub.hrl").

-export([get/3]).


get(Key, MaxCountNum, MaxDiffTime) ->
    case erlang:get({Key, difftime}) of
        undefined ->
            init_count(Key),
            set_difftime(Key),
            ?true;
        OldTime ->
            Now = erl_time:now(),
            if
                (Now - OldTime) >= MaxDiffTime ->
                    init_count(Key),
                    set_difftime(Key),
                    ?true;
                true ->
                    case erlang:get({Key, counter}) of
                        undefined ->
                            set_count(Key, 1),
                            ?true;
                        Counter ->
                            if
                                MaxCountNum >= Counter ->
                                    set_count(Key, Counter + 1),
                                    ?true;
                                true ->
                                    ?return_err(?ERR_LIMIT_API)
                            end
                    end
            end
    end.

init_count(Key) ->
    erlang:put({Key, counter}, 1).

set_count(Key, Counter) ->
    erlang:put({Key, counter}, Counter + 1).


set_difftime(Key) ->
    erlang:put({Key, difftime}, erl_time:now()).