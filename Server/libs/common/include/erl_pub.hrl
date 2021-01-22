%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 27. 四月 2016 下午2:05
%%%-------------------------------------------------------------------

-include("erl_keywords.hrl").
-include("erl_logger.hrl").
-include("erl_verify.hrl").
-include("erl_node.hrl").
-include("erl_db.hrl").
-include("../src/_auto/def/def.hrl").


-define(put_new(K, V), erlang:put(K, V)). %初始化进程字典，和erlang:put/2区分 开
-define(put(K, V), erlang:put(K, V)).
-define(get(K), erlang:get(K)).

-define(encode(Rfc4627Data), jsx:encode(Rfc4627Data)).
-define(decode(Rfc4627Data),
    case jsx:decode(Rfc4627Data) of
        {ok, {obj, Rfc4627Obj}, []} ->
            Rfc4627Obj;
        {ok, Rfc4627Obj, []} ->
            Rfc4627Obj;
        Rfc4627Obj -> Rfc4627Obj
    end).


-define(CHILD_S(ChildRegName, ChildMod, ChildType, ChildArg),
    {ChildRegName, {ChildMod, start_link, ChildArg}, permanent, 5000, ChildType, [ChildMod]}).
-define(CHILD_S(ChildMod, ChildType), ?CHILD_S(ChildMod, ChildMod, ChildType, [])).
-define(CHILD_S(ChildMod, ChildType, ChildArg), ?CHILD_S(ChildMod, ChildMod, ChildType, ChildArg)).