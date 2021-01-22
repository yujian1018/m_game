%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 21. 十月 2016 下午3:00
%%%-------------------------------------------------------------------
-module(prof_process).

-export([
    pstack/1,
    etop/0,
    etop_mem/0,
    etop_stop/0,
    gc_all/0,
    trace/1,
    trace/2,
    trace_stop/0
]).


pstack(Reg) when is_atom(Reg) ->
    case whereis(Reg) of
        undefined -> undefined;
        Pid -> pstack(Pid)
    end;
pstack(Pid) ->
    io:format("~s~n", [element(2, process_info(Pid, backtrace))]).


%进程CPU占用排名
etop() ->
    spawn(fun() -> etop:start([{output, text}, {interval, 10}, {lines, 20}, {sort, reductions}]) end).

%进程Mem占用排名
etop_mem() ->
    spawn(fun() -> etop:start([{output, text}, {interval, 10}, {lines, 20}, {sort, memory}]) end).

%停止etop
etop_stop() ->
    etop:stop().


% 对所有process做gc
gc_all() ->
    [erlang:garbage_collect(Pid) || Pid <- processes()].


%trace Mod 所有方法的调用
trace(Mod) ->
    dbg:tracer(),
    dbg:tpl(Mod, '_', []),
    dbg:p(all, c).

%trace Node上指定 Mod 所有方法的调用, 结果将输出到本地shell
trace(Node, Mod) ->
    dbg:tracer(),
    dbg:n(Node),
    dbg:tpl(Mod, '_', []),
    dbg:p(all, c).

%停止trace
trace_stop() ->
    dbg:stop_clear().