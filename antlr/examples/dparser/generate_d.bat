
@rem change cd depending on where is your antlrworks source
@rem this batch file generates the grammar files from g file
@rem change the output directory as well -o
@rem it generats plsql3_2_DLexer.d and plsql3_2_DParser.d
@rem d:
@rem cd D:\src\antlrworks-1.4_2
@rem -verbose:class 
@rem ;%p%lib\ST4-4.0.4.jar
@set p=%~dp0

%~d0
cd %p%
cd lib
java -classpath "%p%lib\antlr-3.4.jar;%p%lib\antlr-runtime-3.4.jar;%p%lib\ST4-4.0.4.jar" org.antlr.Tool %p%\dparser.g -o %p%output
if %errorlevel% neq 0 exit /b %errorlevel%

@rem java -classpath "%p%lib\antlr-3.4-complete-no-antlrv2.jar" org.antlr.Tool %p%\dparser.g -o %p%\output


@rem java -classpath "d:\extracted\antlr3.4" org.antlr.Tool %p%\dparser.g -o %p%\output

@rem java -classpath "%p%lib\antlrworks-1.4.3.jar" org.antlr.Tool %p%\dparser.g -o %p%\output

@rem java -classpath "d:\extracted\antlrworks1.4.3" org.antlr.Tool %p%\dparser.g -o %p%\output
@d:
@cd D:\m\antlr\antlrdtarget\examples\dparser\lib
@rem java -classpath "D:\m\antlr\antlrdtarget\examples\dparser\lib\antlr-3.4-complete-no-antlrv2.jar" org.antlr.Tool %p%\dparser.g -o %p%\output



@rem java org.antlr.Tool %p%\dparser.g -o %p%\output
@echo done       