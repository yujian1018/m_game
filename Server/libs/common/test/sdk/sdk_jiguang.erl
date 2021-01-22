%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 02. 七月 2017 下午1:07
%%%-------------------------------------------------------------------
-module(sdk_jiguang).

-include("erl_pub.hrl").

-export([
    push/2
]).


-define(APP_KEY, <<"111">>).
-define(MASTER_SECRET, <<"22">>).

-define(URL, "https://api.jpush.cn/v3/push").

push(Uid, Alert) ->
%%    Cid = erl_bin:uuid_bin(),
    Post = <<"{
	\"platform\":\"all\",
	\"audience\":{
		 \"alias\" : [\"", Uid/binary, "\"]
	},
	\"notification\":{
		\"alert\":\"", Alert/binary, "\",
		\"android\":{\"extras\":{\"android-key1\":\"android-value1\"}},
		\"ios\":{\"sound\":\"sound.caf\",\"badge\":\"+1\",\"extras\":{\"ios-key1\":\"ios-value1\"}}
	},
	\"options\": {
        \"apns_production\": false
    }
}">>,
    Token = base64:encode(<<(?APP_KEY)/binary, ":", (?MASTER_SECRET)/binary>>),
    Header = [{"Authorization", "Basic " ++ binary_to_list(Token)}],
    case erl_httpc:post(?URL, Header, "application/json", Post) of
        {error, _} ->
            erl_httpc:post(?URL, Header, "application/json", Post);
        {ok, _Body} ->
            _Body
    end.
