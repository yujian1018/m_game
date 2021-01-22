%%%-------------------------------------------------------------------
%%% @doc 自动生成，请不要手动编辑
%%%
%%%-------------------------------------------------------------------
-module({{MODULE}}).

-include_lib("cache/include/cache_mate.hrl").
-include("{{MODULE}}.hrl").
-include("obj_pub.hrl").


-export([load_data/1, save_data/1, del_data/1]).

-export([
    sql/1, exe_sql/1,
    data/1, to_record/2,
    lookup/1, lookup_record/1, lookup/2, lookup_db/2,
    insert/1, save_data_record/1
]).


load_cache() ->
    [
        #cache_mate{
            name = ?tab_name,
            key_pos = {{KEY_POS}}
        }
    ].


{{LOAD_DATA}}

{{SAVE_DATA}}

lookup_record(Uid) -> to_record(Uid, exe_sql(sql(Uid))).
del_data(Uid) -> cache:delete(?tab_name, Uid).
insert(Record) -> cache:insert(?tab_name, Record).
exe_sql(Sql) -> ?rpc_db_call(db_mysql, ed, [Sql]).

{{LOOKUP}}

{{TO_RECORD}}

{{TO_DATA}}
