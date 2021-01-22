
proto -> 'proto' char '=' integer  '{' client server '}'.
enum -> 'enum' atom_constant '{' line_constant '}'.

all_proto -> 'all_proto' '[' atom_constant_2 ']' '{' line_constant '}';
all_proto -> 'all_proto' '[' ']' '{' line_constant '}';
all_proto -> 'all_proto' '{' line_constant '}'.

client -> 'client' '{' '}';
client -> 'client' '{' atom_constant '}'.

server -> 'server' '{'  '}';
server -> 'server' '{' atom_constant '}'.

atom_constant -> atom;
atom_constant -> atom ':' type;
atom_constant -> atom ':' 'list' '<' '{' atom_constant_2 '}' '>';
atom_constant -> atom ':' '[' '{' atom_constant_2 '}' ']'.

line_constant -> char ':' type;
line_constant -> atom ':' type;
line_constant -> char '=' integer;
line_constant -> atom '=' integer;
line_constant -> char '=' integer ':' atom;
line_constant -> atom atom integer;
line_constant -> atom atom atom integer.

atom_constant_2 -> atom;
atom_constant_2 -> atom ':' type.

