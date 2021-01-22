%#!/usr/bin/env escript
%% -*- erlang -*-
%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 十一月 2016 上午10:21
%%%-------------------------------------------------------------------
-module(t_def).

-include("core/t_record.hrl").

-export([main/1]).

main(Arg) ->
    [InputPath, OutPutPath] =
        case Arg of
            [A1, A2] ->
                NewA1 = if
                            is_atom(A1) -> atom_to_list(A1);
                            true -> A1
                        end,
                NewA2 = if
                            is_atom(A2) -> atom_to_list(A2);
                            true -> A2
                        end,
                [NewA1, NewA2];
            _ ->
                io:format("error input arg~n"),
                erlang:halt()
        end,
    main_def(InputPath, OutPutPath).

main_def(Input, Out) ->
    [file:make_dir(I) || I <- t_escripter:dirs(Out)],
    
    HeadHrl = t_erl:head(),
    Yecc = t_escripter:get_yrl(),
    
    FunMap =
        fun(FileName) ->
            FilePath = filename:absname(FileName, Input),
            Mod = list_to_binary(hd(string:tokens(FileName, "."))),
            
            Parse = t_scan:main([FilePath, Yecc]),
            FunFoldl =
                fun(Item, {ErlAcc, HrlAcc, FunAcc}) when is_record(Item, enum) ->
                    [Atom | _] = Item#enum.name,
                    FunName = Atom#atom_constant.k,
                    {Erl, Hrl} = t_erl:enum(FunName, Item#enum.list),
                    {<<ErlAcc/binary, Erl/binary>>, <<HrlAcc/binary, Hrl/binary>>, [FunName | FunAcc]};
                    
                    (Item, {ErlAcc, HrlAcc, FunAcc}) when is_record(Item, line_constant) ->
                        Hrl = t_erl:line(Item),
                        {ErlAcc, <<HrlAcc/binary, Hrl/binary>>, FunAcc}
                end,
            {RetErl, RetHrl, Funs} = lists:foldl(FunFoldl, {<<>>, <<>>, []}, Parse),
            NewFuns =
                if
                    Funs =:= [] -> <<>>;
                    true ->
                        lists:foldl(fun(I, Acc) ->
                            if
                                Acc =:= <<>> -> <<I/binary, "/1, ", I/binary, "_b/0, ", I/binary, "_a/0">>;
                                true -> <<Acc/binary, ",", I/binary, "/1, ", I/binary, "_b/0, ", I/binary, "_a/0">>
                            end
                                    end,
                            <<>>,
                            Funs)
                end,
            HeadErl = t_erl:head(Mod, NewFuns),
            
            file:write_file(filename:absname(<<Mod/binary, ".erl">>, Out), [HeadErl, RetErl]),
            file:write_file(filename:absname(<<Mod/binary, ".hrl">>, Out), [HeadHrl, RetHrl]),
            Mod
        end,
    AllDef = lists:map(FunMap, filelib:wildcard("*.def", Input)),
    AllHrl = iolist_to_binary([<<"\n-include(\"", Def/binary, ".hrl\").">> || Def <- AllDef]),
    file:write_file(filename:absname("def.hrl", Out), [t_erl:head(), AllHrl]).

