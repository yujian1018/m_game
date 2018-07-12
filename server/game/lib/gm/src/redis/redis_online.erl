%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 11. 九月 2017 下午2:31
%%%-------------------------------------------------------------------
-module(redis_online).

-include("gm_pub.hrl").

-define(TAB_ONLINE(UidBin), <<"online:", UidBin/binary>>).
-define(node, <<"node">>).
-define(pid, <<"pid">>).

-export([
    is_online/1
]).


is_online(Uid) when is_integer(Uid) ->
    is_online(integer_to_binary(Uid));
is_online(UidBin) ->
    case eredis_pool:q(pool_redis_1, [<<"HMGET">>, ?TAB_ONLINE(UidBin), ?pid, ?node]) of
        {ok, [?undefined, _]} -> false;
        {ok, [PidStr, Node]} ->
            SelfNode = node(),
            NodeAtom = list_to_atom(binary_to_list(Node)),
            if
                SelfNode =:= NodeAtom ->
                    case catch list_to_pid(binary_to_list(PidStr)) of
                        {'EXIT', _Exit} ->
                            eredis_pool:q(pool_redis_1, [<<"DEL">>, ?TAB_ONLINE(UidBin)]),
                            false;
                        Pid1 ->
                            case is_process_alive(Pid1) of
                                true ->
                                    {ok, Pid1};
                                false ->
                                    eredis_pool:q(pool_redis_1, [<<"DEL">>, ?TAB_ONLINE(UidBin)]),
                                    false
                            end
                    end;
                true ->
                    {ok, NodeAtom, PidStr}
            end;
        _ -> false
    end.