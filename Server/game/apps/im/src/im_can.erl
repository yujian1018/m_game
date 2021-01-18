%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 29. 六月 2017 下午3:03
%%%-------------------------------------------------------------------
-module(im_can).

-include("im_pub.hrl").

-export([
    verify_bin/2,
    verify_members/1
]).

verify_bin(Bin, MaxSize) ->
    binary_can:is_binary(Bin),
    binary_can:illegal(Bin),
    binary_can:max_size(Bin, MaxSize).

verify_members(Members) ->
    Len = length(Members),
    if
        Len =< 500 ->
            FunFoldl =
                fun(I, Acc) ->
                    case player_mgr:get(I) of
                        false -> Acc;
                        _Pid -> [I | Acc]
                    end
                end,
            lists:foldl(FunFoldl, [], Members);
        true -> ?return_err(?ERR_EXCEED_CHAT_NUM)
    end.
