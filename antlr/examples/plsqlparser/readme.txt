

About this example

It shows a Pl/Sql parser.
To generate the parser use generate_d.bat
To compile it use plsqlparsercompile.bat.

You will need to modify those files, the paths.

The grammar is described in PLSQL3_2_D.g.
The grammar file itself is not perfect,  it does not match correct Pl/Sql syntax at all times.
There is Java version of the grammar as well. It suffers from the same faults as PLSql one.
The grammar file is complex enough to use it as a building block or pieces of it.


if you cannot wait, see the output dir.

the compile parser is plsqlparser.exe.

Run it as plsqlparser.exe h.sql


