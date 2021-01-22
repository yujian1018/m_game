%#!/usr/bin/env escript
%% -*- erlang -*-
%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 十一月 2016 上午10:21
%%%-------------------------------------------------------------------
-module(t_html).

-include("core/t_record.hrl").

-export([
    proto/6,
    nav_html/2
]).

format(Msg, Arg) -> iolist_to_binary(io_lib:format(Msg, Arg)).

proto(ModId, ProtoId, ProtoDes, ApiInfo, Client, Server) ->
    ClientBin = proto_html(Client),
    ServerBin = proto_html(Server),
    NewApiInfo =
        if
            ApiInfo =:= <<>> -> <<>>;
            true -> <<"(<font color=\"green\">\"", ApiInfo/binary, "\"</font>)">>
        end,
    {
        <<"<div class=\"p_content\">
            <a name=\"", ProtoId/binary, "\"></a>
            <h3>", ModId/binary, ".", ProtoId/binary, " ", ProtoDes/binary, NewApiInfo/binary, "</h3>
            <div class=\"code_source\">
			    <pre class=\"code_show\">
<font color=\"#000\">请求格式</font>
{
"/utf8, ClientBin/binary, "
}
<font color=\"#000\">回复格式</font>
{
"/utf8, ServerBin/binary, "
}
                </pre>
            </div>
        </div>">>,
        <<"<li><a href=\"api_", ModId/binary, ".html#", ProtoId/binary, "\">", ModId/binary, ".", ProtoId/binary, " ", ProtoDes/binary, "</a></li>">>
    }.

proto_html([ProtoItem]) ->
    case ProtoItem#proto_item.k of
        undefined -> <<"">>;
        ProtoData ->
            FunFoldl =
                fun(VO, {Index, Len, ErlBin}) ->
                    K = VO#atom_constant.k,
                    K2 = VO#atom_constant.v,
                    ItemBin =
                        if
                            is_list(K2) ->
                                {_, _, ListBin} =
                                    lists:foldl(
                                        fun(Cons, {Index2, Len2, Acc}) ->
                                            Key = if
                                                      Index2 =:= Len2 ->
                                                          format("~-16s", [<<"\"", (Cons#atom_constant_2.k)/binary, "\"">>]);
                                                      true ->
                                                          format("~-16s", [<<"\"", (Cons#atom_constant_2.k)/binary, "\",">>])
                                                  end,
                                            {Index2 + 1, Len2, <<Acc/binary, "\n        ", Key/binary, "<font color='#333'>", (Cons#atom_constant_2.anno)/binary, "</font>">>}
                                        end,
                                        {1, length(K2), <<>>},
                                        K2),
                                if
                                    Index =:= Len -> <<"    \"", K/binary, "\":[{", ListBin/binary, "\n    }]">>;
                                    true -> <<"    \"", K/binary, "\":[{", ListBin/binary, "\n    }],">>
                                end;
                            true ->
                                Key =
                                    if
                                        Index =:= Len -> format("~-16s", [<<"\"", K/binary, "\"">>]);
                                        true -> format("~-16s", [<<"\"", K/binary, "\",">>])
                                    end,
                                case VO#atom_constant.anno of
                                    undefined -> <<>>;
                                    Anno -> <<"    ", Key/binary, "<font color='#333'>", Anno/binary, "</font>">>
                                end
                        end,
                    {Index + 1, Len, <<ErlBin/binary, "\n", ItemBin/binary>>}
                end,
            {_, _, Html} = lists:foldl(FunFoldl, {1, length(ProtoData), <<>>}, ProtoData),
            Html
    end.


nav_html(ModId, List) ->
    iolist_to_binary(lists:map(
        fun({Des, Id}) ->
            NewDes =
                if
                    Des =:= undefined -> <<>>;
                    true -> hd(binary:split(Des, <<"\r\n">>))
                end,
            if
                ModId =:= Id ->
                    <<"<li class=\"selected\"><a href=\"api_", Id/binary, ".html\">", NewDes/binary, "(", Id/binary, ")</a></li>\n">>;
                true ->
                    <<"<li class=\"\"><a href=\"api_", Id/binary, ".html\">", NewDes/binary, "(", Id/binary, ")</a></li>\n">>
            end
        end, List)).