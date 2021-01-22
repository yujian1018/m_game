%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 13. 七月 2018 下午3:54
%%%-------------------------------------------------------------------
-module(erl_maps).

-export([
    find/2,         % 多层嵌套
    keytake/3,      % lists:keyfind
    keymembers/3    % lists:keymembers
]).

find([], V) -> V;
find([H | R], Maps) ->
    K =
        if
            is_binary(H) -> binary_to_atom(H, 'utf8');
            true -> H
        end,
    case maps:find(K, Maps) of
        {ok, V} -> find(R, V);
        _ -> <<>>
    end.


keytake(_Val, _Key, []) -> false;
keytake(Val, Key, Maps) -> keytake(Val, Key, Maps, []).

keytake(_Val, _Key, [], _Acc) -> false;
keytake(Val, Key, [Map | Maps], Acc) ->
    case maps:find(Key, Map) of
        {ok, Val} -> {value, Map, Acc ++ Maps};
        _ -> keytake(Val, Key, Maps, [Map | Acc])
    end.


keymembers(_Val, _Key, []) -> false;
keymembers(Val, Key, [Map | Maps]) ->
    case maps:find(Key, Map) of
        {ok, Val} -> true;
        _ -> keymembers(Val, Key, Maps)
    end.