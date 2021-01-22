%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 11. 六月 2018 下午3:45
%%%-------------------------------------------------------------------
-module(erl_bin).

-export([
    uuid/0, uuid_bin/0, order_id/0,
    
    sql/1, mysql_encode/1, mysql_decode/1, %转译 mysql关键字' 单引号
    
    term_to_bin/1, bin_to_term/1,
    
    to_lower/1, to_upper/1, join/2
]).


%%| 41 bits: Timestamp | 3 bits: 区域 | 10 bits: 机器编号 | 10 bits: 自增序号 |
uuid() ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    Timers = MegaSecs * 1000000000000 + Secs * 1000000 + MicroSecs,
    erl_hash:md5(term_to_binary({self(), erlang:make_ref(), Timers, node()})).

uuid_bin() ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    Timers = MegaSecs * 1000000000000 + Secs * 1000000 + MicroSecs,
    erl_hash:md5_bin(term_to_binary({self(), erlang:make_ref(), Timers, node()})).

%% 32字节的订单号（理论值不能重复）
order_id() ->
    {{Y, Mo, D}, {H, Mi, S}} = erlang:localtime(),
    {_, _, Ms} = os:timestamp(),
    FunTime =
        fun(Int) ->
            if
                Int < 10 -> <<"0", (integer_to_binary(Int))/binary>>;
                true -> integer_to_binary(Int)
            end
        end,
    NewMs =
        if
            Ms < 10 -> <<"00000", (integer_to_binary(Ms))/binary>>;
            Ms < 100 -> <<"0000", (integer_to_binary(Ms))/binary>>;
            Ms < 1000 -> <<"000", (integer_to_binary(Ms))/binary>>;
            Ms < 10000 -> <<"00", (integer_to_binary(Ms))/binary>>;
            Ms < 100000 -> <<"0", (integer_to_binary(Ms))/binary>>;
            true -> integer_to_binary(Ms)
        end,
    crypto:rand_seed(),
    Rand = integer_to_binary(erl_random:random(100000, 999999)),
    Rand2 = integer_to_binary(erl_random:random(100000, 999999)),
    <<(FunTime(Y))/binary, (FunTime(Mo))/binary, (FunTime(D))/binary, (FunTime(H))/binary, (FunTime(Mi))/binary, (FunTime(S))/binary,
        NewMs/binary, Rand/binary, Rand2/binary>>.


mysql_encode(Arg) -> encode(term_to_binary(Arg), []).
mysql_decode(Msg) -> decode(Msg, []).


encode(<<>>, List) -> iolist_to_binary(lists:reverse(List));
encode(<<0:8, R/binary>>, List) -> encode(R, [<<"\\0">> | List]);
encode(<<92:8, R/binary>>, List) -> encode(R, [<<"\\\\">> | List]);
encode(<<10:8, R/binary>>, List) -> encode(R, [<<"\\n">> | List]);
encode(<<13:8, R/binary>>, List) -> encode(R, [<<"\\r">> | List]);
encode(<<39:8, R/binary>>, List) -> encode(R, [<<"\\'">> | List]);
encode(<<34:8, R/binary>>, List) -> encode(R, [<<"\\\"">> | List]);
encode(<<26:8, R/binary>>, List) -> encode(R, [<<"\\Z">> | List]);
encode(<<I:8, R/binary>>, List) -> encode(R, [I | List]).

decode(<<>>, List) -> iolist_to_binary(lists:reverse(List));
decode(<<"\\0", R/binary>>, List) -> decode(R, [0 | List]);
decode(<<"\\\\", R/binary>>, List) -> decode(R, [92 | List]);
decode(<<"\\n", R/binary>>, List) -> decode(R, [10 | List]);
decode(<<"\\r", R/binary>>, List) -> decode(R, [13 | List]);
decode(<<"\\'", R/binary>>, List) -> decode(R, [39 | List]);
decode(<<"\\\"", R/binary>>, List) -> decode(R, [34 | List]);
decode(<<"\\Z", R/binary>>, List) -> decode(R, [26 | List]);
decode(<<I:8, R/binary>>, List) -> decode(R, [I | List]).


sql(Values) ->
    FunFoldl = fun(Value, Acc) ->
        NewValue =
            if
                is_integer(Value) -> integer_to_binary(Value);
                Value =:= undefined -> <<>>;
                true -> <<"'", Value/binary, "'">>
            end,
        if
            Acc =:= <<>> -> NewValue;
            true -> <<Acc/binary, ",", NewValue/binary>>
        end
               end,
    Sql = lists:foldl(FunFoldl, <<>>, Values),
    <<"(", Sql/binary, ")">>.


term_to_bin(Args) when is_list(Args) ->
    FunFoldl =
        fun(Arg, Acc) ->
            NewArg = term_to_bin(Arg),
            if
                Acc =:= <<>> -> NewArg;
                true -> <<Acc/binary, ",", NewArg/binary>>
            end
        end,
    NewArg = lists:foldl(FunFoldl, <<>>, Args),
    <<"[", NewArg/binary, "]">>;

term_to_bin(Args) when is_tuple(Args) ->
    FunFoldl =
        fun(Arg, Acc) ->
            NewArg = term_to_bin(Arg),
            if
                Acc =:= <<>> -> NewArg;
                true -> <<Acc/binary, ",", NewArg/binary>>
            end
        end,
    NewArg = lists:foldl(FunFoldl, <<>>, tuple_to_list(Args)),
    <<"{", NewArg/binary, "}">>;

term_to_bin(undefined) -> <<>>;
term_to_bin(Arg) when is_map(Arg) -> term_to_bin(maps:values(Arg));
term_to_bin(Arg) when is_atom(Arg) -> atom_to_binary(Arg, utf8);
term_to_bin(Arg) when is_integer(Arg) -> integer_to_binary(Arg);
term_to_bin(Arg) when is_binary(Arg) -> Arg.


to_lower(Bin) -> to_lower(Bin, <<>>).

to_lower(<<>>, Acc) -> Acc;
to_lower(<<H:8, R/binary>>, Acc) ->
    NewAcc =
        if
            H >= 65 andalso H =< 90 -> <<Acc/binary, (H + 32):8>>;
            true -> <<Acc/binary, H:8>>
        end,
    to_lower(R, NewAcc).

to_upper(Bin) -> to_upper(Bin, <<>>).

to_upper(<<>>, Acc) -> Acc;
to_upper(<<H:8, R/binary>>, Acc) ->
    NewAcc =
        if
            H >= 97 andalso H =< 122 -> <<Acc/binary, (H - 32):8>>;
            true -> <<Acc/binary, H:8>>
        end,
    to_upper(R, NewAcc).

bin_to_term(<<>>) -> [];
bin_to_term(Bin) ->
    <<B1:8, _Bin/binary>> = Bin,
    if
        B1 =< 127 ->
            {ok, Ret, _} = erl_scan:string(binary_to_list(<<Bin/binary, ".">>)),
            case erl_parse:parse_term(Ret) of
                {ok, Term} ->
                    if
                        is_integer(Term) -> Term;
                        is_list(Term) -> Term;
                        true -> Bin
                    end;
                _ ->
                    Bin
            end;
        true ->
            Bin
    end.

join(Bins, Token) ->
    lists:foldl(
        fun(Bin, Acc) ->
            if
                Acc == <<>> -> Bin; true -> <<Bin/binary, Token/binary, Acc/binary>>
            end
        end,
        <<>>,
        Bins).
