%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 28. 七月 2016 下午5:04
%%%-------------------------------------------------------------------
-module(config_proto).

-include("obj_pub.hrl").

-export([handle_info/2]).


handle_info(?PROTO_GET_CONFIG_MD5, []) ->
    ?tcp_send(config_sproto:encode(?PROTO_GET_CONFIG_MD5, cache:all_config_md5()));

handle_info(?PROTO_GET_CONFIG, TabNames) ->
    NewTabNames =
        if
            is_binary(TabNames) -> [TabNames];
            true -> TabNames
        end,
    Ret = lists:map(
        fun(TabName) ->
            case lists:member(TabName, ?ALL_ALLOW_TAB) of
                true ->
                    Tab = list_to_atom(binary_to_list(TabName)),
                    case lists:member(Tab, ets:all()) of
                        true ->
                            case cache:all_data(Tab) of
                                [] -> [TabName, []];
                                [{_, _, AllData} | _] -> [TabName, AllData]
                            end;
                        _ ->
                            ?WARN("tab err:~p~n", [TabNames]),
                            ok
                    end;
                false -> [TabName, []]
            end
        end, NewTabNames),
    case length(NewTabNames) of
        1 -> ?tcp_send(config_sproto:encode(?PROTO_GET_CONFIG, hd(Ret)));
        _ -> ?tcp_send(config_sproto:encode(?PROTO_GET_CONFIG, Ret))
    end;

handle_info(_Cmd, _RawData) ->
    ?LOG("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).

