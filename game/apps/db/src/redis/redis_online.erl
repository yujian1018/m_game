%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc redis 操作
%%%
%%% Created : 14. 九月 2016 下午3:56
%%%-------------------------------------------------------------------
-module(redis_online).

-include("db_pub.hrl").

-define(TAB_ONLINE(UidBin), <<"online:", UidBin/binary>>).
-define(node, <<"node">>).
-define(pid, <<"pid">>).

-export([
    set/3,
    del/1,
    is_online/1
]).


set(Uid, Pid, Node) ->
    UidBin = integer_to_binary(Uid),
    NodeBin = atom_to_list(Node),
    PidBin = pid_to_list(Pid),
    ?rpc_db_call(db_redis, q, [[<<"HMSET">>, ?TAB_ONLINE(UidBin), ?pid, PidBin, ?node, NodeBin]]).


del(Uid) when is_integer(Uid) -> del(integer_to_binary(Uid));
del(Uid) ->
%%    ?DEBUG("del online uid:~p~n", [[App, Uid, self()]]),
    ?rpc_db_call(db_redis, q, [[<<"DEL">>, ?TAB_ONLINE(Uid)]]).


is_online(Uid) when is_integer(Uid) -> is_online(integer_to_binary(Uid));
is_online(Uid) when is_binary(Uid) ->
    case ?rpc_db_call(db_redis, q, [[<<"HMGET">>, ?TAB_ONLINE(Uid), ?pid, ?node]]) of
        {ok, [?undefined, _]} -> false;
        {ok, [PidStr, Node]} ->
            SelfNode = node(),
            NodeAtom = list_to_atom(binary_to_list(Node)),
            if
                SelfNode =:= NodeAtom ->
                    case catch list_to_pid(binary_to_list(PidStr)) of
                        {'EXIT', _Exit} ->
%%                            ?ERROR("is_process_alive false:~p~n", [[Uid, _Exit]]),
                            del(Uid),
                            false;
                        Pid1 ->
                            case is_process_alive(Pid1) of
                                true ->
                                    {ok, Pid1};
                                false ->
%%                                    ?ERROR("is_process_alive false:~p~n", [[Uid, Pid1]]),
                                    del(Uid),
                                    false
                            end
                    end;
                true ->
                    {ok, NodeAtom, PidStr}
            end;
        _ -> false
    end;

is_online(Uids) when is_list(Uids) ->
    Ret = ?rpc_db_call(db_redis, qp, [[[<<"HMGET">>, ?TAB_ONLINE((integer_to_binary(Uid))), ?pid, ?node] || Uid <- Uids]]),
    Fun =
        fun(I) ->
            case I of
                {ok, [?undefined, _]} -> false;
                {ok, [PidBin, NodeBin]} ->
                    SelfNode = node(),
                    NodeAtom = list_to_atom(binary_to_list(NodeBin)),
                    if
                        SelfNode =:= NodeAtom ->
                            case catch list_to_pid(binary_to_list(PidBin)) of
                                {'EXIT', _Exit} ->
                                    false;
                                Pid1 ->
                                    case is_process_alive(Pid1) of
                                        true ->
                                            {ok, Pid1};
                                        false ->
                                            false
                                    end
                            end;
                        true ->
                            {ok, NodeAtom, PidBin}
                    end;
                _ ->
                    false
            end
        end,
    lists:map(Fun, Ret).

