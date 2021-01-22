%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 29. 五月 2018 上午11:24
%%%-------------------------------------------------------------------
-module(erl_rpc).

-include("erl_pub.hrl").

-export([
    call/2
]).

call(UrlId, Args) ->
    {Url, Arg, Method} = cache_rule:get_url(UrlId),
    case Url of
        <<"http", _/binary>> ->
            NewArgs = data(fun(I) -> cow_uri:urlencode(I) end, Arg, Args),
            if
                Method =:= <<"get">> -> erl_httpc:get(<<Url/binary, "?", NewArgs/binary>>, []);
                Method =:= <<"post">> -> erl_httpc:post(Url, [], "application/x-www-form-urlencoded", NewArgs)
            end;
        Url ->
            [NodeBin, ModBin, FunBin] = binary:split(Url, <<",">>, [global]),
            Node = binary_to_atom(NodeBin, utf8),
            Mod = binary_to_atom(ModBin, utf8),
            Fun = binary_to_atom(FunBin, utf8),
            Ret =
                case binary:split(NodeBin, <<"@127.0.0.1">>) of
                    [_, _] ->
                        rpc:call(node(), Mod, Fun, Args, 10000);
                    _ ->
                        if
                            Method =:= <<"call">> -> rpc:call(Node, Mod, Fun, Args, 10000);
                            Method =:= <<"cast">> -> rpc:cast(Node, Mod, Fun, Args)
                        end
                end,
            case Ret of
                {badrpc,nodedown} ->
                    ?throw(?ERR_NOTFOUND_SERVICE);
                {badrpc, Reason} ->
                    ?ERROR("badrpc:~tp~n", [[UrlId, Node, Mod, Fun, Args, Reason]]),
                    ?throw(?ERR_CRASH_SERVICE);
                Ret -> Ret
            end
    end.


data(FunEncode, Arg, Args) ->
    FunFoldl =
        fun(GetKey, Acc) ->
            Ret =
                case binary:split(GetKey, <<"=">>, [global]) of
                    [Key, <<"*">>] -> lists:keyfind(Key, 1, Args);
                    [Key, Val] -> {Key, Val}
                end,
            if
                Ret =:= false -> Acc;
                true ->
                    {Key2, Val2} = Ret,
                    if
                        Acc =:= <<>> -> <<Key2/binary, "=", (FunEncode(Val2))/binary>>;
                        true -> <<Acc/binary, "&", Key2/binary, "=", (FunEncode(Val2))/binary>>
                    end
            end
        end,
    lists:foldl(FunFoldl, <<>>, binary:split(Arg, <<"&">>, [global])).
