%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 二月 2017 上午11:15
%%%-------------------------------------------------------------------


-define(return_err(ErrCode), erlang:throw({throw, ErrCode, <<>>})).
-define(return_err(ErrCode, Msg), erlang:throw({throw, ErrCode, Msg})).
-define(throw(ErrCode), {throw, ErrCode, <<>>}).
-define(throw(ErrCode, Msg), {throw, ErrCode, Msg}).

-define(assertEqual(Expect, ErrCode), if (Expect) =:= true -> ok;true -> erlang:throw({throw, ErrCode, <<>>}) end).
-define(assertEqual(Expect, ErrCode, ErrMsg), if (Expect) =:= true -> ok;true -> erlang:throw({throw, ErrCode, ErrMsg}) end).
