%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 21. 十月 2016 下午3:00
%%%-------------------------------------------------------------------
-module(prof_code).

-export([
    decompile/1,
    profil/0
]).

decompile(Mod) ->
    {ok, {_, [{abstract_code, {_, AC}}]}} = beam_lib:chunks(code:which(Mod), [abstract_code]),
    io:format("~s~n", [erl_prettypr:format(erl_syntax:form_list(AC))]).


profil() ->
    cprof:start(),
    cprof:pause(),
    
    timer:sleep(30000),
    
    io:format("~p~n", [cprof:analyse(map_server)]),
    cprof:stop().
