%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 16. 五月 2016 下午5:23
%%%-------------------------------------------------------------------
-module(db_mnesia_dump).

-include("erl_pub.hrl").


-export([
    dump_to_textfile/1, dump_to_textfile/2,
    load_textfile/1, load_textfile/2
]).


dump_to_textfile(File) ->
    dump_to_textfile(all, File).


dump_to_textfile(TabName, File) ->
    case ets:lookup_element(mnesia_gvar, mnesia_status, 2) of
        running ->
            {ok, S} = file:open(File, [write]),
            Tabs = lists:delete(schema, mnesia_lib:local_active_tables()),
            if
                TabName =:= all ->
                    Defs = lists:map(
                        fun(T) -> {T, [{record_name, mnesia_lib:val({T, record_name})},
                            {attributes, mnesia_lib:val({T, attributes})}]}
                        end,
                        Tabs),
                    io:format(S, "~p.~n", [{tables, Defs}]),
                    [dump_next(S, Tab, 0) || Tab <- Tabs];
                true ->
                    case lists:member(TabName, Tabs) of
                        true ->
                            Defs = [{TabName, [{record_name, mnesia_lib:val({TabName, record_name})},
                                {attributes, mnesia_lib:val({TabName, attributes})}]}],
                            io:format(S, "~p.~n", [{tables, Defs}]),
                            dump_next(S, TabName, 0);
                        false -> ?WARN("mnesia中不存在该表：~tp", [TabName])
                    end
            end,
            file:close(S);
        false -> ?WARN("mnesia沒有启动")
    end.


dump_next(S, TabName, Cont) ->
    DBRet =
        if
            Cont =:= 0 ->
                mnesia:activity(async_dirty, fun mnesia:select/4, [TabName, [{'_', [], ['$_']}], 10000, read]);
%%                mnesia:transaction(fun() -> mnesia:select(TabName, [{'_', [], ['$_']}], 10000, read) end);
            true ->
                mnesia:activity(async_dirty, fun mnesia:select/1, [Cont])
%%                mnesia:transaction(fun() -> mnesia:select(Cont) end)
        end,
    case DBRet of
        '$end_of_table' -> ok;
        {Data, NewCont} ->
            lists:foreach(fun(Term) -> io:format(S, "~p.~n", [setelement(1, Term, TabName)]) end, Data),
            dump_next(S, TabName, NewCont)
    end.


load_textfile(File) ->
    db_mnesia:ensure_started(),
    {ok, S} = file:open(File, [read]),
    {ok, {tables, TabsInfo}} = io:read(S, ''),
    create_tab(TabsInfo),
    next(S).

load_textfile(File, Fun) ->
    db_mnesia:ensure_started(),
    {ok, S} = file:open(File, [read]),
    {ok, {tables, TabsInfo}} = io:read(S, ''),
    create_tab(TabsInfo),
    next(S, Fun).


create_tab(TabsInfo) ->
    Tabs = lists:delete(schema, mnesia_lib:local_active_tables()),
    Fun = fun({Tab, Def}) ->
        case lists:member(Tab, Tabs) of
            true -> ?INFO("表已经存在");
            false ->
                
                case mnesia:create_table(Tab, Def) of
                    {aborted, Reason} -> ?INFO("创建表失败:~tp", [{Tab, Def, Reason}]);
                    _ -> ok
                end
        end
          end,
    lists:map(Fun, TabsInfo).

next(S) ->
    case io:read(S, '') of
        {ok, Record} ->
            mnesia:dirty_write(Record),
            next(S);
        _Err ->
            ?ERROR("ERR io:read:~tp", [_Err]),
            file:close(S)
    end.


next(S, Fun) ->
    case io:read(S, '') of
        {ok, Record} ->
            mnesia:dirty_write(Fun(Record)),
            next(S, Fun);
        _Err -> ?ERROR("ERR io:read", [_Err])
    end.