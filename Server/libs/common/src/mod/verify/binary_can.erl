%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 18. 七月 2016 上午9:17
%%%-------------------------------------------------------------------
-module(binary_can).

-include("erl_pub.hrl").

-export([
    % @doc 非法字符
    illegal/1, illegal_character/1, illegal_character/2,
    mask_word/1,        %屏蔽字符
    re_url/1,            %验证url
    
    is_binary/1,
    char2char/3,        %特殊符号替换
    
    max_len/3,  %字符数
    min_size/2, max_size/2, size/3  %字节数
]).


-define(ILLEGAL_CHARACTER, [<<"'">>, <<"`">>, <<";">>, <<"/*">>, <<"#">>, <<"--">>]).

illegal(Bin) when erlang:is_binary(Bin) ->
    case illegal_character(Bin, ?ILLEGAL_CHARACTER) of
        true -> Bin;
        false -> ?return_err(?ERR_ILLEGAL_CHATS)
    end;
illegal(Bin) -> Bin.


illegal_character(Binary) -> illegal_character(Binary, ?ILLEGAL_CHARACTER).
illegal_character(_K, []) -> true;
illegal_character(K, [Char | Chars]) ->
    case binary:match(K, Char) of
        nomatch -> illegal_character(K, Chars);
        _ -> false
    end.

mask_word(Binary) ->
    case cpn_mask_word:checkRes(Binary) of
        [_, false] -> Binary;
        [_, true] -> ?return_err(?ERR_SENSITIVE_CHARACTER)
    end.

is_binary(<<"">>) -> ?return_err(?ERR_NOT_BINARY);
is_binary(Binary) ->
    case erlang:is_binary(Binary) of
        true -> Binary;
        false -> ?return_err(?ERR_NOT_BINARY)
    end.


%% @doc 回车换行转义
char2char(Binary, Char1, Char2) ->
    binary:replace(Binary, Char1, Char2, [global]).


max_len(Bin, MaxSize, ErrMsg) ->
    BinLen = byte_size(Bin) + byte_size(<<<<I>> || <<I>> <= Bin, I < 128>>) * 2,
    if
        BinLen > MaxSize -> ?return_err(?ERR_MAX_SIZE, [[<<"?ERR_MAX_SIZE">>, MaxSize div 3], [<<"?KEY">>, ErrMsg]]);
        true -> ok
    end.


max_size(Bin, MaxSize) ->
    BinSize = byte_size(Bin),
    if
        BinSize > MaxSize -> ?return_err(?ERR_MAX_SIZE);
        true -> ok
    end.


min_size(Bin, MinSize) ->
    BinSize = byte_size(Bin),
    if
        BinSize =< MinSize -> ?return_err(?ERR_MIN_SIZE);
        true -> ok
    end.


size(Bin, MinSize, MaxSize) ->
    BinSize = byte_size(Bin),
    if
        MinSize =< BinSize andalso BinSize =< MaxSize -> ok;
        true -> ?return_err(?ERR_NOT_IN_SIZE)
    end.


re_url(Binary) ->
    B1 = binary:replace(Binary, <<" ">>, <<"">>, [global]),
    [B2, _] = cpn_mask_word:checkRes(B1, <<"www\.[a-zA-Z0-9\-_]+\."/utf8>>),
    hd(cpn_mask_word:checkRes(B2, <<"\.[a-zA-Z0-9\-_]+\.(com|cn|net|xin|ltd|store|vip|cc|game|mom|lol|work|pub|club|club|xyz|top|ren|bid|loan|red|biz|mobi|me|win|link|wang|date|party|site|online|tech|website|space|live|studio|press|news|video|click|trade|science|wiki|design|pics|photo|help|gitf|rocks|org|band|market|sotfware|social|lawyer|engineer|gov.cn|name|info|tv|asia|co|so|中国|公司|网络)"/utf8>>)).
