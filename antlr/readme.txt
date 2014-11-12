Introduction

Antlr can generate parsers. This project provides the means to generate parsers in D. 
This project aims to be work with ANTLR 3.4.

The target is based on existing Java and C targets.

Meaning that the usage of D target is quite similar to Java target.
Many Java examples can be used with relatively little modifications.
Differences: In Java, you need to import org.antlr.runtime....
In D, you need to import antlr.runtime... in grammars. (no org)
Otherwise, the name of functions are the same, event the parameters.
Also, access of character in a string is simpler in D, a[i] unlike a.CharAt(i).



Installation

1. get antlr sources see http://www.antlr.org/download.html Current:http://www.antlr.org/download/antlr-3.3.tar.gz and unpack.
2. get antlrworks jar file, unpack it somewhere
3. from svn get the source, svn co https://antlrdtarget.svn.sourceforge.net/svnroot/antlrdtarget antlrdtarget
4. copy templates directory into extracted antlrworks antlr\codegen directory recursively
e.g. xcopy /S /Y templates\*   D:\src\antlrworks-1.4_3\org\antlr\codegen\templates\
5. make a g file set 
options {
	language=D; // this 
}

6. Generate D file in the ide or in command line
e.g.
d:
@rem next line should be the location antlrworks remember step 2.
cd D:\src\antlrworks-1.4_3

java org.antlr.Tool D:\grammars\pascal_D.g -o D:\projects\antlr\ 

two files will be generated  pascal_DLexer.d and pascal_DParser.d in D:\projects\antlr\

7. compile your project...
example... in a batch file
path=%path%;D:\standalone\dmd.2.053\dmd2\windows\bin
set runtime=D:\src\antlr-3.3\antlr-3.3\runtime\D\antlr\runtime
d:

D:\standalone\dmd.2.054\dmd2\windows\bin\dmd  -debug -ID:\src\antlr-3.3\antlr-3.3\runtime\D D:\m\antlr\backendd\runparser.d D:\m\antlr\pascal_DLexer.d D:\m\antlr\pascal_DParser.d -ofD:\projects\antlr\pascalparser.exe %runtime%\BaseRecognizer.d %runtime%\BaseRecognizerConnector.d %runtime%\BitSet.d %runtime%\CharStream.d %runtime%\CommonToken.d %runtime%\EarlyExitException.d %runtime%\FailedPredicateException.d %runtime%\IntStream.d %runtime%\JavaExceptions.d %runtime%\Lexer.d %runtime%\MismatchedNotSetException.d %runtime%\MismatchedRangeException.d %runtime%\MismatchedSetException.d %runtime%\MismatchedTokenException.d %runtime%\MismatchedTreeNodeException.d %runtime%\MissingTokenException.d %runtime%\NoViableAltException.d %runtime%\RecognitionException.d %runtime%\RecognizerSharedState.d %runtime%\Token.d %runtime%\TokenSource.d %runtime%\TokenStream.d %runtime%\UnwantedTokenException.d %runtime%\tree\BaseTree.d %runtime%\tree\CommonTree.d %runtime%\tree\Tree.d %runtime%\tree\TreeAdaptor.d %runtime%\tree\TreeNodeStream.d %runtime%\ANTLRStringStream.d %runtime%\CharStreamState.d  %runtime%\Parser.d %runtime%\CommonTokenStream.d %runtime%\BufferedTokenStream.d %runtime%\dfa.d %runtime%\RuleReturnScope.d %runtime%\tree\CommonTreeAdaptor.d %runtime%\tree\BaseTreeAdaptor.d  %runtime%\ParserRuleReturnScope.d  %runtime%\tree\CommonErrorNode.d  %runtime%\tree\RewriteRuleTokenStream.d %runtime%\tree\RewriteRuleSubtreeStream.d %runtime%\tree\RewriteRuleElementStream.d %runtime%\tree\RewriteCardinalityException.d %runtime%\tree\RewriteEmptyStreamException.d  %runtime%\ANTLRFileStream.d -debug=trace_consume -debug=antlrfilestream -debug=trace_rules

Remove debug=-s if you do not want to trace...

the contents of runparser.d
This sets up lexer, parser, executes them.
loads input from a filename given in command line.

module runparser;

import antlr.runtime.ANTLRStringStream;
import antlr.runtime.ANTLRFileStream;
import antlr.runtime.CommonTokenStream;

import pascal_DLexer,pascal_DParser;

import std.stdio;
import antlr.runtime.tree.CommonTree;
import std.array;

void printTree(CommonTree t, int indent) {

	if ( t ! is null ) {
		string sb ;
		for ( int i = 0; i < indent; i++ )
			sb ~= "   ";
                writeln(sb,"node:",t.token);
		for ( int i = 0; i < t.getChildCount(); i++ ) {
			//writeln(sb,t.getChild(i).toString());
			printTree(cast(CommonTree)t.getChild(i), indent+1);
		}
	}
}

void main(string[] args) 
{
  ANTLRStringStream ins;
  if (args.length>1)
  {
    writeln("arguments:",args[1]);
   ins= new ANTLRFileStream(args[1]);
  }
  else
  ins= new ANTLRStringStream("12*(5-6)");
  auto lexer = new pascal_DLexer(ins);
  CommonTokenStream tokens = new CommonTokenStream(lexer);
  auto parser = new pascal_DParser(tokens);
  auto res=parser.start_rule(); // this should be the name of start rule
  writeln("tree:");
  printTree(cast(CommonTree)res.getTree(),1);
}

8. run D:\projects\antlr\pascalparser.exe inputfile.txt

Authors of original targets:

Terence Parr of Java Target (D target is largely based on Java target)
Jim Idle of C Target

Converter, D target maker:
Marton Papp (hu dot freemail at anteusz ) <- reverse the order or read from right to left




