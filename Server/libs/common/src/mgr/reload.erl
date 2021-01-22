%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 24. 七月 2017 下午3:59
%%%-------------------------------------------------------------------
-module(reload).

-include_lib("kernel/include/file.hrl").
-include("erl_pub.hrl").

-behaviour(gen_server).

-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([reload/1]).


start_link(Apps) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Apps, []).


init(Apps) ->
    erlang:start_timer(?TIMEOUT_S_1, self(), ?timeout_s_1),
    {ok, #{apps => Apps}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({timeout, _TimerRef, ?timeout_s_1}, State = #{apps := Apps}) ->
    reload(Apps),
%%    erlang:garbage_collect(self()),
    erlang:start_timer(?TIMEOUT_S_1, self(), ?timeout_s_1),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


reload(Apps) ->
    Fun =
        fun(App) ->
            AppPath = case code:lib_dir(App, ebin) of
                          {error, _} -> "./ebin";
                          Path -> Path
                      end,
            case file:list_dir(AppPath) of
                {ok, S} ->
                    FunAllMod =
                        fun(Mod, Acc) ->
                            case lists:reverse(Mod) of
                                "maeb." ++ R -> [list_to_atom(lists:reverse(R)) | Acc];
                                _R -> Acc
                            end
                        end,
                    [reload_mod(M) || M <- lists:foldl(FunAllMod, [], S), is_changed(M)];
                _ ->
                    ok
            end
        end,
    lists:map(Fun, Apps).


is_changed(M) ->
    try
        module_vsn(M:module_info()) =/= module_vsn(code:get_object_code(M))
    catch _:_ ->
        false
    end.

module_vsn({M, Beam, _Fn}) ->
    {ok, {M, Vsn}} = beam_lib:version(Beam),
    Vsn;
module_vsn(L) when is_list(L) ->
    {_, Attrs} = lists:keyfind(attributes, 1, L),
    {_, Vsn} = lists:keyfind(vsn, 1, Attrs),
    Vsn.

reload_mod(Module) ->
    io:format("reloading ~p ...", [Module]),
    code:purge(Module),
    case code:load_file(Module) of
        {module, Module} ->
            io:format(" ok.~n"),
            case erlang:function_exported(Module, test, 0) of
                true ->
                    io:format(" - Calling ~p:test() ...", [Module]),
                    case catch Module:test() of
                        ok ->
                            io:format(" ok.~n"),
                            reload;
                        Reason ->
                            io:format(" fail: ~p.~n", [Reason]),
                            reload_but_test_failed
                    end;
                false ->
                    reload
            end;
        {error, Reason} ->
            io:format(" fail: ~p.~n", [Reason]),
            error
    end.
