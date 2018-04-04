%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 22. 十二月 2016 下午4:02
%%%-------------------------------------------------------------------
-module(http_server).

-include("http_pub.hrl").
-export([init/2]).

init(Req, Opts) ->
    Ret =
        case cowboy_req:path_info(Req) of
            [Mod, Proto] ->
%%                ?INFO("111:~p~n", [[Mod, Proto, get_arg(Req)]]),
                catch dispath_handler(Req, Mod, Proto, cowboy_req:parse_qs(Req));
            [<<"favicon.ico">>] ->
                <<"data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==">>;
            _Other ->
%%                ?INFO("path:~p", [_Other]),
                {throw, {?ERR_ARG_ERROR, <<"url参数不正确"/utf8>>}}
        end,
%%    ?INFO("222:~p~n", [Ret]),
    {ok, response_json(Req, Ret), Opts}.


response_json(Req, Ret) ->
    Body =
        case Ret of
            {throw, ErrCode} -> err_code_proto:to_msg(ErrCode);
            {'EXIT', _Exit} ->
                ?ERROR("EXIT:~p~n", [_Exit]),
                err_code_proto:to_msg(?ERR_SERVER_CRASH);
            BodyBin when is_binary(BodyBin) -> BodyBin
        end,
    cowboy_req:reply(200, #{
        <<"Access-Control-Allow-Origin">> => <<"*">>,
        <<"Access-Control-Allow-Methods">> => <<"GET,POST">>,
        <<"Content-Type">> => <<"application/json">>}, Body, Req).


dispath_handler(Req, ModId, ProtoId, Arg) ->
    case proto_all:lookup_cmd(ModId) of
        {error, _ErrCode} -> ?return_err(?ERR_ARG_ERROR, <<"沒有对应的api"/utf8>>);
        {HandlerMod, ProtoMod} ->
            Ret = if
                      ProtoId =:= ?BULLETIN ->
                          HandlerMod:handle_client(Req, ProtoId, Arg);
                      true ->
                          sign(Arg),
                          HandlerMod:handle_client(Req, ProtoId, Arg)
                  end,
            case Ret of
                Data when is_binary(Data) -> Data;
                Data ->
                    jiffy:encode({[{<<"code">>, 200} | ProtoMod:encode(ProtoId, Data)]})
            end
    end.


sign(Arg) ->
    case proplists:get_value(<<"sign">>, Arg) of
        undefined -> ?return_err(?ERR_BAD_SIGN, <<"签名不正确"/utf8>>);
        Sign ->
            Date = proplists:get_value(<<"date">>, Arg, <<>>),
            Now = erl_time:now(),
            DateInt = binary_to_integer(Date),
            if
                abs(DateInt - Now) =< (?TIMEOUT_MO_1 / 1000) ->
                    case proplists:get_value(<<"sign_type">>, Arg, <<>>) of
                        <<"server">> ->
                            list_to_binary(erl_hash:md5(<<"date=", Date/binary, "&key=029bc38977bc512490db73b2c4439f8b">>)) =:= Sign;
                        _ ->
                            list_to_binary(erl_hash:md5(<<"date=", Date/binary, "&key=2b9eb9e4f0211582e4cf056af5f60289">>)) =:= Sign
                    end;
                true ->
                    ?return_err(?ERR_BAD_SIGN, <<"签名不正确"/utf8>>)
            end
    end.