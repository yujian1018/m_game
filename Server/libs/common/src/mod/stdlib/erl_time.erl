%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 15. 三月 2016 下午2:47
%%%-------------------------------------------------------------------
-module(erl_time).

-define(TIMES_START_DATE, 62167248000). %calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}})+3600*8.

-export([
    now/0, now_bin/0, m_now/0, now_month/0, now_week/0, zero_times/0,
    
    c_ms/0,
    
    times_in_month/1,
    
    times/0, times/1,
    
    localtime_to_now/1, sec_to_localtime/1,
    
    time2timer/1, timer2time/1,
    
    weekday/0, weekday/1,
    is_yesterday/3
]).

%% @doc 获取当前服务器时间的时间戳
now() -> times().
now_bin() -> integer_to_binary(times()).

%% GMT+8
zero_times() ->
    Times = times(),
    case erlang:time() of
        {0, 0, 0} ->
            Times;
        {H, M, S} ->
            Times - (3600 * H + 60 * M + S)
    end.

now_week() ->
    Week = weekday(),
    ZeroTime = zero_times(),
    ZeroTime - (Week - 1) * (60 * 60 * 24).

now_month() ->
    {Y, M, _D} = erlang:date(),
    calendar:datetime_to_gregorian_seconds({{Y, M, 1}, {0, 0, 0}}) - ?TIMES_START_DATE.

m_now() ->
    {MegaSec, Sec, MilliSec} = os:timestamp(),
    MegaSec * 1000000000 + Sec * 1000 + (MilliSec div 1000).

times() ->
    {MegaSec, Sec, _MilliSec} = os:timestamp(),
    MegaSec * 1000000 + Sec.


c_ms() ->
    {_MegaSec, _Sec, MilliSec} = os:timestamp(),
    MilliSec div 1000.


times(milli_seconds) ->
    {MegaSec, Sec, _MilliSec} = os:timestamp(),
    MegaSec * 1000000000 + Sec * 1000 + (_MilliSec div 1000);

times(micro_second) ->
    {MegaSec, Sec, _MilliSec} = os:timestamp(),
    MegaSec * 1000000000000 + Sec * 1000000 + _MilliSec.


sec_to_localtime(Times) ->
    MSec = Times div 1000000,
    Sec = Times - MSec * 1000000,
    calendar:now_to_local_time({MSec, Sec, 0}).


localtime_to_now({{Y, Mo, D}, {H, Mi, S}}) ->
    calendar:datetime_to_gregorian_seconds({{Y, Mo, D}, {H, Mi, S}}) - ?TIMES_START_DATE;
localtime_to_now({M, D}) ->
    {Y, _, _} = erlang:date(),
    calendar:datetime_to_gregorian_seconds({{Y, M, D}, {0, 0, 0}}) - ?TIMES_START_DATE.


%2016-07-19 00:00:00
time2timer(Time) ->
    [Y, M, D, H, Mi, S] = binary:split(Time, [<<"-">>, <<" ">>, <<":">>], [global]),
    localtime_to_now({{binary_to_integer(Y), binary_to_integer(M), binary_to_integer(D)}, {binary_to_integer(H), binary_to_integer(Mi), binary_to_integer(S)}}).

timer2time({{Y, Mo, D}, {H, Mi, S}}) ->
    Fun =
        fun(I) ->
            if
                I < 10 -> <<"0", (integer_to_binary(I))/binary>>;
                true -> integer_to_binary(I)
            end
        end,
    <<(Fun(Y))/binary, "-", (Fun(Mo))/binary, "-", (Fun(D))/binary, " ", (Fun(H))/binary, ":", (Fun(Mi))/binary, ":", (Fun(S))/binary>>.


times_in_month(Times) ->
    Date = erlang:date(),
    NowTimes = calendar:datetime_to_gregorian_seconds({Date, {0, 0, 0}}) - ?TIMES_START_DATE,
    if
        Times < NowTimes -> false;
        true -> true
    end.


weekday() -> calendar:day_of_the_week(erlang:date()).
weekday(Date) -> calendar:day_of_the_week(Date).

is_yesterday(RefreshTimes, _GMTOffset, ConfigTimes) ->
%%    DiffTime =
%%        if
%%            GMTOffset =:= undefined -> 0;
%%            true ->
%%                GMTOffset - 8 * 3600
%%        end,
    DiffTime = 0,
    if
        RefreshTimes =:= 0 orelse RefreshTimes =:= undefined ->
            erl_time:now() + DiffTime;
        true ->
            GMTZeroTime = ConfigTimes + DiffTime,
            if
                RefreshTimes >= GMTZeroTime -> false;
                true ->
                    erl_time:now() + DiffTime
            end
    end.