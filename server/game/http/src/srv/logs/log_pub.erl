%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 19. 十月 2017 上午10:37
%%%-------------------------------------------------------------------
-module(log_pub).

-include("http_pub.hrl").

-export([
    sup/0, save_data/2
]).

-export([
    log_db_device/5,
    log_feedback/7
]).

sup() ->
    [
        log_db_device,
        log_feedback,
        log_login_log
    ].


save_data(LogType, Data) ->
    if
        LogType =:= log_db_device ->
            Sql = lists:foldl(fun(I, Acc) ->
                if Acc =:= <<>> -> I;true -> <<Acc/binary, ",", I/binary>> end end, <<>>, Data),
            ?rpc_db_call(db_mysql, el, [<<"insert into log_device (udid, uin, device_pf, ip, c_times) VALUES ">>, Sql, <<";">>]);
        
        LogType =:= log_feedback ->
            Sql = lists:foldl(fun(I, Acc) ->
                if Acc =:= <<>> -> I;true -> <<Acc/binary, ";", I/binary>> end end, <<>>, Data),
            ?rpc_db_call(db_mysql, el, [<<"INSERT INTO feedback (uid, auto_id, msg)  SELECT 1, MAX(auto_id)+1, 's' FROM feedback WHERE uid = 1;
            insert into feedback (`uid`, auto_id, `udid`, `ip`, `c_times`, `channel_id`, `version`, `msg`, `contact`) VALUES ">>, Sql, <<";">>])
    end.


log_db_device(<<>>, _Uin, _DevicePf, _Ip, _Now) -> ok;
log_db_device(<<"win32">>, _Uin, _DevicePf, _Ip, _Now) -> ok;
log_db_device(Udid, Uin, DevicePf, Ip, Now) -> log_db_device ! erl_bin:sql([Udid, Uin, DevicePf, Ip, Now]).


log_feedback(Uid, Udid, Ip, ChannelId, Version, Msg, Contact) ->
    Sql = <<" select ", Uid/binary, ", max(auto_id)+1, ", Udid/binary, ", ", Ip/binary, ", ",
        (erl_time:now_bin())/binary, ", ", ChannelId/binary, ", ", Version/binary, ", ",
        Msg/binary, ", ", Contact/binary, " from feedback where uid = ", Uid/binary>>,
    log_feedback ! Sql.