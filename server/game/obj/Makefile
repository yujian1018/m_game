
all:
	rm -rf ebin/
	make auto


def:
	rm -rf src/auto/def
	escript ../../lib/parse_tool/t_def ../etc/def/obj src/auto/def/


proto:
	rm -rf src/auto/proto
	escript ../../lib/parse_tool/t_proto ../etc/proto/obj src/auto/proto/ priv/docroot/api ../ex/etc/def/game_lib


mysql:
	rm -rf src/auto/load
	erl -pa ebin/ ../../apps/*/ebin ../../lib/*/ebin ../../_build/default/lib/*/ebin -config ../../config/db_127.0.0.1 -s tab_to_vo main -s erlang halt


auto:
	rm -rf src/auto
	make def
	make proto
	make mysql



