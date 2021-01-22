%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 29. 十二月 2018 上午10:50
%%%-------------------------------------------------------------------
-module(std).


-compile(no_native).

-on_load(init/0).

-export([
    t/1
]).

init() ->
    Path = case code:lib_dir(common, priv) of
               {error, _} -> "./priv/std";
               Str -> Str ++ "/std"
           end,
    erlang:load_nif(Path, 0).


%% @doc 插入新词
t(_Bin) ->
    erlang:error({"NIF ERROR in std at line", ?LINE}).
