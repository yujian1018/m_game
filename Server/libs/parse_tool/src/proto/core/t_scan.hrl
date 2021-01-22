%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 24. 三月 2016 下午5:02
%%%-------------------------------------------------------------------
-define(file_name, file_name).


-define(ERROR(Msg, Arg), io:format("~p:~p/~p ~p file:~p~n"Msg, [?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE, get(?file_name)|Arg]), erlang:halt()).
-define(ERROR(Msg), io:format("~p:~p/~p ~p file:~p~n"Msg, [?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE, get(?file_name)]), erlang:halt()).

-define(LOG(Msg, Arg), io:format("~p:~p/~p ~p file:~p~n"Msg, [?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE, get(?file_name)|Arg])).
-define(LOG(Msg), io:format("~p:~p/~p ~p file:~p~n"Msg, [?MODULE, ?FUNCTION_NAME, ?FUNCTION_ARITY, ?LINE, get(?file_name)])).


-define(RETURN_CHAR, <<"\n">>).


-record(col, {
    is_scan = false,
    type,
    char = <<>>
}).
