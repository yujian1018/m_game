%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 27. 六月 2017 下午7:55
%%%-------------------------------------------------------------------

-include_lib("network/include/network_pub.hrl").

-include("../src/auto/def/def.hrl").
-include("../src/auto/proto/proto_all.hrl").


-define(tid, tid).
-define(i_id, i_id).
-define(app_id, app_id).


-define(proto_id,                               proto_id).%% 当前的模块号协议号
-define(uin,                                    uin).%% 账户唯一编号
-define(uid,                                    uid).%% 角色唯一编号
-define(channel_id,                             channel_id).%% 渠道号
-define(login_state,                            login_state).%% 登陆状态
-define(tick,                                   tick).%% 心跳
-define(login_times,                            login_times).%% 登陆时间

-define(LOGIN_CONNECT_INIT,                     0).%% 0默认设置
-define(LOGIN_DONE,                             1).%% 表示登录校验完成
-define(LOGIN_CREATE_ROLE,                      2).%% 0默认设置 表示登录校验完成
-define(LOGIN_INIT_DONE,                        3).%% 表示数据初始化完成，可以收发数据，开放所有功能
-define(PLAYER_TERMINATE,                       4).%% 玩家下线
-define(LOGIN_ING,                              5).%% 特殊状态，玩家正在登陆中


-define(CHANNEL_ALL,                            -999).%%所有渠道