
set compilerbin=D:\standalone\dmd.2.060\dmd2\windows\bin
path=%path%;%compilerbin%
set root=D:\src\antlr-3.3\antlr-3.3\runtime
set p=%~dp0
set runtime=%root%\D\antlr\runtime
d:

cd tmp


rem this is the only way I managed to compile it
rem -g causes an error at the moment with 2.060

%compilerbin%\dmd  -O -I%root%\D %p%runparser.d %p%output\PLSQL3_2_DLexer.d %p%output\PLSQL3_2_DParser.d -of%p%output\plsqlparser.exe %runtime%\BaseRecognizer.d %runtime%\BaseRecognizerConnector.d %runtime%\BitSet.d %runtime%\CharStream.d %runtime%\CommonToken.d %runtime%\EarlyExitException.d %runtime%\FailedPredicateException.d %runtime%\IntStream.d %runtime%\JavaExceptions.d %runtime%\Lexer.d %runtime%\MismatchedNotSetException.d %runtime%\MismatchedRangeException.d %runtime%\MismatchedSetException.d %runtime%\MismatchedTokenException.d %runtime%\MismatchedTreeNodeException.d %runtime%\MissingTokenException.d %runtime%\NoViableAltException.d %runtime%\RecognitionException.d %runtime%\RecognizerSharedState.d %runtime%\Token.d %runtime%\TokenSource.d %runtime%\TokenStream.d %runtime%\UnwantedTokenException.d %runtime%\tree\BaseTree.d %runtime%\tree\CommonTree.d %runtime%\tree\Tree.d %runtime%\tree\TreeAdaptor.d %runtime%\tree\TreeNodeStream.d %runtime%\ANTLRStringStream.d %runtime%\CharStreamState.d  %runtime%\Parser.d %runtime%\CommonTokenStream.d %runtime%\BufferedTokenStream.d %runtime%\dfa.d %runtime%\RuleReturnScope.d %runtime%\tree\CommonTreeAdaptor.d %runtime%\tree\BaseTreeAdaptor.d  %runtime%\ParserRuleReturnScope.d  %runtime%\tree\CommonErrorNode.d  %runtime%\tree\RewriteRuleTokenStream.d %runtime%\tree\RewriteRuleSubtreeStream.d %runtime%\tree\RewriteRuleElementStream.d %runtime%\tree\RewriteCardinalityException.d %runtime%\tree\RewriteEmptyStreamException.d  %runtime%\ANTLRFileStream.d 

@rem add this debug flags to trace the parsing

@rem -debug=trace_consume 
@rem -debug=antlrfilestream 
@rem -debug=trace_rules      rules
@rem -debug=tokenla          getting a token
@rem -debug=charla           getting a char
@rem -debug=memo             momoization
@rem -debug=dfa              the working of dfa

@echo done
 
