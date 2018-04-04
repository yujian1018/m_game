%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 06. 五月 2016 上午10:58
%%%-------------------------------------------------------------------
-module(gm_can).

-include("gm_pub.hrl").

-export([no_need_login/1, no_decode/1]).


-define(NOT_NEED_PERMISSION_API, [{?ACCOUNT_SPROTO, ?ACCOUNT_LOGIN}]).
no_need_login(ProtoIdInt) ->
    case lists:member(ProtoIdInt, ?NOT_NEED_PERMISSION_API) of
        true -> ok;
        false -> {error, ?ERR_PERMISSION_DENIED}
    end.


-define(NOT_DECODE_CMD, [
    {?TAB_SPROTO, ?TAB_LIST},
    {?TAB_SPROTO, ?TAB_LOOKUP},
    {?TAB_SPROTO, ?TAB_ADD},
    {?TAB_SPROTO, ?TAB_UPDATE},
    {?TAB_SPROTO, ?TAB_DELETE},
    {?ACCOUNT_SPROTO, ?PMS_UPDATE},
    {?ACCOUNT_SPROTO, ?PMS_DEL},
    
    {?FILE_SPROTO, ?UPLOAD}
]).

no_decode(Cmd) ->
    lists:member(Cmd, ?NOT_DECODE_CMD).



