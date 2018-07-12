%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 02. 八月 2016 上午10:48
%%%-------------------------------------------------------------------
-module(t_http_login).

-include("t_pub.hrl").

-export([
    set_cookie/2,
    get_cookie/0
]).
-export([
    login/0
]).


login() ->
    Date = erl_time:now(),
    DateBin = integer_to_binary(Date),
    Sign = ?SIGN(Date),
    
    case get_cookie() of
        error ->
            ArgBin = cow_qs:qs([
                {<<"date">>, DateBin},
                {<<"sign">>, Sign},
                {<<"udid">>, erl_bin:uuid_bin()},
                {<<"channel_id">>, ?CHANNEL_ID},
                {<<"gmt_offset">>, integer_to_binary(3600 * 8)}
            ]),
            Url = binary_to_list(<<(?HTTP_ADDR)/binary, "login/guest/?", ArgBin/binary>>),
            ?INFO("login:~p~n", [Url]),
            {ok, Response} = erl_httpc:get(Url, []),
            {[{<<"code">>, CODE}, {<<"uin">>, UIN}, {<<"token">>, TOKEN}]} = ?decode(Response),
            if
                CODE =:= 200 ->
                    set_cookie(UIN, TOKEN),
                    {UIN, TOKEN};
                true ->
                    ?ERROR("get_server err url:~p...response:~p~n", [Url, Response]),
                    ?RETURN_ERR(?ERR_ARG_ERROR)
            end;
        {UIN, TOKEN} ->
            {UIN, TOKEN}
    end.


set_cookie(Uin, Token) ->
    file:write_file(".cache", <<"[{uin, ", (list_to_binary(Uin))/binary, "}, {token, <<\"", Token/binary, "\">>}].">>).


get_cookie() ->
    case file:consult(".cache") of
        {ok, Term} ->
            {_, Uin} = lists:keyfind(uin, 1, Term),
            {_, Token} = lists:keyfind(token, 1, Term),
            {Uin, Token};
        _ ->
            error
    end.