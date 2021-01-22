%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 18. 七月 2016 上午9:17
%%%-------------------------------------------------------------------
-module(assert_can).

-include("erl_pub.hrl").

-export([
    exit_pro_dict/1, exit_pro_dict/3,
    
    exit_process/1, exit_process/3
]).

%% @doc 存在进程字典
exit_pro_dict(Key) -> exit_pro_dict(Key, true, ?ERR_NOTEXIT_PRO_DICT).
exit_pro_dict(Key, true, ErrCode) ->
    case erlang:get(Key) of
        undefined -> ?return_err(ErrCode);
        V -> V
    end;
exit_pro_dict(Key, false, ErrCode) ->
    case erlang:get(Key) of
        undefined -> ok;
        _V -> ?return_err(ErrCode)
    end.


exit_process(Pid) -> exit_process(Pid, true, ?ERR_NOTEXIT_PROCESS).
exit_process(Pid, true, ErrCode) ->
    case is_pid(Pid) of
        true ->
            case is_process_alive(Pid) of
                true -> Pid;
                false -> ?return_err(ErrCode)
            end;
        false -> ?return_err(ErrCode)
    end;
exit_process(Pid, false, ErrCode) ->
    case is_pid(Pid) of
        true ->
            case is_process_alive(Pid) of
                false -> Pid;
                true -> ?return_err(ErrCode)
            end;
        false -> Pid
    end.