
rem change cd depending on where is your antlrworks source
rem this batch file generates the grammar files from g file
rem change the output directory as well -o
rem it generats plsql3_2_DLexer.d and plsql3_2_DParser.d
@rem d:
@rem cd D:\src\antlrworks-1.4_2

set p=%~dp0
@rem java org.antlr.Tool %p%\PLSQL3_2_D.g -o %p%\output 
%~d0
cd %p%
cd lib
java -classpath "%p%lib\antlr-3.4.jar;%p%lib\antlr-runtime-3.4.jar;%p%lib\ST4-4.0.4.jar" org.antlr.Tool %p%\PLSQL3_2_D.g -o %p%output

@echo done       