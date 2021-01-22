%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 复制与rebar，编译后代码打包成一个整体，方便使用
%%%
%%% Created : 20. 五月 2016 上午11:09
%%%-------------------------------------------------------------------
-module(t_escripter).


-export([
    escript/1,
    get_yrl/0,
    dirs/1,
    get_tpl/1
]).

escript(Arg) ->
    escriptize("parse_tool/ebin",Arg).


escriptize(Ebins, ToEscript) ->
    BeamBin = usort(load_files(Ebins, "ebin")),
    {ok, {"mem", Zip}} = zip:create("mem", BeamBin, [memory]),
    Head = <<"#!/usr/bin/env escript\n%% -*- erlang -*-\n%%! -pa ", (list_to_binary(Ebins))/binary, "\n">>,
    
    FileBin = iolist_to_binary([Head, Zip]),
    
    [file:write_file(atom_to_list(ToFile), FileBin) || ToFile <- ToEscript],
    [os:cmd("chmod 777 " ++ atom_to_list(I)) || I <- ToEscript].


load_files(PrePath, Dir) ->
    Files = filelib:wildcard("*", Dir),
    Fun =
        fun(File) ->
            NewPath = filename:join(PrePath, File),
            NewDir = filename:join(Dir, File),
            case filelib:is_dir(NewDir) of
                true ->
                    load_files(NewPath, NewDir);
                false ->
                    {ok, Bin} = file:read_file(NewDir),
                    {NewPath, Bin}
            end
        end,
    lists:map(Fun, Files).


%% Given "foo/bar/baz", return ["foo", "foo/bar", "foo/bar/baz"].
dirs(Dir) -> dirs1(filename:split(Dir), "", []).
dirs1([], _, Acc) -> lists:reverse(Acc);
dirs1([H | T], "", []) -> dirs1(T, H, [H]);
dirs1([H | T], Last, Acc) ->
    Dir = filename:join(Last, H),
    dirs1(T, Dir, [Dir | Acc]).

usort(List) ->
    lists:ukeysort(1, lists:flatten(List)).


get_yrl() ->
    FileSpec = get_files(),
    case [B || {N, B, _I} <- FileSpec, N =:= "parse_tool/ebin/t_yecc.yrl"] of
        [] -> erlang:error("not found t_yecc.yrl");
        [Bin | _] ->
            Bin
    end.


get_files() ->
    Dir = string:tokens(code:lib_dir(parse_tool), "/"),
    FilePath =
        case os:type() of
            {_, linux} ->
                "/" ++ string:join(lists:sublist(Dir, length(Dir) - 2) ++ ["t_proto"], "/");
            _ ->
                string:join(lists:sublist(Dir, length(Dir) - 2) ++ ["t_proto"], "/")
        end,
    {ok, [_, _, _, {archive, ArchiveBin}]} = escript:extract(FilePath, [compile_source]),
    {ok, Files} = zip:foldl(fun(N, I, B, Acc) -> [{N, B(), I()} | Acc] end, [], {"t_proto", ArchiveBin}),
    Files.



get_tpl(File) when is_integer(hd(File)) ->
    FileSpec = get_files(),
    [Tpl] = [B || {N, B, _I} <- FileSpec, N =:= File],
    Tpl;

get_tpl(Files) ->
    FileSpec = get_files(),
    Fun =
        fun(File) ->
            [Tpl] = [B || {N, B, _I} <- FileSpec, N =:= File],
            Tpl
        end,
    lists:map(Fun, Files).