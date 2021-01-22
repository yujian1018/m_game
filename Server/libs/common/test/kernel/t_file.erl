%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%-------------------------------------------------------------------
-module(t_file).

-compile(export_all).

-export([log/2, log/3, log/4]).
-include_lib("kernel/include/file.hrl").

log(Log, State) ->
    log("/home/yujian/project/test/log/test.log", "~p~n", Log, State).

log(LogFormat, Log, State) ->
    log("/home/yujian/project/test/log/test.log", LogFormat, Log, State).

log(FileName, LogFormat, Log, write) ->
    NewLog = io_lib:format( LogFormat, Log ),
    file:write_file(FileName, NewLog);

log(FileName, LogFormat, Log, append) ->
    {ok, S} = file:open( FileName, [append] ),
    io:format(S, LogFormat, Log),
    file:close(S).



read() ->
    {ok, S} = file:open("/home/yujian/Downloads/ubuntu-15.10-desktop-amd64.iso", [raw, binary]),
    read(S, 1024*1024, 1).

read(S, Num, N) ->
    case file:read(S, Num*N) of
        {ok, _Bin} ->
            read(S, Num, N+1);
        eof ->
            ok
    end.

read1() ->
    file:read_file("/home/yujian/Downloads/ubuntu-15.10-desktop-amd64.iso").

read2() ->
    {ok, FileInfo} = file:read_file_info("/home/yujian/Downloads/ubuntu-15.10-desktop-amd64.iso"),
    OffSize = FileInfo#file_info.size div 10,
    Fun = fun(Offsize, Num) ->
        {ok, S} = file:open("/home/yujian/Downloads/ubuntu-15.10-desktop-amd64.iso", [raw, binary]),
        NewOffsize = Offsize*(Num-1),
        file:pread(S, NewOffsize, OffSize),
        file:close(S)
        end,
    test_pub:lists_spawn({0, 1}, 10, Fun).

