-define(send_to_client, send_to_client).
-define(send_to_client(PID, MSG), PID ! {?send_to_client, MSG}).
-define(to_client_msg(MSG), {?send_to_client, MSG}).


-define(mod_msg(MOD, MSG), {mod, MOD, self(), ?MODULE, MSG}).
-define(remote_mod_msg(MOD, MSG), {mod, MOD, {node(), list_to_binary(pid_to_list(self()))}, ?MODULE, MSG}).
-define(call_msg(MOD, MSG), {call, MOD, self(), ?MODULE, MSG}).

-define(rpc_call(NODE, MOD, FUN, ARG), rpc:call(NODE, MOD, FUN, ARG, 10000)).
-define(rpc_cast(NODE, MOD, FUN, ARG), rpc:cast(NODE, MOD, FUN, ARG)).

-define(rpc_db_call(MOD, FUN, ARG), rpc:call(node(), MOD, FUN, ARG, 10000)).
-define(rpc_db_cast(MOD, FUN, ARG), ?rpc_cast(?db_node, MOD, FUN, ARG)).
-define(rpc_mgr_call(MOD, FUN, ARG), ?rpc_call(?mgr_node, MOD, FUN, ARG)).
-define(rpc_mgr_cast(MOD, FUN, ARG), ?rpc_cast(?mgr_node, MOD, FUN, ARG)).
-define(rpc_push_call(MOD, FUN, ARG), ?rpc_call(?push_node, MOD, FUN, ARG)).
-define(rpc_push_cast(MOD, FUN, ARG), ?rpc_cast(?push_node, MOD, FUN, ARG)).


-define(pid_call(NODE, UID, PIDBIN, MSG), catch rpc:call(NODE, player_server, rpc_call, [UID, PIDBIN, MSG], 10000)).
-define(pid_cast(NODE, UID, PIDBIN, MSG), rpc:cast(NODE, player_server, rpc_cast, [UID, PIDBIN, MSG])).

-define(send_cast_msg(PID, MOD, MSG), PID ! ?mod_msg(MOD, MSG)).
-define(send_cast(UID, MSG),
    case redis_online:is_online(UID) of
        {ok, PID} -> PID ! MSG;
        {ok, NODE, PIDBIN} -> ?pid_cast(NODE, UID, PIDBIN, MSG);
        false -> false
    end).

-define(send_call_msg(PID, MSG), catch gen_server:call(PID, MSG, 10000)).
-define(send_call(UID, MSG),
    case redis_online:is_online(UID) of
        {ok, PID} -> catch gen_server:call(PID, MSG, 10000);
        {ok, NODE, PIDBIN} -> ?pid_call(NODE, UID, PIDBIN, MSG);
        false -> false
    end).

-define(start_timer(TIME, MSG), erlang:start_timer(TIME, self(), MSG)).

