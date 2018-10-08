%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 数据打点，新增用户在哪里流失掉
%%%
%%% Created : 12. 八月 2016 上午9:44
%%%-------------------------------------------------------------------
-module(log_login_log).

-include("logic_pub.hrl").


-record(log_login, {
    uuid = 0,
    uid = 0,
    channel_id = 0,
    ip = <<>>,
    udid = <<>>,
    t1,     %服务器连接完成
    t2,     %准备下载配置表
    t3,     %登陆获取uid,token
    t4,     %uid,token核对完成
    t5,     %配置表下载完成，并解析完成
    t6,     %进入到主界面
    t7,     %点击快速开始按钮
    t8,     %点击sng按钮
    t9,     %点击mtt按钮
    t10,    %快速开始 进入牌局，桌子初始化完成
    t11,    %SNG模式 进入牌局，桌子初始化完成
    t12,    %MTT模式 进入牌局，桌子初始化完成
    t13     %退出牌局
}).

-define(LOG_LOGIN_INSERT(UUId, Uid, ChannelId, Ip, Udid, InsertK, InsertV),
    <<"insert into log_login_log (uuid, uid, channel_id, ip, udid, ", InsertK/binary, ") values ('", UUId/binary, "', ", Uid/binary, ", ", ChannelId/binary, ", '", Ip/binary, "', '", Udid/binary, "', ", InsertV/binary, ");">>
).

-export([
    log_login_init/2,
    log_login_uid/2,
    log_login_add/1,
    log_login_save/0
]).

-define(log_login, log_login). %%登陆状态进程字典 {uuid, uid, time,time.....}

log_login_init(Ip, Udid) ->
    UUId = erl_bin:uuid_bin(),
    ?put_new(?log_login, #log_login{uuid = UUId, t1 = erl_time:now(), ip = Ip, udid = Udid}).

log_login_uid(Uid, ChannelId) ->
    case get(?log_login) of
        ?undefined -> ok;
        LogLogin ->
            put(?log_login, LogLogin#log_login{uid = Uid, channel_id = ChannelId})
    end.

log_login_add(Num) ->
    case get(?log_login) of
        ?undefined -> ok;
        LogLogin ->
            Now = erl_time:now(),
            put(?log_login, setelement(Num + 6, LogLogin, Now))
    end.

log_login_save() ->
    case get(?log_login) of
        ?undefined -> ok;
        LogLogin ->
            UUID = LogLogin#log_login.uuid,
            Size = tuple_size(LogLogin) + 1,
            if
                UUID =/= 0 ->
                    case log_login_insert(LogLogin, 7, Size, <<>>, <<>>) of
                        {<<>>, <<>>} -> ok;
                        {InsertK, InsertV} ->
                            Uid = integer_to_binary(LogLogin#log_login.uid),
                            ChannelId = LogLogin#log_login.channel_id,
                            Ip = LogLogin#log_login.ip,
                            Udid = LogLogin#log_login.udid,
                            log_login_log ! ?LOG_LOGIN_INSERT(UUID, Uid, ChannelId, Ip, Udid, InsertK, InsertV)
                    end;
                true ->
                    ok
            end
    end.

log_login_insert(_LogLogin, MaxSize, MaxSize, InsertK, InsertV) -> {InsertK, InsertV};
log_login_insert(LogLogin, Index, MaxSize, InsertK, InsertV) ->
    case element(Index, LogLogin) of
        ?undefined -> log_login_insert(LogLogin, Index + 1, MaxSize, InsertK, InsertV);
        Time ->
            NewV = integer_to_binary(Time),
            {NewInsertK, NewInsertV} =
                if
                    InsertK =:= <<>> ->
                        {<<"t", (integer_to_binary(Index - 6))/binary, "_times">>, NewV};
                    true ->
                        {<<InsertK/binary, ", t", (integer_to_binary(Index - 6))/binary, "_times">>, <<InsertV/binary, ", '", NewV/binary, "'">>}
                end,
            
            log_login_insert(LogLogin, Index + 1, MaxSize, NewInsertK, NewInsertV)
    end.

