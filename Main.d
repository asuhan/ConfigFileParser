module runparser;

import antlr.runtime.ANTLRStringStream;
import antlr.runtime.ANTLRFileStream;
import antlr.runtime.CommonTokenStream;

import ConfigurationFileLexer, ConfigurationFileParser;

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
  auto lexer = new ConfigurationFileLexer(ins);
  CommonTokenStream tokens = new CommonTokenStream(lexer);
  auto parser = new ConfigurationFileParser(tokens);
  auto res=parser.configuration(); // this should be the name of start rule
  writeln("tree:");
  printTree(cast(CommonTree)res.getTree(),1);
}
