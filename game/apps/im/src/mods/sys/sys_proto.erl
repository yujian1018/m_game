%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 19. 七月 2016 下午1:25
%%%-------------------------------------------------------------------
-module(sys_proto).

-include("im_pub.hrl").

-export([handle_info/2]).

handle_info(?PROTO_SYS_GET_UPLOAD_TOKEN, []) ->
    AppId = ?get(?app_id),
    Iid = ?get(?i_id),
    Token = cache_token:set(AppId, Iid),
    ?tcp_send(sys_sproto:encode(?PROTO_SYS_GET_UPLOAD_TOKEN, Token));


handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).
