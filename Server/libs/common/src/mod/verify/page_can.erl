%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 17. 十二月 2016 下午1:28
%%%-------------------------------------------------------------------
-module(page_can).

-include("erl_pub.hrl").

-export([
    size/3,
    page_index/3,
    index/3
]).

size(Page, PageSize, MaxPage) ->
    case erlang:is_integer(Page) of
        true ->
            if
                Page =< 0 -> ?return_err(?ERR_PAGE_SIZE_ERR);
                Page > MaxPage -> ?return_err(?ERR_PAGE_MAX_SIZE);
                true ->
                    SIndex = (Page - 1) * PageSize + 1,
                    {SIndex, PageSize}
            end;
        _ ->
            ?return_err(?ERR_INVALID_INTEGER)
    end.

page_index(Page, PageSize, MaxPage) ->
    case erlang:is_integer(PageSize) of
        true ->
            if
                Page =< 0 -> ?return_err(?ERR_PAGE_SIZE_ERR);
                Page > MaxPage -> ?return_err(?ERR_PAGE_MAX_SIZE);
                true ->
                    SIndex = (Page - 1) * PageSize,
                    EIndex = Page * PageSize - 1,
                    {SIndex, EIndex}
            end;
        _ ->
            ?return_err(?ERR_INVALID_INTEGER)
    end.

index(CPageIndex, PageSize, MaxPage) ->
    case erlang:is_integer(CPageIndex) of
        true ->
            if
                PageSize * MaxPage > CPageIndex + PageSize -> {CPageIndex, PageSize};
                PageSize * MaxPage > CPageIndex -> {CPageIndex, PageSize * MaxPage - CPageIndex};
                true -> ?return_err(?ERR_PAGE_MAX_SIZE)
            end;
        _ ->
            ?return_err(?ERR_INVALID_INTEGER)
    end.