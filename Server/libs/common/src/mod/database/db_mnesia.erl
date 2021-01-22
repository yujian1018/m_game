%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 16. 五月 2016 下午5:23
%%%-------------------------------------------------------------------
-module(db_mnesia).

-include("erl_pub.hrl").


-export([
    write/1,
    read/2,
    do/1, transaction/1,
    foldl/3
]).

-export([
    ensure_started/0
]).


write(VO) ->
    mnesia:dirty_write(VO).


read(TabName, Key) ->
    mnesia:dirty_read(TabName, Key).


do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

%%  @doc    事务
transaction(F) ->
    case mnesia:transaction(F) of
        {atomic, Val} ->
            Val;
        Other ->
            ?ERROR("transaction error:~p~n", [Other]),
            {error, Other}
    end.



foldl(Fun, DataInit, TabName) -> foldl(Fun, DataInit, TabName, 0).

foldl(Fun, Data, Tab, Index) ->
    case mnesia:dirty_slot(Tab, Index) of
        '$end_of_table' -> Data;
        DataQuery -> foldl(Fun, lists:foldl(Fun, Data, DataQuery), Tab, Index + 1)
    end.



ensure_started() ->
    case mnesia_lib:is_running() of
        yes ->
            yes;
        no ->
            case mnesia_lib:exists(mnesia_lib:dir("schema.DAT")) of
                true ->
                    mnesia:start();
                false ->
                    {ok, MnesiaDir} = application:get_env(mnesia, dir),
                    case filelib:is_dir(MnesiaDir) of
                        true -> ok;
                        false ->
                            [file:make_dir(I) || I <- erl_file:dirs(MnesiaDir)],
                            mnesia:stop(),
                            mnesia:delete_schema([node()]),
                            mnesia:create_schema([node()]),
                            mnesia:start()
                    end
            end
    end.