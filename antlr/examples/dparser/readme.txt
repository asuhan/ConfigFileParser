

About this example

This implements a D parser.
To generate the parser use generate_d.bat.In this case, read the readme.txt in the root as well.
To compile it use dparsercompile.bat.You will need to set the path of DMD in dcompilercompile.bat

Optionally, compile it with Apache Ant + Apache ivy. There are build.xml and ivy.xml supplied to help you in that.
Then enter ent in dparser directory. You will need to set the path of DMD in dcompilercompile.bat still.




You will need to modify those files, the paths inside them.

The grammar is described in dparser.g.
The grammar file itself is not perfect,  it does not match correct D syntax at all times.

The grammar file is complex enough to use it as a building block or pieces of it.


if you cannot wait, see the output dir.

the compiled parser is dparser.exe.

Run it as dparser.exe dfile.d


