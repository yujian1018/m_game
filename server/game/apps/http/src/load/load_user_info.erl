%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 20. 十月 2017 下午5:22
%%%-------------------------------------------------------------------
-module(load_user_info).

-include_lib("http_pub.hrl").

-export([
    create_info/3,
    create_info/4,
    reset_token/2,
    reset_info/5
]).


%% 游客，账户注册
create_info(Uin, ChannelId, GMTOfftime) ->
    Token = erl_string:uuid_bin(),
    ?rpc_db_call(db_mysql, ea, [<<"insert into user_info(uin, token, gmt_offset) values (",
        (integer_to_binary(Uin))/binary, ", '",
        Token/binary, "', ",
        GMTOfftime/binary, ") ON DUPLICATE KEY UPDATE token = '", Token/binary, "';">>]),
    redis_token:set(Uin, Token, ChannelId),
    {Uin, Token}.

%% sdk注册
create_info(Uin, ChannelId, GMTOfftime, {Nick, Sex, HeadImg, Address}) ->
    Token = erl_string:uuid_bin(),
    ?rpc_db_call(db_mysql, ea, [<<"insert into user_info(uin, token, gmt_offset, nick, sex, head_img, address) values (",
        (integer_to_binary(Uin))/binary, ", '",
        Token/binary, "', ",
        GMTOfftime/binary, ", '",
        Nick/binary, "', '",
        Sex/binary, "','",
        HeadImg/binary, "','",
        Address/binary, "') ON DUPLICATE KEY UPDATE token = '",
        Token/binary, "', nick = '",
        Nick/binary, "',sex = ",
        Sex/binary, ", head_img='",
        HeadImg/binary, "',address = '",
        Address/binary, "';">>]),
    redis_token:set(Uin, Token, ChannelId),
    {Uin, Token}.


%% 更新玩家信息
reset_info(Uin, Nick, Sex, HeadImg, Address) ->
    ?rpc_db_call(db_mysql, ea, [<<"update user_info set nick='",
        Nick/binary, "', sex=",
        Sex/binary, ", head_img='",
        HeadImg/binary, "', address='",
        Address/binary, "' where uin = ",
        (integer_to_binary(Uin))/binary, ";">>]).


%% 更新token
reset_token(Uin, ChannelId) ->
    Token = erl_string:uuid_bin(),
    UinBin = integer_to_binary(Uin),
    [OldToken, _] = ?rpc_db_call(db_mysql, ea, [<<"SELECT token FROM user_info WHERE uin = ",
        UinBin/binary, ";INSERT INTO user_info(uin, token) VALUES (",
        UinBin/binary, ", '",
        Token/binary, "') ON DUPLICATE KEY UPDATE token = '", Token/binary, "';">>]),
    if
        OldToken =:= [] -> redis_token:set(UinBin, Token, ChannelId);
        true ->
            [[OldToken1] | _] = OldToken,
            redis_token:reset(OldToken1, UinBin, Token, ChannelId)
    end,
    {Uin, Token}.