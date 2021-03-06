module runparser;

import antlr.runtime.ANTLRStringStream;
import antlr.runtime.ANTLRFileStream;
import antlr.runtime.CommonTokenStream;
//import tLexer,tParser;
import PLSQL3_2_DLexer,PLSQL3_2_DParser;
alias PLSQL3_2_DLexer tLexer;
alias PLSQL3_2_DParser tParser; 
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
   ins= new tParser.ANTLRNoCaseFileStream(args[1]);
}
  else
  ins= new ANTLRStringStream("12*(5-6)");
  auto lexer = new tLexer(ins);
  CommonTokenStream tokens = new CommonTokenStream(lexer);
  auto parser = new tParser(tokens);
 // static if (typeof(parser)==typeof(
  auto res=parser.start_rule();
   
  writeln("tree:");
  printTree(cast(CommonTree)res.getTree(),1);
}