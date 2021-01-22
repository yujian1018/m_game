%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 02. 七月 2017 下午1:07
%%%-------------------------------------------------------------------
-module(sdk_baidu).

-include("erl_pub.hrl").

-export([
    geocoding/1
]).

-define(KEY, <<"111">>).


geocoding(Addr) ->
    NewAddr = cow_uri:urlencode(Addr),
    Url = binary_to_list(<<"http://api.map.baidu.com/geocoder/v2/?address=", NewAddr/binary, "&output=json&ak=", (?KEY)/binary, "">>),
    {ok, Ret} = erl_httpc:get(Url, []),
    {List} = jiffy:decode(Ret),
    case lists:keyfind(<<"status">>, 1, List) of
        {_, 0} ->
            {_, {Result}} = lists:keyfind(<<"result">>, 1, List),
            {_, {Location}} = lists:keyfind(<<"location">>, 1, Result),
            {_, Lng} = lists:keyfind(<<"lng">>, 1, Location),
            {_, Lat} = lists:keyfind(<<"lat">>, 1, Location),
            {float_to_binary(Lng), float_to_binary(Lat)};
        _ -> {<<"0.00">>, <<"0.00">>}
    end.