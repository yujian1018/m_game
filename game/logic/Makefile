
all:
	rm -rf ebin/
	make auto


def:
	rm -rf src/_auto/def
	escript ../lib/parse_tool/t_def ../config/def/logic src/_auto/def/


proto:
	rm -rf src/_auto/proto
	escript ../lib/parse_tool/t_proto ../config/proto/logic src/_auto/proto/ priv/docroot/api ../config/def/logic


mysql:
	rm -rf src/_auto/db
	erl -pa ../lib/*/ebin ../../_build/default/lib/*/ebin -config ../../config/db_127.0.0.1 -s tab_to_vo main -s erlang halt


auto:
	rm -rf src/_auto
	make def
	make proto
	#make mysql



