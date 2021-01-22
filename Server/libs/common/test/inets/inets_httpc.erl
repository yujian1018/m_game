-module(inets_httpc).

-compile(export_all).

-define(URL, "http://61.152.156.126:8019/search").
-define(URL_POST, <<"{\"aya\":\"66666666\",\"keyword\":\"范冰冰\",\"offset\":\"-1\",\"direction\":\"1\",\"reqlen\":\"10\"}"/utf8>>).
%%% 1000 1 -> 36s 37.675120s
%%% 1 1000 -> 36.056780s 36.120233s


%%-define(URL, "http://61.152.156.126:8019/matchword").
%%-define(URL_POST, <<"{\"aya\":\"66666666\",\"keyword\":\"汽车\"}"/utf8>>).
%%% 1000 1 -> 4.2s 4.248491s 4.274607s
%%% 1 1000 -> 5.058608s 5.100056s 6.066191s


%%test() ->
%%    inets:start(),
%%    T1 = erlang:timestamp(),
%%    test(0),
%%    DiffTime = timer:now_diff(erlang:timestamp(), T1),
%%    io:format("cost ms_time:~p~n", [DiffTime]).
%%
%%test(1000) -> ok;
%%test(N) ->
%%    httpc:request(post, {?URL, [], [], ?URL_POST}, [{timeout, 5000}], []),
%%    test(N+1).


test(Url, Count, Process, Args) ->
    inets:start(),
    T1 = erlang:timestamp(),
    Fun = fun(_I) ->
        httpc:request(post, {Url, [], [], Args}, [{timeout, 5000}], [])
          end,
    lists_spawn({0, Count}, Process, Fun),
    DiffTime = timer:now_diff(erlang:timestamp(), T1),
%%    io:format("cost ms_time:~p~n", [DiffTime]),
    DiffTime.


test() ->
    inets:start(),
    T1 = erlang:timestamp(),
    Fun = fun(_I) ->
%%        R = httpc:request(post, {?URL, [], [], ?URL_POST}, [{timeout, 5000}], []),
%%        io:format( "111:~p~n", [R] )
        httpc:request(post, {?URL, [], [], ?URL_POST}, [{timeout, 5000}], [])
          end,
    lists_spawn({0, 1}, 1000, Fun),
    DiffTime = timer:now_diff(erlang:timestamp(), T1),
    io:format("cost ms_time:~p~n", [DiffTime]).

lists_spawn({_MaxNum, _MaxNum}, _SpawnNum, _Fun) -> ok;

lists_spawn({Num, MaxNum}, SpawnNum, Fun) ->
    Ref = erlang:make_ref(),
    Pid = self(),

    [
        receive
            {Ref, Res} -> Res;
            _ -> ok
        end || _ <-
        [spawn(
            fun() ->
                Res = Fun(I),
                Pid ! {Ref, Res}
            end) || I <- lists:seq(1, SpawnNum)]
    ],
    lists_spawn({Num + 1, MaxNum}, SpawnNum, Fun).