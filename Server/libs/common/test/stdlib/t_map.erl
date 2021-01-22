%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 六月 2016 上午10:23
%%%-------------------------------------------------------------------
-module(t_map).

-compile(export_all).

test() ->
    Map = #{"a" => <<"binary">>},
    Map1 = maps:put("a", 1, Map),
    Map2 = maps:put("b", "string", Map1),
    io:format("Map1:~p~nMap2:~p~~n~n", [Map1, Map2]),

    Map3 = maps:update("a", "astring", Map2),
    Map4 = try maps:update("c", "no key", Map3) catch _C:_W -> {_C, _W} end,
    io:format("update exit_key:~p~n       no_exit_key:~p~n~n", [Map3, Map4]),

    Ret1 = maps:get("a", Map3),
    Ret2 = try maps:get("c", Map3) catch _C2:_W2 -> {_C2, _W2} end,
    io:format("get exit_key:~p~n    no_exit_key:~p~n~n", [Ret1, Ret2]),

    Find1 = maps:find("b", Map3),
    Find2 = maps:find("c", Map3),
    io:format("find exit_key:~p~n     no_exit_key:~p~n~n", [Find1, Find2]),

    Remove1 = maps:remove("b", Map3),
    Remove2 = maps:remove("c", Map3),
    io:format("remove exit_key:~p~n       no_exit_key:~p~n~n", [Remove1, Remove2]),

    IsKey1 = maps:is_key("a", Map3),
    IsKey2 = maps:is_key("c", Map3),
    io:format("is_key exit_key:~p~n       no_exit_key:~p~n~n", [IsKey1, IsKey2]),

    maps:size(Map3),

    FunMap = fun(K, V1) when is_list(K) -> V1 * 2;
                (_K, V1) -> V1
             end,
    NewMap = #{k1 => 1, "k2" => 2, <<"k3">> => 3},
    maps:map(FunMap, NewMap),

    FunFoldl = fun(K, V, AccIn) when is_list(K) -> AccIn + V;
                  (_K,_V,AccIn) -> AccIn
               end,
    FoldMap = #{k1 => 1, "k2" => 2, <<"k3">> => 3},
    maps:fold(FunFoldl, 0, FoldMap),

    ok.


new() ->
    maps:new().
%%       #{}

get(Key, Map) ->
    Key = 1337,
    Map = #{42 => value_two, 1337 => "value one", "a" => 1},
    maps:get(Key, Map).

find(Key, Map) ->
    Map = #{"hi" => 42},
    Key = "hi",
    maps:find(Key, Map).

put() ->
    Map = #{"a" => 1},
    %%#{"a" => 1}
    Map1 = maps:put("a", 42, Map),
    %%#{"a" => 42}
    maps:put("b", 1337, Map1).
%%#{"a" => 1, "b" => 1337}


is_key() ->
    Map = #{"42" => value},
%%          #{"42" > => value}
    maps:is_key("42", Map).
%%          true


keys() ->
    Map = #{42 => value_three, 1337 => "value two", "a" => 1},
    maps:keys(Map).
%%[42, 1337, "a"]


fold() ->
    Fun = fun(K, V, AccIn) when is_list(K) -> AccIn + V end,
    Map = #{"k1" => 1, "k2" => 2, "k3" => 3},
    maps:fold(Fun, 0, Map).

from_list() ->
    List = [{"a", ignored}, {1337, "value two"}, {42, value_three}, {"a", 1}],
    maps:from_list(List).
%%     #{42 => value_three, 1337 => "value two", "a" => 1}


map() ->
    Fun = fun(K, V1) when is_list(K) -> V1 * 2 end,
    Map = #{"k1" => 1, "k2" => 2, "k3" => 3},
    maps:map(Fun, Map).

%%#{"k1" => 2, "k2" => 4, "k3" => 6}
merge() ->
    Map1 = #{a => "value_one", b => "value_two"},
    Map2 = #{a => 1, c => 2},
    maps:merge(Map1, Map2).
%%#{a => 1, b => "value_two", c => 2}

remove() ->
    Map = #{"a" => 1},
%%#{"a" => 1}
    maps:remove("a", Map).
%%#{}
%%maps:remove("b", Map).
%%#{"a" => 1}

size() ->
    Map = #{42 => value_two, 1337 => "value one", "a" => 1},
    maps:size(Map).

to_list() ->
    Map = #{42 => value_three, 1337 => "value two", "a" => 1},
    maps:to_list(Map).
%%[{42, value_three}, {1337, "value two"}, {"a", 1}]

update() ->
    Map = #{"a" => 1},
%%#{"a" => 1}
    maps:update("a", 42, Map).
%%#{"a" => 42}

values() ->
    Map = #{42 => value_three, 1337 => "value two", "a" => 1},
    maps:values(Map).
%%[value_three, "value two", 1]

without() ->
    Map = #{42 => value_three, 1337 => "value two", "a" => 1},
    Ks = ["a", 42, "other key"],
    maps:without(Ks, Map).
%%#{1337 => "value two"}
