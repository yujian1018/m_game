%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description :
%%%
%%% Created : 2012-9-24
%%% -------------------------------------------------------------------
-module(im_proto).

-include("im_pub.hrl").

-export([recv_dispatch/4]).

recv_dispatch(ModId, ProtoId, Data, LoginState) ->
%%    ?WARN("111~w~n", [[ModId, ProtoId, Data, Uid, LoginState]]),
    Ret = if
        
              ModId =:= ?SYS_SPROTO andalso ProtoId =:= ?PROTO_SERVER_TIMER ->
                  catch ?sys_proto:handle_info(ProtoId, Data);
        
              LoginState =:= ?LOGIN_CONNECT_INIT andalso ModId =:= ?LOGIN_SPROTO ->
%%                  ?WARN("111~p~n", [[ModId, [ProtoId | Data]]]),
                  catch ?login_proto:handle_info(ProtoId, Data);
              ModId =:= ?ERR_CODE_SPROTO andalso ProtoId =:= ?PROTO_SYS_TICK ->
                  ok;
        
              true ->
                  if
                      LoginState =:= ?LOGIN_INIT_DONE ->
                          {Mod, _ProtoMod} = proto_all:lookup_cmd(ModId),
                          if
                              Mod =:= error ->
                                  ?DEBUG("error no module_id:~p~n", [ModId]),
                                  ?return_err(?ERR_NOTFOUND_API);
                              Mod =:= ?LOGIN_SPROTO andalso ProtoId =:= ?PROTO_LOGIN ->
                                  ?DEBUG("error relogin data:~p~n", [[ModId, ProtoId, Data]]),
                                  ?return_err(?ERR_RE_ONLINE);
                              true ->
                                  ?put(?proto_id, {ModId, ProtoId}),
                                  catch Mod:handle_info(ProtoId, Data)
                          end;
                      true ->
%%                          ?DEBUG("not login:~p~n", [[ModId, ProtoId | Data]]),
                          error
                  end
          end,
    case Ret of
        {throw, _ErrCode} ->
            err_code_proto:err_code(Ret, ModId, ProtoId, Data);
        {'EXIT', _Exit} ->
            err_code_proto:err_code(_Exit, ModId, ProtoId, Data);
        _ ->
            Tick = ?get(?tick),
            ?put(?tick, Tick + 1)
    end.