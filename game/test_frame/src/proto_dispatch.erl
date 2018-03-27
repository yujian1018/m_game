%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 27. 十二月 2017 下午5:10
%%%-------------------------------------------------------------------
-module(proto_dispatch).

-include("t_pub.hrl").
-export([
    recv_dispatch/3
]).

recv_dispatch(ModId, ProtoId, Data) ->
    case Data of
        [<<"err_code">> | Err] ->
            ?WARN("错误码:~p~n", [Err]),
            error;
        Data ->
            case proto_all:lookup_cmd(ModId) of
                {error, not_found} ->
                    ?WARN("proto_mod not_found:~p~n", [[ModId, ProtoId, Data]]),
                    error;
                {Mod, _ProtoMod} ->
                    case catch Mod:handle_info(ProtoId, Data) of
                        {'EXIT', Exit} ->
                            ?ERROR("EXIT:~p...mod_id~p...proto_id:~p...data:~p~n", [Exit, ModId, ProtoId, Data]),
                            error;
                        Data -> Data
                    end
            end
    end.