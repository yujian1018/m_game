%#!/usr/bin/env escript
%% -*- erlang -*-
%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 十一月 2016 上午10:21
%%%-------------------------------------------------------------------
-module(t_erl).

-include("core/t_record.hrl").

-export([
    head/0,
    head/2,
    enum/2,
    line/1,
    proto_json_encode/3,
    proto_json_decode/3,
    proto_list_encode/3,
    proto_list_decode/3,
    proto_binary_encode/3,
    proto_binary_decode/3,
    encode_null/1,
    decode_null/1,
    decode_list/0,
    hrl/2,
    lookup/2, lookup/3,
    lookup_null/0
]).

format(Msg, Arg) -> iolist_to_binary(io_lib:format(Msg, Arg)).

head() ->
    <<"%%%-------------------------------------------------------------------
%%% @doc
%%% 由配置自动生成！
%%% 请不要手动修改！
%%%-------------------------------------------------------------------"/utf8>>.

head(Mod, Type) ->
    Export =
        if
            Mod =:= <<"proto_all">> -> <<"-export([lookup_cmd/1]).">>;
            Type =:= proto -> <<"-export([decode/2, encode/2, decode_list/3]).">>;
            is_binary(Type) -> <<"-export([", Type/binary, "]).">>;
            true -> <<"-compile(export_all).">>
        end,

    <<(head())/binary, "

-module('", Mod/binary, "').

-include(\"", Mod/binary, ".hrl\").

", Export/binary, "

">>.


enum(FunName, KVList) ->
    FunFoldl =
        fun(VO, {ErlAcc, HrlAcc}) ->
            K = VO#line_constant.k,
            K2 =
                if
                    VO#line_constant.k2 =:= <<"atom">> -> K;
                    VO#line_constant.k2 =:= <<"binary">> -> <<"<<\"", K/binary, "\">>">>;
                    true -> VO#line_constant.k2
                end,
            V = VO#line_constant.v,
            Anno = if
                       VO#line_constant.anno =:= <<>> -> <<>>;
                       true -> <<"%%", (VO#line_constant.anno)/binary>>
                   end,
            NewK = format("~-40s", [<<"(?", K/binary, ")">>]),
            NewK2 = format("~-40s", [<<"<<\"", K/binary, "\">>;">>]),
            NewHrlK = format("~-40s", [<<K/binary, ",">>]),
            if
                V =:= undefined ->
                    {
                        <<ErlAcc/binary, "\n", FunName/binary, NewK/binary, "-> ", NewK2/binary, Anno/binary>>,
                        <<HrlAcc/binary, "\n-define(", NewHrlK/binary, K2/binary, ").", Anno/binary>>
                    };
                true ->
                    NewV = format("~-40s", [<<V/binary, ",">>]),
                    NewV1 = format("~-40s", [<<"(?", V/binary, ")">>]),
                    NewK22 = format("~-40s", [<<K2/binary, ";">>]),
                    {
                        <<ErlAcc/binary, "\n", FunName/binary, NewV1/binary, "-> ", NewK22/binary, Anno/binary>>,
                        <<HrlAcc/binary, "\n-define(", NewHrlK/binary, K2/binary, ").", Anno/binary, "\n-define(", NewV/binary, V/binary, ").">>
                    }
            end
        end,
    {RetErl, RetHrl} = lists:foldl(FunFoldl, {<<>>, <<>>}, KVList),
    BsAll =
        case [VO#line_constant.k || VO <- KVList, VO#line_constant.k =/= undefined] of
            [] -> <<FunName/binary, "_b() -> [].">>;
            Bs ->
                BsBin = lists:foldl(
                    fun(K, Acc) ->
                        if Acc =:= <<>> -> <<"?", K/binary>>;
                            true ->
                                <<Acc/binary, ",?", K/binary>>
                        end
                    end,
                    <<>>,
                    Bs),
                <<FunName/binary, "_b() -> [", BsBin/binary, "].">>
        end,

    AsAll =
        case [VO#line_constant.v || VO <- KVList, VO#line_constant.v =/= undefined] of
            [] -> <<FunName/binary, "_a() -> [].">>;
            As ->
                AsBin = lists:foldl(
                    fun(K, Acc) ->
                        if Acc =:= <<>> -> <<"?", K/binary>>;
                            true ->
                                <<Acc/binary, ",?", K/binary>>
                        end
                    end,
                    <<>>,
                    As),
                <<FunName/binary, "_a() -> [", AsBin/binary, "].">>
        end,
    {<<"\n", RetErl/binary, "\n", FunName/binary, "(_) -> <<>>.\n\n", BsAll/binary, "\n", AsAll/binary, "\n\n">>, <<"\n", RetHrl/binary, "\n">>}.


line(VO) ->
    K = VO#line_constant.k,
    K2 =
        if
            VO#line_constant.k2 =:= <<"atom">> -> list_to_binary(string:to_lower(binary_to_list(K)));
            VO#line_constant.k2 =:= <<"binary">> -> <<"<<\"", K/binary, "\">>">>;
            VO#line_constant.k2 =:= <<"string">> -> <<"\"", K/binary, "\"">>;
            true -> K
        end,
    Anno = if
               VO#line_constant.anno =:= <<>> -> <<>>;
               true ->
                   <<"%%", (VO#line_constant.anno)/binary>>
           end,
    NewK = format("~-40s", [<<K/binary, ",">>]),
    <<"\n-define(", NewK/binary, K2/binary, ").", Anno/binary>>.


proto_json_encode(_ModNum, ProtoName, [ProtoItem]) ->
    if
        ProtoItem#proto_item.k =:= undefined ->
            <<"encode(?", ProtoName/binary, ", {}) -> \n    <<\"[]\">>;\n\n">>;
        true ->
            FunFoldl =
                fun(VO, {ErlAcc, ArgAcc, IndexAcc}) ->
                    K = VO#atom_constant.k,
                    K2 = VO#atom_constant.v,
                    Json =
                        if
                            is_list(K2) ->
                                Arg = list_to_binary(string:join([string:to_upper(binary_to_list(I#atom_constant_2.k)) || I <- K2], ",")),
                                Map = list_to_binary(string:join(["                    {<<\"" ++ binary_to_list(I#atom_constant_2.k) ++ "\">>" ++ ", " ++ string:to_upper(binary_to_list(I#atom_constant_2.k)) ++ "}" || I <- K2], ",\n")),
                                V = <<"lists:map(
            fun({", Arg/binary, "}) ->
                {[
", Map/binary, "
                ]}
            end,
            ", (list_to_binary(string:to_upper(binary_to_list(K))))/binary, ")">>,
                                <<"        {<<\"", K/binary, "\">>, ", V/binary, "}">>;
                            true ->
                                <<"        {<<\"", K/binary, "\">>, ", (list_to_binary(string:to_upper(binary_to_list(K))))/binary, "}">>
                        end,
                    NewErlAcc =
                        if
                            K =:= <<"code">> -> ErlAcc;
                            ErlAcc =:= <<>> -> Json;
                            true -> <<ErlAcc/binary, ",\n", Json/binary>>
                        end,
                    NewArgAcc =
                        if
                            K =:= <<"code">> -> ArgAcc;
                            ArgAcc =:= <<>> -> list_to_binary(string:to_upper(binary_to_list(K)));
                            true -> <<ArgAcc/binary, ", ", (list_to_binary(string:to_upper(binary_to_list(K))))/binary>>
                        end,
                    NewIndexAcc =
                        if
                            K =:= <<"code">> -> IndexAcc;
                            true -> IndexAcc + 1
                        end,
                    {NewErlAcc, NewArgAcc, NewIndexAcc}
                end,
            {RetErl, Arg, Index} = lists:foldl(FunFoldl, {<<>>, <<>>, 0}, ProtoItem#proto_item.k),
            if
                Index =:= 0 ->
                    <<"encode(?", ProtoName/binary, ", _Arg) -> \n   [];\n\n">>;
                Index =:= 1 ->
                    <<"encode(?", ProtoName/binary, ", ", Arg/binary, ") -> \n   [\n", RetErl/binary, "\n    ];\n\n">>;
                true ->
                    <<"encode(?", ProtoName/binary, ", {", Arg/binary, "}) -> \n    [\n", RetErl/binary, "\n    ];\n\n">>
            end
    end.


proto_json_decode(_ModNum, FunName, [ProtoItem]) ->
    if
        ProtoItem#proto_item.k =:= undefined ->
            <<"decode(?", FunName/binary, ", _Arg) -> \n    {};\n\n">>;
        true ->
            FunFoldl =
                fun(VO, ErlAcc) ->
                    K = VO#atom_constant.k,
                    KUpper = erlang:list_to_binary(string:to_upper(binary_to_list(K))),
                    K2 = VO#atom_constant.v,
                    Json =
                        if
                            is_list(K2) ->
                                Arg1 = list_to_binary(string:join([string:to_upper(binary_to_list(I#atom_constant_2.k)) || I <- K2], ", ")),
                                Arg = <<"{", Arg1/binary, "}">>,

                                Arg2 = list_to_binary(string:join(["{<<\"" ++ binary_to_list(I#atom_constant_2.k) ++ "\">>, " ++ string:to_upper(binary_to_list(I#atom_constant_2.k)) ++ "}" || I <- K2], ", ")),
                                Arg3 = <<"{[", Arg2/binary, "]}">>,
                                <<"[", Arg/binary, " || ", Arg3/binary, " <- ", KUpper/binary, "]">>;
                            true ->
                                KUpper
                        end,
                    if
                        ErlAcc =:= <<>> -> Json;
                        true ->
                            <<ErlAcc/binary, ", \n        ", Json/binary>>
                    end
                end,
            RetErl = lists:foldl(FunFoldl, <<>>, ProtoItem#proto_item.k),

            FunArgFoldl =
                fun(VO, ArgAcc) ->
                    K = VO#atom_constant.k,
                    KUpper = erlang:list_to_binary(string:to_upper(binary_to_list(K))),
                    if
                        ArgAcc =:= <<>> ->
                            <<"{<<\"", K/binary, "\">>, ", KUpper/binary, "}">>;
                        true ->
                            <<ArgAcc/binary, ", {<<\"", K/binary, "\">>, ", KUpper/binary, "}">>
                    end
                end,
            Arg = lists:foldl(FunArgFoldl, <<>>, ProtoItem#proto_item.k),
            <<"decode(?", FunName/binary, ", {[", Arg/binary, "]}) -> \n    {\n        ", RetErl/binary, "\n    };\n\n">>
    end.



proto_list_decode(_ModNum, FunName, [_ProtoItem]) ->
    <<"decode(?", FunName/binary, ", Arg) -> \n    jiffy:decode(Arg);\n\n">>.

proto_list_encode(ModNum, FunName, [_ProtoItem]) ->
    <<"encode(?", FunName/binary, ", Arg) -> \n    [?", ModNum/binary, ", ?", FunName/binary, ", Arg];\n\n">>.


proto_binary_encode(ModNum, FunName, [ProtoItem]) ->
    if
        ProtoItem#proto_item.k =:= undefined ->
            <<"encode(?", FunName/binary, ", {}) -> \n    <<?", ModNum/binary, ":8, ?", FunName/binary, ":8>>;\n\n">>;
        true ->
            FunFoldlList =
                fun(VO, ErlListAcc) ->
                    K = VO#atom_constant.k,
                    KVariables = list_to_binary(string:to_upper(binary_to_list(K))),
                    K2 = VO#atom_constant.v,
                    if
                        is_list(K2) ->
                            Arg = case [string:to_upper(binary_to_list(I#atom_constant_2.k)) || I <- K2] of
                                      [I] -> list_to_binary(I);
                                      Items -> <<"{", (list_to_binary(string:join(Items, ", ")))/binary, "}">>
                                  end,

                            FunMap =
                                fun(Constant2) ->
                                    Constant2K2 = list_to_binary(string:to_upper(binary_to_list(Constant2#atom_constant_2.k))),
                                    binary_to_list(binary_type(Constant2K2, Constant2#atom_constant_2.v, encode))
                                end,
                            Arg2 = list_to_binary(string:join(lists:map(FunMap, K2), ", ")),
                            if
                                ErlListAcc =:= <<>> ->
                                    <<KVariables/binary, "_BIN = iolist_to_binary([<<", Arg2/binary, ">> || ", Arg/binary, " <- ", KVariables/binary, "]),">>;
                                true ->
                                    <<ErlListAcc/binary, "\n    ", KVariables/binary, "_BIN = iolist_to_binary([<<", Arg2/binary, ">> || ", Arg/binary, " <- ", KVariables/binary, "]),">>
                            end;
                        true ->
                            ErlListAcc
                    end
                end,
            ErlList = lists:foldl(FunFoldlList, <<>>, ProtoItem#proto_item.k),

            FunFoldlBin =
                fun(VO, ErlBinAcc) ->
                    K = VO#atom_constant.k,
                    KVariables = list_to_binary(string:to_upper(binary_to_list(K))),
                    K2 = VO#atom_constant.v,
                    Json =
                        if
                            is_list(K2) ->
                                <<"(byte_size(", KVariables/binary, "_BIN)):16, (", KVariables/binary, "_BIN)/binary">>;
                            true ->
                                binary_type(KVariables, K2, encode)
                        end,
                    if
                        ErlBinAcc =:= <<>> -> Json;
                        true -> <<ErlBinAcc/binary, ",\n        ", Json/binary>>
                    end
                end,
            ErlBin = lists:foldl(FunFoldlBin, <<>>, ProtoItem#proto_item.k),
            if
                length(ProtoItem#proto_item.k) =:= 1 ->
                    ArgInput = list_to_binary(string:join([string:to_upper(binary_to_list(I#atom_constant.k)) || I <- ProtoItem#proto_item.k], ", ")),
                    <<"encode(?", FunName/binary, ", ", ArgInput/binary, ") -> \n    ", ErlList/binary, "    \n    <<\n        ?", ModNum/binary, ":8,\n        ?", FunName/binary, ":8,\n        ", ErlBin/binary, "\n    >>;\n\n">>;
                true ->
                    ArgInput = list_to_binary(string:join([string:to_upper(binary_to_list(I#atom_constant.k)) || I <- ProtoItem#proto_item.k], ", ")),
                    <<"encode(?", FunName/binary, ", {", ArgInput/binary, "}) -> \n    ", ErlList/binary, "    \n    <<\n        ?", ModNum/binary, ":8,\n        ?", FunName/binary, ":8,\n        ", ErlBin/binary, "\n    >>;\n\n">>
            end
    end.



proto_binary_decode(_ModNum, FunName, [ProtoItem]) ->
    if
        ProtoItem#proto_item.k =:= undefined ->
            <<"decode(?", FunName/binary, ", <<>>) -> \n    {};\n\n">>;
        true ->
            FunFoldl =
                fun(VO, ErlAcc) ->
                    K = VO#atom_constant.k,
                    KUpper = erlang:list_to_binary(string:to_upper(binary_to_list(K))),
                    K2 = VO#atom_constant.v,
                    if
                        is_list(K2) ->
                            FunMap =
                                fun(Constant2) ->
                                    Constant2K2 = list_to_binary(string:to_upper(binary_to_list(Constant2#atom_constant_2.k))),
                                    binary_to_list(binary_type(Constant2K2, Constant2#atom_constant_2.v, decode))
                                end,
                            ArgInput2 = list_to_binary(string:join(lists:map(FunMap, K2), ", ")),
                            ArgOutput2 = case [string:to_upper(binary_to_list(I#atom_constant_2.k)) || I <- K2] of
                                             [I] -> list_to_binary(I);
                                             Items -> <<"{", (list_to_binary(string:join(Items, ", ")))/binary, "}">>
                                         end,
                            <<ErlAcc/binary, "Fun", KUpper/binary, " =
        fun(<<", ArgInput2/binary, ", Acc/binary>>) ->
            {Acc, ", ArgOutput2/binary, "}
        end,
    ", KUpper/binary, "_LIST = decode_list(Fun", KUpper/binary, ", ", KUpper/binary, ", []),\n">>;
                        true ->
                            ErlAcc
                    end
                end,
            RetErl = lists:foldl(FunFoldl, <<>>, ProtoItem#proto_item.k),

            FunArgFoldl =
                fun(VO, {ArgInputAcc, ArgOutputAcc}) ->
                    K = VO#atom_constant.k,
                    KUpper = erlang:list_to_binary(string:to_upper(binary_to_list(K))),
                    K2 = VO#atom_constant.v,
                    {Bin1, Bin2} = if
                                       is_list(K2) ->
                                           {<<"_", KUpper/binary, "_SIZE:16, ", KUpper/binary, ":_", KUpper/binary, "_SIZE/binary">>, <<KUpper/binary, "_LIST">>};
                                       true -> {binary_type(KUpper, K2, decode), KUpper}
                                   end,
                    NewBin1 = if
                                  ArgInputAcc =:= <<>> -> Bin1;
                                  true -> <<ArgInputAcc/binary, ", ", Bin1/binary>>
                              end,
                    NewBin2 = if
                                  ArgOutputAcc =:= <<>> -> Bin2;
                                  true -> <<ArgOutputAcc/binary, ", ", Bin2/binary>>
                              end,
                    {NewBin1, NewBin2}
                end,
            {ArgInput, ArgOutput} = lists:foldl(FunArgFoldl, {<<>>, <<>>}, ProtoItem#proto_item.k),
            <<"decode(?", FunName/binary, ", <<", ArgInput/binary, ">>) -> \n    ", RetErl/binary, "\n    {", ArgOutput/binary, "};\n\n">>
    end.


binary_type(KVariables, <<"u4">>, _Type) -> <<KVariables/binary, ":4">>;
binary_type(KVariables, <<"u8">>, _Type) -> <<KVariables/binary, ":8">>;
binary_type(KVariables, <<"u16">>, _Type) -> <<KVariables/binary, ":16">>;
binary_type(KVariables, <<"u32">>, _Type) -> <<KVariables/binary, ":32">>;
binary_type(KVariables, <<"u64">>, _Type) -> <<KVariables/binary, ":64">>;
binary_type(KVariables, <<"s4">>, _Type) -> <<KVariables/binary, ":4/signed">>;
binary_type(KVariables, <<"s8">>, _Type) -> <<KVariables/binary, ":8/signed">>;
binary_type(KVariables, <<"s16">>, _Type) -> <<KVariables/binary, ":16/signed">>;
binary_type(KVariables, <<"s32">>, _Type) -> <<KVariables/binary, ":32/signed">>;
binary_type(KVariables, <<"s64">>, _Type) -> <<KVariables/binary, ":64/signed">>;
binary_type(KVariables, <<"sstr">>, Type) ->
    if
        Type =:= encode ->
            <<"(byte_size(", KVariables/binary, ")):8, ", KVariables/binary, "/binary">>;
        true ->
            <<KVariables/binary, "_SIZE:8, ", KVariables/binary, ":", KVariables/binary, "_SIZE/binary">>
    end;
binary_type(KVariables, <<"lstr">>, Type) ->
    if
        Type =:= encode ->
            <<"(byte_size(", KVariables/binary, ")):16, ", KVariables/binary, "/binary">>;
        true ->
            <<"_", KVariables/binary, "_SIZE:16, ", KVariables/binary, ":_", KVariables/binary, "_SIZE/binary">>
    end;
binary_type(KVariables, <<"binary">>, Type) ->
    if
        Type =:= encode -> <<KVariables/binary, "/binary">>;
        true -> <<KVariables/binary, ":16">>
    end.


encode_null(ProtoKEY) ->
    <<"encode(_ProtoId, Arg) -> \n    io:format(\"encode error, not found mod_id:~p...proto_id:~p...arg:~p~n\", [?", ProtoKEY/binary, ", _ProtoId, Arg]), \n    false.\n\n\n">>.

decode_null(ProtoKEY) ->
    <<"decode(_ProtoId, Arg) -> \n    io:format(\"decode error, not found proto mod_id:~p...proto_id:~p...arg:~p~n\", [?", ProtoKEY/binary, ", _ProtoId, Arg]), \n    false.\n\n\n">>.

decode_list() ->
    <<"decode_list(_Fun, <<>>, _Acc) -> [];
    decode_list(Fun, Bin, Acc) ->
    case Fun(Bin) of
        {<<>>, Data} ->
            lists:reverse([Data | Acc]);
        {NewBin, Data} ->
            decode_list(Fun, NewBin, [Data | Acc])
    end.">>.

hrl(K, V) ->
    NewK = format("~-40s", [<<K/binary, ",">>]),
    <<"\n-define(", NewK/binary, V/binary, ").">>.

lookup(K, V, ModId) ->
    <<"\nlookup_cmd(<<\"", ModId/binary, "\">>) -> {?", K/binary, ", ?", V/binary, "};">>.
lookup(K, V) ->
    VUpper = list_to_binary(string:to_upper(binary_to_list(V))),
    <<"\nlookup_cmd(?", VUpper/binary, ") -> {?", K/binary, ", ?", V/binary, "};">>.
lookup_null() ->
    <<"\nlookup_cmd(_Arg) -> {error, not_found}.">>.