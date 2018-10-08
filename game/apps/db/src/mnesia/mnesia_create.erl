%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 04. 一月 2018 下午7:55
%%%-------------------------------------------------------------------
-module(mnesia_create).

-include("db_pub.hrl").
-include("mnesia_ex.hrl").

-behaviour(db_mnesia_init).

-export([
    create_tab/0
]).


create_tab() ->
    ?NEW_TABLE(room_st, disc_only_copies).