%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 19. 四月 2016 上午9:33
%%%-------------------------------------------------------------------
-module(im_user_proto).

-include("im_pub.hrl").

-export([handle_client/4]).


%% @doc 创建用户
handle_client(_Req, <<"create">>, AppsId, Arg) ->
    Iid = proplists:get_value(<<"i_id">>, Arg),
    im_can:verify_bin(Iid, 32),
    load_account:create_i_id(AppsId, Iid),
    <<"ok">>;

%%handle_client(_Req, <<"logout">>, AppsId, Arg) ->
%%    Iid = proplists:get_value(<<"i_id">>, Arg),
%%    im_can:verify_bin(Iid, 32),
%%    load_account:del_i_id(AppsId, Iid),
%%    <<"ok">>;

handle_client(_Req, Cmd, AppsId, Arg) ->
    ?PRINT("handle_info no match ProtoId:~p...arg:~p~n", [Cmd, [AppsId, Arg]]),
    ?return_err(?ERR_ARG_ERROR).
