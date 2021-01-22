%#!/usr/bin/env escript
%% -*- erlang -*-
%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 十一月 2016 上午10:21
%%%-------------------------------------------------------------------
-module(t_proto).

-include("core/t_record.hrl").

-export([main/1]).

main(Arg) ->
    [InputPath, OutPutPath, TestOutPath, HtmlOutPath, ErrCodePath] =
        case Arg of
            [A1, A2] -> [A1, A2, "test_frame/src/auto/proto", "priv/docroot/api", "../etc/def/common"];
            [A1, A2, A3] -> [A1, A2, A3, "priv/docroot/api", "../etc/def/common"];
            [A1, A2, A3, A4] -> [A1, A2, "test_frame/src/auto/proto", A3, A4];
            [A1, A2, A3, A4, A5] -> [A1, A2, A3, A4, A5];
            _ ->
                io:format("error input arg~n"),
                erlang:halt()
        end,
    main_proto(InputPath, OutPutPath, TestOutPath, HtmlOutPath, ErrCodePath).

main_proto(Input, Out, TestOutPath, HtmlOutPath, ErrCodePath) ->
    [file:make_dir(I) || I <- t_escripter:dirs(Out)],
    Yecc = t_escripter:get_yrl(),
    HeadHrl = t_erl:head(),
    FilePath = filename:absname("proto_all.proto", Input),
    [AllParse | _] = t_scan:main([FilePath, Yecc]),
    IsJson = lists:member(<<"json">>, [I#atom_constant_2.k || I <- AllParse#all_proto.options]),
    IsList = lists:member(<<"game">>, [I#atom_constant_2.k || I <- AllParse#all_proto.options]),
    
    IsTest = lists:member(<<"test">>, [I#atom_constant_2.k || I <- AllParse#all_proto.options]),
    FunMap =
        fun(VO) ->
            Mod = VO#line_constant.k,
            ProtoMod = VO#line_constant.k2,
            ProtoKEY = list_to_binary(string:to_upper(binary_to_list(ProtoMod))),
            ModId = VO#line_constant.v,
            ModId2 = VO#line_constant.v2,
            Parse = t_scan:main([filename:absname(<<ProtoMod/binary, ".proto">>, Input), Yecc]),
            FunFoldl =
                fun(Item, {DecodeAcc, EncodeAcc, HrlAcc, TestDecodeAcc, TestEncodeAcc, HtmlProtoAcc, HtmlNavAcc}) when is_record(Item, proto) ->
                    ProtoName = Item#proto.name,
                    ProtoId = Item#proto.proto,
                    {Decode, Encode, TestDecode, TestEncode} =
                        if
                            IsJson andalso IsTest ->
                                {
                                    t_erl:proto_json_decode(ProtoKEY, ProtoName, Item#proto.client),
                                    t_erl:proto_json_encode(ProtoKEY, ProtoName, Item#proto.server),
                                    t_erl:proto_json_decode(ProtoKEY, ProtoName, Item#proto.server),
                                    t_erl:proto_json_encode(ProtoKEY, ProtoName, Item#proto.client)
                                };
                            IsList andalso IsTest ->
                                {
                                    t_erl:proto_list_decode(ProtoKEY, ProtoName, Item#proto.client),
                                    t_erl:proto_list_encode(ProtoKEY, ProtoName, Item#proto.server),
                                    t_erl:proto_list_decode(ProtoKEY, ProtoName, Item#proto.server),
                                    t_erl:proto_list_encode(ProtoKEY, ProtoName, Item#proto.client)
                                };
                            IsJson ->
                                {
                                    t_erl:proto_json_decode(ProtoKEY, ProtoName, Item#proto.client),
                                    t_erl:proto_json_encode(ProtoKEY, ProtoName, Item#proto.server),
                                    <<>>,
                                    <<>>
                                };
                            IsList ->
                                {
                                    t_erl:proto_list_decode(ProtoKEY, ProtoName, Item#proto.client),
                                    t_erl:proto_list_encode(ProtoKEY, ProtoName, Item#proto.server),
                                    <<>>,
                                    <<>>
                                };
                            IsTest ->
                                {
                                    t_erl:proto_binary_decode(ProtoKEY, ProtoName, Item#proto.client),
                                    t_erl:proto_binary_encode(ProtoKEY, ProtoName, Item#proto.server),
                                    t_erl:proto_binary_decode(ProtoKEY, ProtoName, Item#proto.server),
                                    t_erl:proto_binary_encode(ProtoKEY, ProtoName, Item#proto.client)
                                };
                            true ->
                                {
                                    t_erl:proto_binary_decode(ProtoKEY, ProtoName, Item#proto.client),
                                    t_erl:proto_binary_encode(ProtoKEY, ProtoName, Item#proto.server),
                                    <<>>,
                                    <<>>
                                }
                        end,
                    
                    Hrl =
                        if
                            IsJson ->
                                t_erl:hrl(ProtoName, <<"<<\"", (list_to_binary(string:to_lower(binary_to_list(ProtoName))))/binary, "\">>">>);
                            true ->
                                t_erl:hrl(ProtoName, ProtoId)
                        end,
                    
                    Path = list_to_binary(string:to_lower(binary_to_list(ProtoName))),
                    {HtmlProto, HtmlNav} =
                        if IsJson -> t_html:proto(ModId2, ProtoId, Item#proto.anno,
                            <<"/", ModId/binary, "/", Path/binary>>, Item#proto.client, Item#proto.server);
                            true ->
                                t_html:proto(ModId, ProtoId, Item#proto.anno, <<"">>, Item#proto.client, Item#proto.server)
                        end,
                    
                    {
                        <<DecodeAcc/binary, Decode/binary>>,
                        <<EncodeAcc/binary, Encode/binary>>,
                        <<HrlAcc/binary, Hrl/binary>>,
                        <<TestDecodeAcc/binary, TestDecode/binary>>,
                        <<TestEncodeAcc/binary, TestEncode/binary>>,
                        <<HtmlProtoAcc/binary, HtmlProto/binary>>,
                        <<HtmlNavAcc/binary, HtmlNav/binary>>
                    }
                end,
            {RetDecodeErl, RetEncodeErl, RetHrl, TestDecodeErl, TestEncodeErl, HtmlProto, HtmlNav} =
                lists:foldl(FunFoldl, {<<>>, <<>>, <<>>, <<>>, <<>>, <<>>, <<>>}, Parse),
            
            HeadErl = t_erl:head(ProtoMod, proto),
            
            HrlProtoDef = if
                              IsJson ->
                                  t_erl:hrl(ProtoKEY, <<"<<\"", (list_to_binary(string:to_lower(binary_to_list(ProtoKEY))))/binary, "\">>">>);
                              true ->
                                  t_erl:hrl(ProtoKEY, ModId)
                          end,
            
            Hrl = [HeadHrl, HrlProtoDef, RetHrl],
            file:write_file(filename:absname(<<ProtoMod/binary, ".erl">>, Out),
                [HeadErl, RetDecodeErl, t_erl:decode_null(ProtoKEY), RetEncodeErl, t_erl:encode_null(ProtoKEY), t_erl:decode_list()]),
            file:write_file(filename:absname(<<ProtoMod/binary, ".hrl">>, Out), Hrl),
            if
                IsTest ->
                    [file:make_dir(I) || I <- t_escripter:dirs(TestOutPath)],
                    file:write_file(filename:absname(<<ProtoMod/binary, ".erl">>, TestOutPath),
                        [HeadErl, TestDecodeErl, t_erl:decode_null(ProtoKEY), TestEncodeErl, t_erl:encode_null(ProtoKEY), t_erl:decode_list()]),
                    file:write_file(filename:absname(<<ProtoMod/binary, ".hrl">>, TestOutPath), Hrl);
                true ->
                    ok
            end,
            {Mod, ProtoMod, ModId, ModId2, HtmlProto, HtmlNav}
        end,
    AllProto = lists:map(FunMap, AllParse#all_proto.list),
    HeadErlAll = t_erl:head(<<"proto_all">>, proto),
    E1 =
        if
            IsJson ->
                iolist_to_binary([t_erl:lookup(Handler, Sproto, ModId) || {Handler, Sproto, ModId, _ModId2, _HtmlProto, _HtmlNav} <- AllProto]);
            true ->
                iolist_to_binary([t_erl:lookup(Handler, Sproto) || {Handler, Sproto, _ModId, _ModId2, _HtmlProto, _HtmlNav} <- AllProto])
        end,
    
    H1 = iolist_to_binary([<<"\n-include(\"", Sproto/binary, ".hrl\").">> || {_Handler, Sproto, _ModId, _ModId2, _HtmlProto, _HtmlNav} <- AllProto]),
    H2 = iolist_to_binary([[t_erl:hrl(Handler, Handler), t_erl:hrl(Sproto, Sproto)] || {Handler, Sproto, _ModId, _ModId2, _HtmlProto, _HtmlNav} <- AllProto]),
    
    HrlAll = [HeadHrl, H1, H2],
    file:write_file(filename:absname("proto_all.erl", Out), [HeadErlAll, E1, t_erl:lookup_null()]),
    file:write_file(filename:absname("proto_all.hrl", Out), HrlAll),
    
    if
        IsJson ->
            is_json(AllProto, AllParse#all_proto.list, HtmlOutPath, ErrCodePath, Yecc, IsJson);
        IsList ->
            is_json(AllProto, AllParse#all_proto.list, HtmlOutPath, ErrCodePath, Yecc, false);
        true -> ok
    end,
    
    if
        IsTest ->
            file:write_file(filename:absname("proto_all.erl", TestOutPath), [HeadErlAll, E1, t_erl:lookup_null()]),
            file:write_file(filename:absname("proto_all.hrl", TestOutPath), HrlAll);
        true ->
            ok
    end.

is_json(AllProto, AllParseList, HtmlOutPath, ErrCodePath, Yecc, IsJson) ->
    ParseList =
        if
            IsJson ->
                [{VO#line_constant.anno, VO#line_constant.v2} || VO <- AllParseList];
            true ->
                [{VO#line_constant.anno, VO#line_constant.v} || VO <- AllParseList]
        end,
    
    [ApiHtml, ApiHtmlCss, ApiImg1, ApiImg2, Index3Html] = t_escripter:get_tpl([
        "parse_tool/ebin/api/api.html",
        "parse_tool/ebin/api/index.css",
        "parse_tool/ebin/api/topnav_bg.gif",
        "parse_tool/ebin/api/topnav_tab.gif",
        "parse_tool/ebin/api/index_3.html"
    ]),
    
    [file:make_dir(I) || I <- t_escripter:dirs(HtmlOutPath)],
    file:write_file(filename:absname(<<"index.css">>, HtmlOutPath), ApiHtmlCss),
    file:write_file(filename:absname(<<"topnav_bg.gif">>, HtmlOutPath), ApiImg1),
    file:write_file(filename:absname(<<"topnav_tab.gif">>, HtmlOutPath), ApiImg2),
    lists:map(
        fun(VO) ->
            {V2, HtmlProto, HtmlNav} =
                if
                    IsJson ->
                        {_Mod, _ProtoMod, _ModId, V3, HtmlProto3, HtmlNav3} = lists:keyfind(VO#line_constant.v2, 4, AllProto),
                        {V3, HtmlProto3, HtmlNav3};
                    true ->
                        {_Mod, _ProtoMod, ModId, _V2, HtmlProto4, HtmlNav4} = lists:keyfind(VO#line_constant.v, 3, AllProto),
                        {ModId, HtmlProto4, HtmlNav4}
                end,
            NavHtml = t_html:nav_html(V2, ParseList),
            Html1 = binary:replace(ApiHtml, <<"{{nav}}">>, NavHtml),
            Html2 = binary:replace(Html1, <<"{{page_nav}}">>, HtmlNav),
            Html3 = binary:replace(Html2, <<"{{proto}}">>, HtmlProto),
            file:write_file(filename:absname(<<"api_", V2/binary, ".html">>, HtmlOutPath), Html3)
        end, AllParseList),
    
    ErrCodeHtml = err_code(Yecc, ErrCodePath),
    file:write_file(filename:absname(<<"index_3.html">>, HtmlOutPath), binary:replace(Index3Html, <<"{{err_code}}">>, ErrCodeHtml)).


err_code(Yecc, Paths) ->
    NewPaths = string:tokens(Paths, "_"),
    Fun =
        fun(Path) ->
            lists:foldl(
                fun(FileName, ErrAcc) ->
                    FilePath = filename:absname(FileName, Path),
                    Parse = t_scan:main([FilePath, Yecc]),
                    FunFoldl =
                        fun(Item, Acc) when is_record(Item, enum) ->
                            TrBin = iolist_to_binary([<<"<tr><td>", (VO#line_constant.k2)/binary, "</td><td>", (VO#line_constant.anno)/binary, "</td></tr>\n">> || VO <- Item#enum.list]),
                            <<Acc/binary, TrBin/binary>>;
                            
                            (VO, Acc) when is_record(VO, line_constant) ->
                                <<Acc/binary, "<tr><td>", (VO#line_constant.k2)/binary, "</td><td>", (VO#line_constant.anno)/binary, "</td></tr>\n">>
                        end,
                    TrAcc = lists:foldl(FunFoldl, <<>>, Parse),
                    <<ErrAcc/binary, TrAcc/binary>>
                end,
                <<>>,
                filelib:wildcard("err_code*", Path))
        end,
    iolist_to_binary(lists:map(Fun, NewPaths)).