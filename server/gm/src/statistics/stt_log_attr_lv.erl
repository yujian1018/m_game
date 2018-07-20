%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 20. 十一月 2017 上午11:26
%%%-------------------------------------------------------------------
-module(stt_log_attr_lv).


-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, _ETimeBin, _ChannelIds) ->
    loop(STimeBin, 1).

loop(STimeBin, Page) ->
    PageIndex = integer_to_binary((Page - 1) * 5000),
    case erl_mysql:execute(pool_dynamic_1, <<"SELECT uid, lv FROM attr WHERE is_ai = 0 and uid not in (select uid from dz_account.white_list) limit ",
        PageIndex/binary, ", 5000;">>) of
        [] -> ok;
        Lvs ->
            Fun = fun([Uid, Lv], Acc) ->
                if
                    Acc =:= <<>> ->
                        <<"(", STimeBin/binary, ", ", (integer_to_binary(Uid))/binary, ", ", (integer_to_binary(Lv))/binary, ")">>;
                    true ->
                        <<Acc/binary, ", (", STimeBin/binary, ", ", (integer_to_binary(Uid))/binary, ", ", (integer_to_binary(Lv))/binary, ")">>
                end
                  end,
            case lists:foldl(Fun, <<>>, Lvs) of
                <<>> -> ok;
                Sqls ->
                    erl_mysql:execute(pool_log_1, <<"INSERT INTO log_attr_lv (`c_times`, `uid`, `lv`) VALUES ", Sqls/binary, ";">>)
            end,
            loop(STimeBin, Page + 1)
    end.
    