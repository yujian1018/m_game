%% Author: Administrator
%% Created: 2012-9-21
%% Description: 负责登陆,注册
%% 
-module(login_proto).

-include("im_pub.hrl").

-export([
    handle_info/2
]).

%% 登录游戏
handle_info(?PROTO_LOGIN, [AppId, Iid]) ->
    binary_can:illegal(AppId),
    binary_can:max_size(AppId, 32),
    
    binary_can:illegal(Iid),
    binary_can:max_size(Iid, 32),
    
    InAppId = load_account:get_account(AppId, Iid),
    
    case player_mgr:get(Iid) of
        false -> ok;
        Pid ->
            gen_server:call(Pid, {stop, ?ERR_OTHER_LOGIN}, 10000)
    end,
    player_mgr:add(self(), Iid),
    ?tcp_send(login_sproto:encode(?PROTO_DATA_OVER, 1)),
    ?put_new(?i_id, Iid),
    ?put_new(?app_id, InAppId),
    ?put_new(?tid, sets:new()),
    ?put(?login_state, ?LOGIN_INIT_DONE);


handle_info(_Cmd, _RawData) ->
    ?LOG("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).

