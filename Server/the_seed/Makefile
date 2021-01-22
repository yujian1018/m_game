
co:
	sed -i "s/%{d, dev}/{d, dev}/" rebar.config.script
	sed -i "s/%{d, prod}/{d, prod}/" rebar.config.script
	sed -i "s/{d, prod}/%{d, prod}/" rebar.config.script
	rebar3 compile

cl:
	rebar3 clean


rel:
	./st.sh release

st:
	./st.sh health 127.0.0.1 8080


prod:
	sed -i "s/%{d, dev}/{d, dev}/" rebar.config.script
	sed -i "s/{d, dev}/%{d, dev}/" rebar.config.script
	sed -i "s/%{d, prod}/{d, prod}/" rebar.config.script
	rebar3 compile

cl_prod:
	make cl
	make prod

# 编译 rebar3 compile
# 配置修改
# 数据准备 mnesia database文件
# 启动 erl -name health@127.0.0.1 -config config/sys -config .\config\health_127.0.0.1_8080.config  -args_file config/vm.args -args_file .\config\health_vm.args