%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 八月 2017 下午2:44
%%%-------------------------------------------------------------------
-module(config_asset).

-include("obj_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").

-export([
    exit_attr/1, exit_item/1,
    get_attr_limit/1,
    get_item_limit/1, get_item_effect/1, is_item_expired/2

]).

-define(tab_name_1, config_attr).
-define(tab_name_2, config_item).


-record(config_attr, {
    attr_id,
    max
}).
-record(config_item, {
    item_id,
    max,
    type,
    use_limit,
    use_effect,
    is_acc,
    expires_type,
    expires
}).

load_cache() ->
    [
        #cache_mate{
            name = ?tab_name_1,
            record = #?tab_name_1{},
            fields = record_info(fields, ?tab_name_1)
        },
        #cache_mate{
            name = ?tab_name_2,
            record = #?tab_name_2{},
            fields = record_info(fields, ?tab_name_2),
            rewrite = fun rewrite_item/1
        }
    ].

rewrite_item(#config_item{use_limit = UseLimit, use_effect = UseEffect} = Config) ->
    Fun =
        fun(Bin) ->
            if
                Bin =:= <<>> -> [];
                true ->
                    {ok, Scan, _} = erl_scan:string(binary_to_list(Bin) ++ "."),
                    {ok, Term} = erl_parse:parse_term(Scan),
                    Term
            end
        end,
    Config#config_item{use_limit = Fun(UseLimit), use_effect = Fun(UseEffect)}.




exit_attr(AttrId) -> ets:member(?tab_name_1, AttrId).
exit_item(ItemId) -> ets:member(?tab_name_2, ItemId).


get_attr_limit(AttrId) ->
    case ets:lookup(?tab_name_1, AttrId) of
        [] -> -1;
        [#config_attr{max = Max}] -> Max
    end.


get_item_limit(ItemId) ->
    case ets:lookup(?tab_name_2, ItemId) of
        [] -> 0;
        [#config_item{max = MaxNum}] -> MaxNum
    end.

get_item_effect(ItemId) ->
    case ets:lookup(?tab_name_2, ItemId) of
        [] -> 0;
        [#config_item{use_limit = UseLimit, use_effect = Effect}] -> {UseLimit, Effect}
    end.

%% 是否过期 ?TRUE 过期
is_item_expired(ItemId, CTimes) ->
    case ets:lookup(?tab_name_2, ItemId) of
        [] -> ?TRUE;
        [#config_item{expires_type = ExpiresType, expires = Expires}] ->
            if
                ExpiresType =:= 0 -> ?FALSE;
                ExpiresType =:= 1 ->
                    Now = erl_time:now(),
                    if
                        (CTimes + Expires) < Now -> ?TRUE;
                        true -> ?FALSE
                    end;
                ExpiresType =:= 2 ->
                    Now = erl_time:now(),
                    if
                        Expires < Now -> ?TRUE;
                        true -> ?FALSE
                    end;
                ExpiresType =:= 3 ->
                    Now = erl_time:now(),
                    {Date, _} = erl_time:sec_to_localtime(CTimes),
                    ExpiresTime = erl_time:localtime_to_now({Date, {0, 0, 0}}) + 86400 + Expires,
                    if
                        ExpiresTime < Now -> ?TRUE;
                        true -> ?FALSE
                    end;
                ExpiresType =:= 4 ->
                    Now = erl_time:now(),
                    
                    {Date, _} = erl_time:sec_to_localtime(CTimes),
                    CTimes1 = CTimes - (erl_time:index_week(Date) * 86400),
                    {Date2, _} = erl_time:sec_to_localtime(CTimes1),
                    ExpiresTime = erl_time:localtime_to_now({Date2, {0, 0, 0}}) + 86400 * 7 + Expires,
                    if
                        ExpiresTime < Now -> ?TRUE;
                        true -> ?FALSE
                    end
            end
    end.

