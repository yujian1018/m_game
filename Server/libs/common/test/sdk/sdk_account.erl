%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 27. 七月 2016 下午1:33
%%%-------------------------------------------------------------------
-module(sdk_account).

-export([login/1]).

-include("erl_pub.hrl").


-ifdef(prod).

-define(URL_LOGIN, <<"http://sdk.game2us.cn:450">>). %正式服
-define(CLIENT_ID, <<"111">>).
-define(CLIENT_SECRET, <<"222">>).

-else.

-define(URL_LOGIN, <<"http://sdk.game2us.cn:450">>).  %测试服
-define(CLIENT_ID, <<"111">>).
-define(CLIENT_SECRET, <<"222">>).

-endif.


login(Arg) ->
    Account = list_can:exit_v_not_null(<<"open_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 open_id"/utf8>>),
    Token = list_can:exit_v_not_null(<<"token">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 open_id"/utf8>>),
    UrlAccount = cow_uri:urlencode(Account),
    Url = <<?URL_LOGIN/binary, "/Login/loginForToken?account=", UrlAccount/binary, "&access_token=", Token/binary, "&client_secret=", (?CLIENT_SECRET)/binary>>,
    case erl_httpc:get(binary_to_list(Url), []) of
        {ok, Res} ->
            {Obj} = jiffy:decode(Res),
            case lists:keyfind("error_code", 1, Obj) of
                {_, 0} ->
                    OpenId2 = list_can:get_arg("error_msg", Obj),
                    {OpenId2, <<>>, {<<>>, <<"1">>, <<>>, <<>>}};
                _Other ->
                    ?WARN("error:~p~n", [_Other]),
                    ?return_err(?ERR_ACCOUNT_SDK_ERR, <<"账户登陆，平台验证失败"/utf8>>)
            end;
        _Other ->
            ?ERROR("url:~p~n", [[Url, _Other]]),
            ?return_err(?ERR_ACCOUNT_SDK_FAIL, <<"账户登陆，平台验证网络超时"/utf8>>)
    end.
