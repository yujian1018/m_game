%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 27. 七月 2016 下午1:33
%%%-------------------------------------------------------------------
-module(sdk_facebook).

-include("erl_pub.hrl").

-export([
    login/1
]).

-define(URL_LOGIN, <<"https://graph.facebook.com/v2.8/">>).

login(Arg) ->
    Account = list_can:exit_v_not_null(<<"open_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 facebook open_id"/utf8>>),
    Token = list_can:exit_v_not_null(<<"open_token">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 facebook token"/utf8>>),
%%    {Account, Token, {<<>>, <<"1">>, <<>>, <<>>}}.
    
    Url = <<?URL_LOGIN/binary, "me?fields=id%2Cname%2Cgender%2Clocale&access_token=", Token/binary>>,
    case erl_httpc:get(binary_to_list(Url), []) of
        {ok, Res} ->
            {Obj} = jiffy:encode(Res),
            case lists:keyfind("id", 1, Obj) of
                {_, OpenId} ->
                    case OpenId of
                        Account -> ok;
                        _ -> ?return_err(?ERR_ARG_ERROR)
                    end,
                    Name = list_can:get_arg("name", Obj),
                    Gender =
                        case list_can:get_arg("gender", Obj) of
                            <<"male">> -> <<"1">>;
                            _ -> <<"0">>
                        end,
                    Pic = <<"http://graph.facebook.com/", OpenId/binary, "/picture?type=large">>,
                    Address = list_can:get_arg("locale", Obj),
                    {Account, Token, {Name, Gender, Pic, Address}};
                _ ->
                    ?return_err(?ERR_SDK_ERR, <<"sdk_facebook登陆，平台验证失败"/utf8>>)
            end;
        _ -> ?return_err(?ERR_SDK_FAIL, <<"sdk_facebook登陆，平台验证网络超时"/utf8>>)
    end.
