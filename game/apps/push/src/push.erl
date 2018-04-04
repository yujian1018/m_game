%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 九月 2017 下午2:55
%%%-------------------------------------------------------------------
-module(push).

-include("push_pub.hrl").

-export([
    create_uid/2,
    add_uid/2,
    del_uid/2,
    
    push_data/2
]).

create_uid(Event, Uin) ->
    push_srv:create_uid(Event, Uin).

add_uid(Event, Uin) ->
    push_srv:add_uid(Event, Uin).

del_uid(Event, Uin) ->
    push_srv:del_uid(Event, Uin).


push_data(1, Uin) ->
    app_push:httpc(Uin, ?PUSH_MSG_1_EN).