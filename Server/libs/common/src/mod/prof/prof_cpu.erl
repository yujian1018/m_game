%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 21. 十月 2016 下午2:59
%%%-------------------------------------------------------------------
-module(prof_cpu).


-export([
    scheduler_usage/0,
    scheduler_stat/0,
    eprof/1, eprof_stop/0,
    eprof_all/1, fprof/3, fprof/1
]).


% 统计下1s每个调度器CPU的实际利用率(因为有spin wait、调度工作, 可能usage 比top显示低很多)
scheduler_usage() ->
    scheduler_usage(30000).

scheduler_usage(RunMs) ->
    erlang:system_flag(scheduler_wall_time, true),
    Ts0 = lists:sort(erlang:statistics(scheduler_wall_time)),
    timer:sleep(RunMs),
    Ts1 = lists:sort(erlang:statistics(scheduler_wall_time)),
    erlang:system_flag(scheduler_wall_time, false),
    Cores = lists:map(fun({{I, A0, T0}, {I, A1, T1}}) ->
        {I, (A1 - A0) / (T1 - T0)} end, lists:zip(Ts0, Ts1)),
    {A, T} = lists:foldl(fun({{_, A0, T0}, {_, A1, T1}}, {Ai, Ti}) ->
        {Ai + (A1 - A0), Ti + (T1 - T0)} end, {0, 0}, lists:zip(Ts0, Ts1)),
    Total = A / T,
    io:format("~p~n", [[{total, Total} | Cores]]).


% 统计下1s内调度进程数量(含义：第一个数字执行进程数量，第二个数字迁移进程数量)
scheduler_stat() ->
    scheduler_stat(30000).

scheduler_stat(RunMs) ->
    erlang:system_flag(scheduling_statistics, enable),
    Ts0 = erlang:system_info(total_scheduling_statistics),
    timer:sleep(RunMs),
    Ts1 = erlang:system_info(total_scheduling_statistics),
    erlang:system_flag(scheduling_statistics, disable),
    lists:map(fun({{Key, In0, Out0}, {Key, In1, Out1}}) ->
        {Key, In1 - In0, Out1 - Out0} end, lists:zip(Ts0, Ts1)).


eprof(Pid) ->
    eprof:start(),
    eprof:profile([Pid]),
    timer:sleep(30000),
    eprof_stop().

eprof_stop() ->
    eprof:stop_profiling(),
    eprof:analyze(),
    eprof:stop().


%%ordsets:subtract/2                  113577     0.33     40766  [      0.36]
%%ordsets:fold/3                       66455     0.36     45463  [      0.68]
%%ordsets:size/1                       48405     0.37     46625  [      0.96]
%%ordsets:new/0                        86496     0.39     48982  [      0.57]
%%ordsets:intersection/2               86462     0.41     51875  [      0.60]
%%dict:fold_seg/4                     251967     0.61     76282  [      0.30]
%%dict:find_val/2                     335366     0.63     78369  [      0.23]
%%gen_server:try_dispatch/4            14720     0.81    100952  [      6.86]
%%dict:get_bucket_s/2                 326090     0.84    104790  [      0.32]
%%lists:'-filter/2-lc$^0/1-0-'/2      240440     0.94    118127  [      0.49]
%%dict:fold_bucket/3                  256886     1.08    134855  [      0.52]
%%dict:get_bucket/2                   325774     1.17    146136  [      0.45]
%%dict:fold/3                          24042     1.21    151494  [      6.30]
%%dict:map_bkt_list/2                 352155     1.32    165617  [      0.47]
%%dict:find/2                         325774     1.36    170533  [      0.52]
%%ordsets:add_element/2               331361     1.60    200778  [      0.61]
%%dict:append_bkt/3                   626522     1.63    204493  [      0.33]
%%ordsets:union/2                     289999     2.51    314201  [      1.08]
%%erlang:'++'/2                       606886     2.56    320575  [      0.53]
%%dict:maybe_expand/2                1248562     2.68    335177  [      0.27]
%%dict:store/3                        622039     2.70    338617  [      0.54]
%%dict:'-store/3-fun-0-'/3            622039     2.74    342841  [      0.55]
%%dict:'-append/3-fun-0-'/3           626522     2.77    347341  [      0.55]
%%dict:maybe_expand_aux/2            1248562     3.30    413462  [      0.33]
%%erlang:phash/2                     1580757     4.93    617558  [      0.39]
%%dict:store_bkt_val/3               1514760     5.93    742738  [      0.49]
%%dict:append/3                       626522     6.17    772521  [      1.23]
%%dict:map_bucket/2                  1250074     6.19    775550  [      0.62]
%%dict:on_bucket/3                   1254230     6.86    859257  [      0.69]
%%dict:get_slot/2                    1580004     7.38    923578  [      0.58]
%%erlang:setelement/3                5029166    12.01   1503684  [      0.30]
%%lists:foldl/3                      1470796    13.92   1743075  [      1.19]
%%--------------------------------  --------  -------  --------  [----------]
%%Total:                            23829000  100.00%  12520862  [      0.53]


% 对整个节点内所有进程执行eprof, eprof 对线上业务有一定影响,慎用!
% 建议TimeoutSec<10s，且进程数< 1000，否则可能导致节点crash
% 结果:
% 输出每个方法实际执行时间（不会累计方法内其他mod调用执行时间）
% 只能得到mod - Fun 执行次数 执行耗时
eprof_all(TimeoutSec) ->
    eprof(processes() -- [whereis(eprof)], TimeoutSec).

eprof(Pids, TimeoutSec) ->
    eprof:start(),
    eprof:start_profiling(Pids),
    timer:sleep(TimeoutSec),
    eprof:stop_profiling(),
    eprof:analyze(total),
    eprof:stop().


% 对MFA 执行分析，会严重减缓运行，建议只对小量业务执行
% 结果:
% fprof 结果比较详细，能够输出热点调用路径
fprof(M, F, A) ->
    fprof:start(),
    fprof:apply(M, F, A),
    fprof:profile(),
    fprof:analyse(),
    fprof:stop().

fprof(Pid) ->
    fprof:trace([start, cpu_time, {file, "./fprof.trace"}, {procs, Pid}]),  %% 或者可以trace多个Pid，[PidSpec]
    timer:sleep(30000),
    fprof:trace([stop]),
    fprof:profile({file, "./fprof.trace"}),
    fprof:analyse([{dest, "fprof.analysis"}, {sort, own}, totals, no_callers]),
    fprof:stop().
%%    format_fprof_analyze().  %% 详细参数见： http://www.erlang.org/doc/man/fprof.html#analyse-2
