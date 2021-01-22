%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 12. 六月 2016 下午3:09
%%%-------------------------------------------------------------------
-module(user_default).


-export([reload/0, reload/1, stop/1]).

reload() ->
    reload(no_app).

reload(AppName) ->
    ListDir =
        fun(Path) ->
            {ok, S} = file:list_dir(Path),
            S
        end,
    
    AppPath = case code:lib_dir(AppName, ebin) of
                  {error, _} -> "./ebin";
                  Path -> Path
              end,
    
    FileList = ListDir(AppPath),
    
    FunMap =
        fun(I) ->
            case lists:reverse(I) of
                "maeb." ++ R -> c:l(list_to_atom(lists:reverse(R)));
                R -> io:format("111:~p~n", [lists:reverse(R)])
            end
        end,
    lists:map(FunMap, FileList).


stop(obj_server) -> obj_server_app:stop();

stop(scene_arena) -> scene_app:stop();
stop(scene_normal) -> scene_app:stop();

stop(gm_tool) -> gm_app:stop();

stop(http) -> http_app:stop();

stop(mgr_server) -> mgr_server_app:stop();

stop(db_server) -> db_server_app:stop().
