%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 14. 十月 2017 下午5:17
%%%-------------------------------------------------------------------
-module(db_mnesia_init).

-include("db_pub.hrl").
-define(MNESIA_DIR, "./mnesia_db").

-export([
    start/0
]).

%% @doc 创建表格
-callback create_tab() -> ok.

start() ->
    application:set_env(mnesia, dc_dump_limit, 40),
    application:set_env(mnesia, dump_log_write_threshold, 10000),
    NewMnesiaDir =
        case application:get_env(db, mnesia_dir) of
            {ok, MnesiaDir} ->
                MnesiaDir;
            _ ->
                ?MNESIA_DIR
        end,
    
    application:set_env(mnesia, dir, NewMnesiaDir),
    case filelib:is_dir(NewMnesiaDir) of
        true -> mnesia:start();
        false ->
            file:make_dir(NewMnesiaDir),
            mnesia:delete_schema([node()]),
            mnesia:create_schema([node()]),
            mnesia:start(),
            [Mod:create_tab() || Mod <- erl_file:get_mods(db, db_mnesia_init)]
    end.

