#语法解析工具
----
目前用来做前后端API文件配置，封装协议层，只用关心具体的逻辑层


## 支持功能

> * 1.根据配置文件t_yecc.yrl解析出token
> * 2.协议层的编解码。（基于http的json格式协议）
> * 3.简化erlang的宏定义


## 语法配置文件

> priv/t_yecc.yrl



## 如何使用
``` Makefile
    mkdir -p ./src/auto/proto
    mkdir -p ./src/auto/def
    escript deps/parse_tool/src_test/t_def.erl
    escript deps/parse_tool/src_test/t_proto.erl
```


## 问题

1.获取chunk，直接就获取到一个块的具体内容



## 第三版思路
> 1.生成token,不用按行来生成
>