
all:
	rm -rf ebin/
	make auto


def:
	rm -rf src/_auto/def
	escript ../lib/parse_tool/t_def ../config/def/http src/_auto/def/


proto:
	rm -rf src/_auto/proto
	escript ../lib/parse_tool/t_proto ../config/proto/http src/_auto/proto/ priv/docroot/api ../config/def/http


auto:
	make def
	make proto


