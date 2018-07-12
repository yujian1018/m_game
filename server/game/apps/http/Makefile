
all:
	rm -rf ebin/
	make auto


def:
	rm -rf src/auto/def
	escript ../../libs/parse_tool/t_def ../etc/def/http src/auto/def/


proto:
	rm -rf src/auto/proto
	escript ../../libs/parse_tool/t_proto ../etc/proto/http src/auto/proto/ priv/docroot/api ../etc/def/http


auto:
	make def
	make proto


