@echo off


cd lib\parse_tool
escript.exe rebar compile
cd ../../

echo %cd%

rd /q /s lib\common\ebin
rd /q /s lib\common\.rebar
rd /q /s lib\common\src\auto\def
escript.exe lib\parse_tool\t_def lib\common\priv\def lib\common\src\auto\def\

cd lib\common
echo %cd%
escript.exe rebar compile
cd ../../
echo %cd%

rd /q /s apps\http\ebin
rd /q /s apps\http\src\auto
escript.exe lib\parse_tool\t_def config\def\http\ apps\http\src\auto\def\
escript.exe lib\parse_tool\t_proto config\proto\http apps\http\src\auto\proto\ apps\http\priv\docroot\api config\def\http


rd /q /s obj\ebin
rd /q /s obj\src\auto
escript.exe lib\parse_tool\t_def config\def\obj obj\src\auto\def\
escript.exe lib\parse_tool\t_proto config\proto\obj obj\src\auto\proto\ obj\priv\docroot\api config\def\obj


escript.exe rebar3 compile
pause