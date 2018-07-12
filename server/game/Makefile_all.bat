@echo off
::set Path=%CD%
::PATH C:\Program Files\erl8.2\bin

rd /q /s libs\common\ebin
rd /q /s libs\common\.rebar
rd /q /s libs\common\src\auto\def
escript.exe libs\parse_tool\t_def libs\common\priv\def libs\common\src\auto\def\


rd /q /s apps\game_lib\ebin
rd /q /s apps\game_lib\.rebar
rd /q /s apps\game_lib\src\auto\def
escript.exe libs\parse_tool\t_def apps\etc\def\game_lib apps\game_lib\src\auto\def\


rd /q /s apps\http\ebin
rd /q /s apps\http\src\auto
escript.exe libs\parse_tool\t_def apps\etc\def\http\ apps\http\src\auto\def\
escript.exe libs\parse_tool\t_proto apps\etc\proto\http apps\http\src\auto\proto\ apps\http\priv\docroot\api apps\etc\def\web_server


rd /q /s obj\ebin
rd /q /s obj\src\auto
escript.exe libs\parse_tool\t_def etc\def\obj obj\src\auto\def\
escript.exe libs\parse_tool\t_proto etc\proto\obj obj\src\auto\proto\


escript.exe rebar co
pause