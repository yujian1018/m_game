%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 29. 十二月 2016 上午11:39
%%%-------------------------------------------------------------------
-module(erl_file).

-include("erl_pub.hrl").

-export([
    get_mods/2,
    is_behaviour/2,
    read_file/2,
    dirs/1,
    max_file/3, new_file/3
]).


get_mods(AppName, Behaviour) ->
    case code:lib_dir(AppName, ebin) of
        {error, _Err} -> ?ERROR("no app:~p~n", [AppName]), [];
        Pwd ->
            {ok, FileNames} = file:list_dir(Pwd),
            lists:foldl(
                fun(FileName, ModAcc) ->
                    case lists:reverse(FileName) of
                        "maeb." ++ R ->
                            Mod = list_to_atom(lists:reverse(R)),
                            case is_behaviour(Mod, Behaviour) of
                                true -> [Mod | ModAcc];
                                false -> ModAcc
                            end;
                        _R -> ModAcc
                    end
                end,
                [],
                FileNames)
    end.


is_behaviour(Mod, Behaviour) ->
    lists:member({behaviour, [Behaviour]}, Mod:module_info(attributes)).


read_file(AppName, File) ->
    Pwd = code:lib_dir(AppName),
    {ok, Bin} = file:read_file(Pwd ++ File),
    Bin.


dirs(Dir) -> dirs1(filename:split(Dir), "", []).
dirs1([], _, Acc) -> lists:reverse(Acc);
dirs1([H | T], "", []) -> dirs1(T, H, [H]);
dirs1([H | T], Last, Acc) ->
    Dir = filename:join(Last, H),
    dirs1(T, Dir, [Dir | Acc]).


%% 1.根据文件模板，查找出最后一个文件
%% 2.根据判断size，判断是否新建
max_file(Path, FileTpl, MaxSize) ->
    FileTplTokens = string:tokens(FileTpl, "."),
    case string:to_integer(lists:last(FileTplTokens)) of
        {_Int, []} -> ok;
        _ -> ?return_err(?ERR_ARG_ERROR, <<"模板名称错误"/utf8>>)
    end,
    Len = length(FileTplTokens) - 1,
    HeadTpl = lists:sublist(FileTplTokens, 1, Len),
    FileTpls =
        case file:list_dir(Path) of
            {ok, []} -> [];
            {ok, Files} ->
                lists:foldl(
                    fun(I, Acc) ->
                        FileTokens = string:tokens(I, "."),
                        case lists:sublist(FileTokens, 1, Len) of
                            HeadTpl -> [{list_to_integer(lists:last(FileTokens)), I} | Acc];
                            _ -> Acc
                        end
                    end,
                    [],
                    Files)
        end,
    case FileTpls of
        [] -> {FileTpl, 0};
        FileTpls ->
            {_, FileName} = lists:max(FileTpls),
            {ok, FileInfo} = file:read_file_info(filename:join(Path, FileName)),
            Size = element(2, FileInfo),
            new_file(FileName, Size, MaxSize)
    end.


new_file(File, Size, MaxSize) ->
    if
        Size >= MaxSize ->
            FileToken = string:tokens(File, "."),
            Index = list_to_integer(lists:last(FileToken)),
            File1 = lists:flatten([I ++ "." || I <- lists:sublist(FileToken, 1, length(FileToken) - 1)]),
            {File1 ++ integer_to_list(Index + 1), 0};
        true -> {File, Size}
    end.