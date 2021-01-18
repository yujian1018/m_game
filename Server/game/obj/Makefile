
all:
	rm -rf ebin/
	make auto


def:
	rm -rf src/auto/def
	escript ../libs/parse_tool/t_def ../etc/def/obj src/auto/def/


proto:
	rm -rf src/auto/proto
	escript ../libs/parse_tool/t_proto ../etc/proto/obj src/auto/proto/ priv/docroot/api ../ex/etc/def/game_lib


mysql:
	rm -rf src/auto/load
	erl -pa ebin/ ../apps/*/ebin ../libs/*/ebin ../ex/db/ebin  -config ../etc/conf/db_127.0.0.1 -s tab_to_vo main -s erlang halt


auto:
	rm -rf src/auto
	make def
	make proto
	make mysql



