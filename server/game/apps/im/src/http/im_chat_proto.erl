%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 19. 四月 2016 上午9:33
%%%-------------------------------------------------------------------
-module(im_chat_proto).

-include("im_pub.hrl").

-export([handle_client/4]).


handle_client(_Req, <<"create">>, _AppsId, Arg) ->
    Members = ?decode(proplists:get_value(<<"member">>, Arg, <<"[]">>)),
    Tid = proplists:get_value(<<"tid">>, Arg, <<"">>),
    im_can:verify_bin(Tid, 32),
    NewMembers = im_can:verify_members(Members),
    case room_mgr:create(Tid, NewMembers) of
        {error, Err} -> ?return_err(Err);
        _ -> <<"ok">>
    end;

handle_client(_Req, <<"logout">>, _AppsId, Arg) ->
    case proplists:get_value(<<"tid">>, Arg) of
        undefined ->
            ?return_err(?ERR_ARG_ERROR);
        Tid ->
            im_can:verify_bin(Tid, 32),
            case room_mgr:logout(Tid) of
                {error, Err} -> ?return_err(Err);
                _ -> <<"ok">>
            end
    end;

handle_client(_Req, <<"add">>, _AppsId, Arg) ->
    Tid = proplists:get_value(<<"tid">>, Arg),
    Iid = proplists:get_value(<<"i_id">>, Arg),
    im_can:verify_bin(Tid, 32),
    im_can:verify_bin(Iid, 32),
    case room_mgr:add(Tid, Iid) of
        {error, Err} -> ?return_err(Err);
        _ -> <<"ok">>
    end;

handle_client(_Req, <<"kick">>, _AppsId, Arg) ->
    Tid = proplists:get_value(<<"tid">>, Arg),
    Iid = proplists:get_value(<<"i_id">>, Arg),
    im_can:verify_bin(Tid, 32),
    im_can:verify_bin(Iid, 32),
    case room_mgr:tick(Tid, Iid) of
        {error, Err} -> ?return_err(Err);
        _ -> <<"ok">>
    end;

handle_client(_Req, Cmd, _AppsId, Arg) ->
    ?INFO("handle_info no match ProtoId:~p...arg:~p~n", [Cmd, Arg]),
    ?return_err(?ERR_ARG_ERROR).
