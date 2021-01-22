%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 13. 九月 2018 下午5:37
%%%-------------------------------------------------------------------
-module(algo).

-compile(no_native).

-on_load(init/0).

-export([
    edit_distance/2
]).


init() ->
    Path = case code:lib_dir(common, priv) of
               {error, _} -> "./priv/algo";
               Str -> Str ++ "/algo"
           end,
    erlang:load_nif(Path, 0).



%%algo:edit_distance(<<"dakaichangweiyisheng">>,<<"feichangshourenaidae">>).

-spec edit_distance(binary(), binary()) -> integer().

edit_distance(_Src, _Dest) when is_binary(_Src) andalso is_binary(_Dest) andalso _Src =/= <<>> andalso _Dest =/= <<>> ->
    erlang:nif_error(nif_not_loaded);

edit_distance(_Src, _Dest) -> 100.


%%%===================================================================
%%% Unit tests
%%%===================================================================

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-ifdef(TEST).
load_nif_test() ->
    ?assertEqual(ok, load_nif(filename:join(["..", "priv", "lib"]))).

dis_1_test() ->
    ?assertEqual(
        5,
        algo:edit_distance(<<"utf-8">>, <<"koi8-r">>)).
-endif.
