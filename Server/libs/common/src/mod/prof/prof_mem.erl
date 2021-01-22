%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc etop 无法应对10w+ 进程节点, 下面代码就没问题了；找到可疑proc后通过pstack、message_queu_len 排查原因
%%%
%%% Created : 21. 十月 2016 下午3:00
%%%-------------------------------------------------------------------
-module(prof_mem).

-export([
    proc_mem_all/1,
    proc_mem/1,
    proc_mem/2
]).

proc_mem_all(SizeLimitKb) ->
    Procs = [{undefined, Pid} || Pid<- erlang:processes()],
    proc_mem(Procs, SizeLimitKb).

proc_mem(SizeLimitKb) ->
    Procs = [{Name, Pid} || {_, Name, Pid, _} <- release_handler_1:get_supervised_procs(),
        is_process_alive(Pid)],
    proc_mem(Procs, SizeLimitKb).

proc_mem(Procs, SizeLimitKb) ->
    SizeLimit = SizeLimitKb * 1024,
    {R, Total} = lists:foldl(fun({Name, Pid}, {Acc, TotalSize}) ->
        case erlang:process_info(Pid, total_heap_size) of
            {_, Size0} ->
                Size = Size0*8,
                case Size > SizeLimit of
                    true -> {[{Name, Pid, Size} | Acc], TotalSize+Size};
                    false -> {Acc, TotalSize}
                end;
            _ -> {Acc, TotalSize}
        end
                             end, {[], 0}, Procs),
    R1 = lists:keysort(3, R),
    {Total, lists:reverse(R1)}.