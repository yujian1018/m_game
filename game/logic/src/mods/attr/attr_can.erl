-module(attr_can).

-include("logic_pub.hrl").

-export([
    attr/2
]).

attr(Uid, Data) -> attr(Uid, Data, []).

attr(_Uid, [], Acc) -> Acc;

attr(_Uid, [[?NICK, V] | R], Acc) ->
    binary_can:max_len(V, 36, <<"昵称"/utf8>>),
    binary_can:illegal(V),
    NewV = cpn_mask_word:check(V),
    attr(_Uid, R, [[?NICK, "=", NewV] | Acc]);

attr(_Uid, [[?SEX, V] | R], Acc) ->
    list_can:member(V, [0, 1], ?ERR_ARG_ERROR),
    attr(_Uid, R, [[?SEX, "=", V] | Acc]);

attr(_Uid, [[?ICON, V] | R], Acc) ->
    binary_can:illegal(V),
    Nick = load_attr:get_v(_Uid, ?ICON),
    if
        Nick =:= V -> ?return_err(?ERR_ATTR_NICK_SAME);
        true -> ok
    end,
    attr(_Uid, R, [[?ICON, "=", V] | Acc]);

attr(_Uid, [[?SIGN, V] | R], Acc) ->
    binary_can:max_len(V, 1024, <<"签名"/utf8>>),
    binary_can:illegal(V),
    NewV = cpn_mask_word:check(V),
    attr(_Uid, R, [[?SIGN, "=", NewV] | Acc]);

attr(_Uid, [[?CLIENT_SETTING, V] | R], Acc) ->
    binary_can:max_len(V, 1024, <<"设置"/utf8>>),
    binary_can:illegal(V),
    attr(_Uid, R, [[?CLIENT_SETTING, "=", V] | Acc]);

attr(_Uid, _R, _Acc) -> ?return_err(?ERR_ATTR_NO_KEY).

