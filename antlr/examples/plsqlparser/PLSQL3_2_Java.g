/*******************************************************************************

DESCRIPTION:
		Oracle PL/SQL Grammar for ANTLR v3, target language C#
AUTHOR:
		Andrey Kharitonkin (thikone@gmail.com)
DATE:
		02-Jan-2008
BASED ON:
		PLSQLGrammar.g for ANTLR v2
		Qazi Firdous Ahmed (qazif_ahmed@infosys.com) 
		Krupa Benhur (krupa_bg@infosys.com)
		Manojaba Banerjee (manojaba_banerjee@infosys.com)
		Infosys Technologies Ltd., Bangalore, India
		Sept 18, 2002
		This grammar is for PL/SQL.
COMMENT:
		The grammar has been mostly re-written for ANTLR v3,
		using Oracle 10g Release 2 documentation and ANTLR book.
		New SQL and PL/SQL expression rules, SQL statments
		SELECT, INSERT, UPDATE, DELETE are fully supported.
		Generated parser can parse most of valid PL/SQL and 
		it was tested with over 10 Mb of test source code.
		Let me know if something cannot be parsed by this grammar.
KNOWN ISSUES:
		At the moment only supports CREATE PACKAGE and PACKAGE BODY.
		Symbol table and gate predicates needed to distinguish
			between function call and variable usage.

It was fun learning ANTLR3 and creating this grammar, hope you enjoy it as well!

*******************************************************************************/

grammar PLSQL3_2_Java;

options {
	language=Java;
	backtrack=true;
	memoize=true;
	output=AST;
}

/*@members {
    
}*/

@parser::includes
{
void myDisplayRecognitionError (BaseRecognizer recognizer,
pANTLR3_UINT8 * tokenNames) ;
}

@parser::apifuncs {
	RECOGNIZER.displayRecognitionError = myDisplayRecognitionError;
}


@imports
{

import antlr.runtime.ANTLRFileStream;
import std.ascii;
}

@header
{
import java.util.*;
import java.io.*;
import antlr.collections.AST;
import antlr.collections.impl.*;
import antlr.debug.misc.*;
import antlr.*;
import org.antlr.runtime.CharStream;
import org.antlr.runtime.Parser;
import org.antlr.runtime.BitSet;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.Token;
import org.antlr.runtime.TokenStream;
import org.antlr.runtime.NoViableAltException;
}


@members
{

    boolean is_sql = false;
    boolean is_sqlplus = false;
    static public class ANTLRNoCaseFileStream  extends ANTLRFileStream {
        public ANTLRNoCaseFileStream(String fileName) throws IOException {
            super(fileName, null);
        }

        public ANTLRNoCaseFileStream(String fileName, String encoding) throws IOException
         {
            super(fileName, encoding);
        }

        public int LA(int i) {
            if ( i==0 ) {
                return 0; // undefined
            }
            if ( i<0 ) {
                i++; // e.g., translate LA(-1) to use offset 0
            }

            if ( (p+i-1) >= n ) {

                return CharStream.EOF;
            }
            return Character.toUpperCase(data[p+i-1]);
        }
    }

}
/*void			
myDisplayRecognitionError	    (pANTLR3_BASE_RECOGNIZER recognizer, pANTLR3_UINT8 * tokenNames)
{
	pANTLR3_PARSER			parser;
	pANTLR3_TREE_PARSER	    tparser;
	pANTLR3_INT_STREAM	    is;
	pANTLR3_STRING			ttext;
	pANTLR3_STRING			ftext;
	pANTLR3_EXCEPTION	    ex;
	pANTLR3_COMMON_TOKEN    theToken;
	pANTLR3_BASE_TREE	    theBaseTree;
	pANTLR3_COMMON_TREE	    theCommonTree;

	// Retrieve some info for easy reading.
	//
	ex	    =		recognizer.state.exception;
	ttext   =		NULL;

	// See if there is a 'filename' we can use
	//
	if	(ex.streamName == NULL)
	{
		if	(((pANTLR3_COMMON_TOKEN)(ex.token)).type == ANTLR3_TOKEN_EOF)
		{
			ANTLR3_FPRINTF(stderr, "-end of input-(");
		}
		else
		{
			ANTLR3_FPRINTF(stderr, "-unknown source-(");
		}
	}
	else
	{
		ftext = ex.streamName.to8(ex.streamName);
		ANTLR3_FPRINTF(stderr, "\%s ", ftext.chars);
	}

	// Next comes the line number
	//

	ANTLR3_FPRINTF(stderr, "line \%d col \%d ", recognizer.state.exception.line,recognizer.state.exception.charPositionInLine);
	//ANTLR3_FPRINTF(stderr, " : error \%d : \%s", 
	//									recognizer.state.exception.type,
	//				(pANTLR3_UINT8)	   (recognizer.state.exception.message));


	// How we determine the next piece is dependent on which thing raised the
	// error.
	//
	switch	(recognizer.type)
	{
	case	ANTLR3_TYPE_PARSER:

		// Prepare the knowledge we know we have
		//
		parser	    = (pANTLR3_PARSER) (recognizer.super);
		tparser	    = NULL;
		is			= parser.tstream.istream;
		theToken    = (pANTLR3_COMMON_TOKEN)(recognizer.state.exception.token);
		//ttext	    = theToken.toString(theToken);
                ttext	    =theToken.getText(theToken);
		//ANTLR3_FPRINTF(stderr, ", at offset \%d", recognizer.state.exception.charPositionInLine);
		if  (theToken != NULL)
		{
			if (theToken.type == ANTLR3_TOKEN_EOF)
			{
				ANTLR3_FPRINTF(stderr, ", at the end of file");
			}
			else
			{
				// Guard against null text in a token
				//
				ANTLR3_FPRINTF(stderr, "\n    near \%s\n    ", ttext == NULL ? (pANTLR3_UINT8)"<no text for the token>" : ttext.chars);
			}
		}
		break;

	case	ANTLR3_TYPE_TREE_PARSER:

		tparser		= (pANTLR3_TREE_PARSER) (recognizer.super);
		parser		= NULL;
		is			= tparser.ctnstream.tnstream.istream;
		theBaseTree	= (pANTLR3_BASE_TREE)(recognizer.state.exception.token);
		ttext		= theBaseTree.toStringTree(theBaseTree);

		if  (theBaseTree != NULL)
		{
			theCommonTree	= (pANTLR3_COMMON_TREE)	    theBaseTree.super;

			if	(theCommonTree != NULL)
			{
				theToken	= (pANTLR3_COMMON_TOKEN)    theBaseTree.getToken(theBaseTree);
			}
			ANTLR3_FPRINTF(stderr, ", at offset \%d", theBaseTree.getCharPositionInLine(theBaseTree));
			ANTLR3_FPRINTF(stderr, ", near \%s", ttext.chars);
		}
		break;

	default:

		ANTLR3_FPRINTF(stderr, "Base recognizer function displayRecognitionError called by unknown parser type - provide override for this function\n");
		return;
		break;
	}

	// Although this function should generally be provided by the implementation, this one
	// should be as helpful as possible for grammar developers and serve as an example
	// of what you can do with each exception type. In general, when you make up your
	// 'real' handler, you should debug the routine with all possible errors you expect
	// which will then let you be as specific as possible about all circumstances.
	//
	// Note that in the general case, errors thrown by tree parsers indicate a problem
	// with the output of the parser or with the tree grammar itself. The job of the parser
	// is to produce a perfect (in traversal terms) syntactically correct tree, so errors
	// at that stage should really be semantic errors that your own code determines and handles
	// in whatever way is appropriate.
	//
	switch  (ex.type)
	{
	case	ANTLR3_UNWANTED_TOKEN_EXCEPTION:

		// Indicates that the recognizer was fed a token which seesm to be
		// spurious input. We can detect this when the token that follows
		// this unwanted token would normally be part of the syntactically
		// correct stream. Then we can see that the token we are looking at
		// is just something that should not be there and throw this exception.
		//
		if	(tokenNames == NULL)
		{
			ANTLR3_FPRINTF(stderr, " : Extra code...");
		}
		else
		{
			if	(ex.expecting == ANTLR3_TOKEN_EOF)
			{
				ANTLR3_FPRINTF(stderr, " : Extra code - expected <EOF>\n");
			}
			else
			{
				ANTLR3_FPRINTF(stderr, " : Extra code - expected \%s ...\n", tokenNames[ex.expecting]);
			}
		}
		break;

	case	ANTLR3_MISSING_TOKEN_EXCEPTION:

		// Indicates that the recognizer detected that the token we just
		// hit would be valid syntactically if preceeded by a particular 
		// token. Perhaps a missing ';' at line end or a missing ',' in an
		// expression list, and such like.
		//
		if	(tokenNames == NULL)
		{
			ANTLR3_FPRINTF(stderr, " : Missing token (\%d)...\n", ex.expecting);
		}
		else
		{
			if	(ex.expecting == ANTLR3_TOKEN_EOF)
			{
				ANTLR3_FPRINTF(stderr, " : expecing the end of file\n");
			}
			else
			{
				ANTLR3_FPRINTF(stderr, " : Missing \%s \n", tokenNames[ex.expecting]);
			}
		}
		break;

	case	ANTLR3_RECOGNITION_EXCEPTION:

		// Indicates that the recognizer received a token
		// in the input that was not predicted. This is the basic exception type 
		// from which all others are derived. So we assume it was a syntax error.
		// You may get this if there are not more tokens and more are needed
		// to complete a parse for instance.
		//
		ANTLR3_FPRINTF(stderr, " : syntax error...\n");    
		break;

	case    ANTLR3_MISMATCHED_TOKEN_EXCEPTION:

		// We were expecting to see one thing and got another. This is the
		// most common error if we coudl not detect a missing or unwanted token.
		// Here you can spend your efforts to
		// derive more useful error messages based on the expected
		// token set and the last token and so on. The error following
		// bitmaps do a good job of reducing the set that we were looking
		// for down to something small. Knowing what you are parsing may be
		// able to allow you to be even more specific about an error.
		//
		if	(tokenNames == NULL)
		{
			ANTLR3_FPRINTF(stderr, " : syntax error...\n");
		}
		else
		{
			if	(ex.expecting == ANTLR3_TOKEN_EOF)
			{
				ANTLR3_FPRINTF(stderr, " : expected <EOF>\n");
			}
			else
			{
				ANTLR3_FPRINTF(stderr, " : expected \%s ...\n", tokenNames[ex.expecting]);
			}
		}
		break;

	case	ANTLR3_NO_VIABLE_ALT_EXCEPTION:

		// We could not pick any alt decision from the input given
		// so god knows what happened - however when you examine your grammar,
		// you should. It means that at the point where the current token occurred
		// that the DFA indicates nowhere to go from here.
		//
		//ANTLR3_FPRINTF(stderr, " : cannot match to any predicted input...\n");
                ANTLR3_FPRINTF(stderr, " : unknown syntax...\n");

		break;

	case	ANTLR3_MISMATCHED_SET_EXCEPTION:

		{
			ANTLR3_UINT32	  count;
			ANTLR3_UINT32	  bit;
			ANTLR3_UINT32	  size;
			ANTLR3_UINT32	  numbits;
			pANTLR3_BITSET	  errBits;

			// This means we were able to deal with one of a set of
			// possible tokens at this point, but we did not see any
			// member of that set.
			//
			ANTLR3_FPRINTF(stderr, " : unexpected input...\n  expected one of : ");

			// What tokens could we have accepted at this point in the
			// parse?
			//
			count   = 0;
			errBits = antlr3BitsetLoad		(ex.expectingSet);
			numbits = errBits.numBits		(errBits);
			size    = errBits.size			(errBits);

			if  (size > 0)
			{
				// However many tokens we could have dealt with here, it is usually
				// not useful to print ALL of the set here. I arbitrarily chose 8
				// here, but you should do whatever makes sense for you of course.
				// No token number 0, so look for bit 1 and on.
				//
				for	(bit = 1; bit < numbits && count < 8 && count < size; bit++)
				{
					// TODO: This doesn;t look right - should be asking if the bit is set!!
					//
					if  (tokenNames[bit])
					{
						ANTLR3_FPRINTF(stderr, "\%s\%s", count > 0 ? ", " : "", tokenNames[bit]); 
						count++;
					}
				}
				ANTLR3_FPRINTF(stderr, "\n");
			}
			else
			{
				ANTLR3_FPRINTF(stderr, "Actually dude, we didn't seem to be expecting anything here, or at least\n");
				ANTLR3_FPRINTF(stderr, "I could not work out what I was expecting, like so many of us these days!\n");
			}
		}
		break;

	case	ANTLR3_EARLY_EXIT_EXCEPTION:

		// We entered a loop requiring a number of token sequences
		// but found a token that ended that sequence earlier than
		// we should have done.
		//
		ANTLR3_FPRINTF(stderr, " : missing elements...\n");
		break;

	default:

		// We don't handle any other exceptions here, but you can
		// if you wish. If we get an exception that hits this point
		// then we are just going to report what we know about the
		// token.
		//
		ANTLR3_FPRINTF(stderr, " : syntax not recognized...\n");
		break;
	}

	// Here you have the token that was in error which if this is
	// the standard implementation will tell you the line and offset
	// and also record the address of the start of the line in the
	// input stream. You could therefore print the source line and so on.
	// Generally though, I would expect that your lexer/parser will keep
	// its own map of lines and source pointers or whatever as there
	// are a lot of specific things you need to know about the input
	// to do something like that.
	// Here is where you do it though :-).
	//
}*/





start_rule
	:   (	(create_package DIVIDE?)
	       | (plsql_block SEMI DIVIDE?) 
               | sql_plus
           )* EOF
	;
	
sql_plus:	('ACC'| 'ACCEPT') variable ('NUM'|'NUMBER' | 'CHAR' | 'DATE' | 'BINARY_FLOAT' | 'BINARY_DOUBLE')? 
                (('FOR'|'FORMAT') format)? (('DEF'|'DEFAULT') defaultvalue)? ('PROMPT' text|('NOPR'|'NOPROMPT'))? 'HIDE'?;



variable:	identifier;
format	: QUOTED_STRING;
defaultvalue : QUOTED_STRING;
text 	: QUOTED_STRING;	

//SINGLE_QUOTE_SQLPLUS  @init { is_sqlplus = true; }
//	:	
//	QUOTED_STRING;
//	: ( 'n' )? '\'' ( '\'\'' | ~('\'') )* '\'';	

create_package @init { is_sqlplus = false; }
	:	'CREATE' ( 'OR' keyREPLACE )?
		( package_spec | package_body )
	;
	
package_spec
	:	keyPACKAGE package_name ( 'IS' | 'AS' ) 
		( package_obj_spec )*
		'END' (package_name)? SEMI
	;
	
package_body
	:	keyPACKAGE ( keyBODY ) package_name ( 'IS' | 'AS' )
		( package_obj_body )*
		( 'BEGIN' seq_of_statements )?  
		'END' ( package_name )? SEMI
	;

package_name
	:	( schema_name DOT )? identifier 
	;

package_obj_spec
	:	variable_declaration 
	|	type_declaration
	|	subtype_declaration 
	|	record_declaration 
	|	plsql_table_declaration 
	|	varray_declaration
	|	cursor_declaration 
	|	cursor_spec 
	|	procedure_spec 
	|	function_spec 
	|	exception_declaration 
	|	pragma_declaration
	;

variable_declaration
	:	variable_name ('CONSTANT')?
		type_spec ('NOT' 'NULL')? 
		( ( ASSIGN | 'DEFAULT' ) plsql_expression)? SEMI
	;	

type_declaration 
	:	keyTYPE type_spec 'IS' ( keyNEW )? ( type_spec ( 'NOT' 'NULL' )? | LPAREN plsql_expressions RPAREN ) SEMI
	;	

subtype_declaration 
	:	keySUBTYPE type_spec 'IS' type_spec ( 'NOT' 'NULL' | keyRANGE literal DOUBLEDOT literal )? SEMI
	;	
	
cursor_declaration
	:	keyCURSOR cursor_name
		( LPAREN parameter_specs RPAREN )?
		'IS' select_command SEMI
	;
package_obj_body
	:	variable_declaration 
	|	subtype_declaration 
	|	cursor_declaration 
	|	exception_declaration 
	|	record_declaration 
	|	plsql_table_declaration 
	|	varray_declaration
	|	procedure_body 
	|	function_body 
	|	pragma_declaration
	;

seq_of_statements
	:	statement SEMI ( statement SEMI )*
	;
	
statement
	:	assignment_statement
	|	exit_statement
	|	goto_statement
	|	case_statement
	|	if_statement 
	|	loop_statement 
	|	null_statement
	|	raise_statement
	|	return_statement
	|	sql_statement
	|	plsql_block
//	|	begin_block
	|	function_call
	;
		
plsql_block  @init { is_sqlplus = false; }
	:	( LLABEL label_name RLABEL )?
		( ( 'DECLARE' )? (declare_spec)+ )? 
		( 'BEGIN' )
		seq_of_statements
		( 'EXCEPTION' ( exception_handler )+ )? 
		( 'END' ( label_name )? )
	;

declare_spec
	:	variable_declaration 
	|	subtype_declaration 
	|	cursor_declaration 
	|	exception_declaration 
	|	record_declaration 
	|	plsql_table_declaration 
	|	varray_declaration
	|	procedure_declaration 
	|	function_declaration
	|	type_declaration 
	|	pragma_declaration
	;

pragma_declaration
	:	keyPRAGMA 
		(	keyRESTRICT_REFERENCES LPAREN ( 'DEFAULT' | function_name ) ( COMMA pragma_param )+ RPAREN 
		|	keyEXCEPTION_INIT LPAREN exception_name COMMA literal RPAREN
		|	keyAUTONOMOUS_TRANSACTION
		|	keySERIALLY_REUSABLE
		|	keyBUILTIN LPAREN pragma_params RPAREN
		|	keyFIPSFLAG LPAREN pragma_params RPAREN
		|	keyINTERFACE LPAREN pragma_params RPAREN
		|	keyNEW_NAMES LPAREN pragma_params RPAREN
		|	keyTIMESTAMP LPAREN pragma_params RPAREN
		)
		SEMI
	;

pragma_params
	:	pragma_param ( COMMA pragma_param )*
	;

pragma_param
	:	( PLUS | MINUS )? NUMBER
	|	QUOTED_STRING
	|	identifier
	;

assignment_statement
	:	//(lvalue ASSIGN function_call) => (lvalue ASSIGN function_call)
//	|	(lvalue ASSIGN plsql_expression)  => 
		(lvalue ASSIGN plsql_expression)
//	|	function_call
	;
lvalues
	:	lvalue ( COMMA lvalue )*
	;
lvalue
	:	variable_name
	|	record_name DOT field_name
	|	plsql_table_name LPAREN subscript RPAREN ( DOT field_name )*
	|	COLON host_variable ( COLON host_variable )?
	;

field_name
	:	identifier
	;
	
subscript
	:	plsql_expression 
	;
	
host_variable
	:	identifier
	;
	
goto_statement
	:	'GOTO' label_name
	;
	
label_name
	:	identifier
	;	

exit_statement
	:	keyEXIT ( label_name )? ( 'WHEN' plsql_condition )?
	;
	
datatype
	:	'BINARY_INTEGER' 
	|	'BINARY_FLOAT'
	|	'BINARY_DOUBLE'
	|	'NATURAL' 
	|	'POSITIVE' 
	|	( 'NUMBER' | 'NUMERIC' | 'DECIMAL' | 'DEC' ) ( LPAREN NUMBER ( COMMA NUMBER )? RPAREN )?
	|	'LONG' ( 'RAW')? ( LPAREN NUMBER RPAREN )?
	|	'RAW' ( LPAREN NUMBER RPAREN )?
	|	'BOOLEAN'
	|	'DATE'
	|	keyINTERVAL keyDAY ( LPAREN NUMBER RPAREN )? 'TO' keySECOND ( LPAREN NUMBER RPAREN )?
	|	keyINTERVAL keyYEAR ( LPAREN NUMBER RPAREN )? 'TO' keyMONTH
	|	( keyTIME | keyTIMESTAMP ) ( LPAREN NUMBER RPAREN )? ( 'WITH' ( keyLOCAL )? keyTIME keyZONE)?
	|	'INTEGER'
	|	'INT'
	|	'SMALLINT'
	|	'FLOAT' ( LPAREN NUMBER RPAREN )?
	|	'REAL'
	|	'DOUBLE' keyPRECISION
	|	'CHAR'      ( keyVARYING )? ( LPAREN NUMBER ( keyBYTE | 'CHAR' )? RPAREN )? ( 'CHARACTER' 'SET' ( identifier | column_spec CHARSET_ATTR ) )?
	|	'VARCHAR'                   ( LPAREN NUMBER ( keyBYTE | 'CHAR' )? RPAREN )? ( 'CHARACTER' 'SET' ( identifier | column_spec CHARSET_ATTR ) )?
	|	'VARCHAR2'                  ( LPAREN NUMBER ( keyBYTE | 'CHAR' )? RPAREN )? ( 'CHARACTER' 'SET' ( identifier | column_spec CHARSET_ATTR ) )?
	|	'CHARACTER' ( keyVARYING )? ( LPAREN NUMBER RPAREN )?
	|	'NCHAR'     ( keyVARYING )? ( LPAREN NUMBER RPAREN )?
	|	'NVARCHAR'  ( LPAREN NUMBER RPAREN )?
	|	'NVARCHAR2' ( LPAREN NUMBER RPAREN )?
	|	'NATIONAL'  ( 'CHARACTER' | 'CHAR' ) ( keyVARYING )? ( LPAREN NUMBER RPAREN )?
	|	'MLSLABEL'
	|	'PLS_INTEGER'
	|	'BLOB'
	|	'CLOB' ( 'CHARACTER' 'SET' ( identifier | column_spec CHARSET_ATTR ) )?
	|	'NCLOB'
	|	'BFILE'
	|	'ROWID' 
	|	'UROWID' ( LPAREN NUMBER RPAREN )?
	;

type_spec
	:	datatype 
//	|	variable_name TYPE_ATTR
        |     type_name type_variants
//	|	( column_spec TYPE_ATTR) => column_spec TYPE_ATTR
	
//	|	package_name DOT variable_name
       // |  (  table_spec ROWTYPE_ATTR) =>  table_spec ROWTYPE_ATTR
 //       |	type_name ( LPAREN NUMBER RPAREN )?
//	|	keyREF ( keyCURSOR | type_name )
	
	;
type_spec2
	: type_name type_variants;
	
type_variants
	: ( LPAREN NUMBER RPAREN )? // simple
	  |  ROWTYPE_ATTR // table_spec
	  |  TYPE_ATTR; // column spec	

type_name
	:	identifier ( DOT identifier )*
	;

parameter_specs
	:	parameter_spec ( COMMA parameter_spec )*
	;

parameter_spec
	:	parameter_name ( 'IN' )? ( type_spec )?
	;	

parameter_name
	:	identifier
	;

cursor_spec
	:	keyCURSOR cursor_name 
		( LPAREN parameter_specs RPAREN )?
		keyRETURN return_type SEMI! 
	;

procedure_spec: 
	'PROCEDURE' procedure_name 
	( LPAREN arguments RPAREN )? SEMI
	;

function_spec
	:	'FUNCTION' function_name 
		( LPAREN arguments RPAREN )?
		keyRETURN return_type SEMI
	;

exception_declaration
	:	exception_name 'EXCEPTION' SEMI
	;

exception_names
	:	exception_name ( 'OR' exception_name )*
	;

exception_name
	:	( exception_package_name DOT )? identifier
	;

exception_package_name
	:	identifier
	;

	
//oracle_err_number
//	:	( PLUS | MINUS )? NUMBER
//	|	QUOTED_STRING
//	;
	
record_declaration
	:	record_type_dec 
//	|	record_var_dec
	;

record_type_dec
	:	keyTYPE type_name 'IS' keyRECORD 
		LPAREN field_specs RPAREN SEMI
	;

//record_var_dec
//	:	record_name type_name ROWTYPE_ATTR SEMI
//	;

field_specs
	:	field_spec ( COMMA field_spec )*
	;
field_spec
	:	column_name type_spec
		('NOT' 'NULL')? 
		( ( ASSIGN | 'DEFAULT' ) plsql_expression)?
	;

plsql_table_declaration
	:	table_type_dec
//	|	table_var_dec
	;

table_type_dec
	:	keyTYPE type_name 'IS' 'TABLE' 
		'OF' type_spec ( 'NOT' 'NULL' )?
		(	'INDEX' 'BY' 
			(	'BINARY_INTEGER'
			|	'PLS_INTEGER'
			|	'VARCHAR2' LPAREN integer RPAREN
			)
		)?
		SEMI
	;

table_var_dec
	:	plsql_table_name type_name SEMI
	;

plsql_table_name
	:	identifier ( DOT identifier )*
	;

varray_declaration
	:	keyTYPE type_name 'IS' 
		( keyVARRAY | keyVARYING keyARRAY ) LPAREN integer RPAREN
		'OF' type_spec ( 'NOT' 'NULL' )?
	;

procedure_declaration
	:	procedure_body
	;

procedure_body
	:	( proc_fun_start )? 'PROCEDURE'^ procedure_name 
		( LPAREN argument ( COMMA argument )* RPAREN )? 
		( 'IS' | 'AS' )
		//( keyPRAGMA keyAUTONOMOUS_TRANSACTION )?
		( ( declare_spec ) => ( declare_spec )* )
		( 'BEGIN' )
		( seq_of_statements )
		( 'EXCEPTION' ( exception_handler )* )?
		'END' ( procedure_name )? SEMI
	;

begin_block
	:	'BEGIN'
		( seq_of_statements )
		( 'EXCEPTION' ( exception_handler )+ )?
		'END'
	;

//Exception handler needs to be defined
exception_handler
	:	'WHEN' exception_names 'THEN'
		seq_of_statements
	;

proc_fun_start
	:	'CREATE' ( 'OR' keyREPLACE )?
	;

function_body
	:	( proc_fun_start )? 'FUNCTION'^ function_name 
		( LPAREN arguments RPAREN )? 
		keyRETURN return_type ( 'IS' | 'AS' )
		//( keyPRAGMA keyAUTONOMOUS_TRANSACTION )?
		( ( declare_spec ) => ( declare_spec )* )
		( 'BEGIN' )
		( seq_of_statements )
		( 'EXCEPTION' ( exception_handler )+ )?
		'END' ( function_name )? SEMI { /*ANTLR3_FPRINTF(stderr,"\%s",function_name.text);*/}
	;

function_name
	:	identifier | QUOTED_STRING //( schema_name DOT )? identifier
	;

procedure_name
	:	identifier | QUOTED_STRING //( schema_name DOT )? identifier
	;

arguments
	:	argument ( COMMA argument )*
	;

argument
	:	argument_name ( keyOUT | 'IN' keyOUT | 'IN' )? (argument_type )?
		( ( ASSIGN | 'DEFAULT' ) plsql_expression )?
	;

argument_name
	:	identifier
	;

argument_type
	:	type_spec
	;

value
	:	( PLUS | MINUS )? NUMBER
	|	quoted_string
	|	'TRUE' | 'FALSE'
	|	'NULL'
	;

return_type
	:	type_spec
	;

function_declaration
	:	function_body
	;

function_call
	:	user_defined_function ( { input.LA(1) != LPAREN || input.LA(2) != PLUS || input.LA(3) != RPAREN }? LPAREN ( call_parameters )? RPAREN )?
//	|	//{ INPUT.LA(1) == ID && INPUT.LA(2) == LPAREN && INPUT.LA(3) == ASTERISK && INPUT.LA(4) == RPAREN }? 
//		{ is_sql }?
//		keyCOUNT LPAREN ( ASTERISK | sql_expression ) RPAREN
//	|	{ is_sql }?
//		'DISTINCT' LPAREN call_parameters RPAREN
	;

collection_function_call
	:	plsql_table_name
	;

variable_names
	:	variable_name ( COMMA variable_name )*
	;
variable_name
	:	identifier
	 	  
	;
	
full_variable_name
	:  identifier (DOT  identifier)* ; 	 

null_statement
	:	'NULL' 
	;

raise_statement
	:	keyRAISE ( exception_name )?
	;
	
return_statement
	:	keyRETURN ( plsql_expression )?
	;

loop_statement
	:	( LLABEL label_name RLABEL )?
		(	keyWHILE^ plsql_condition
		| 	(	'FOR'^
				(	( numeric_loop_param ) => numeric_loop_param
				|	( cursor_loop_param ) => cursor_loop_param 
				)
			)
		)?
		keyLOOP
		seq_of_statements
		'END' keyLOOP 
		( label_name )?
	;

numeric_loop_param
	:	index_name 'IN' ( keyREVERSE )? integer_expr DOUBLEDOT integer_expr
	;

index_name
	:	identifier
	;

//Added typespec to handle packagename.variablename for loop statement
integer_expr
	:	sql_expression
	;

cursor_name
	:	identifier
	;

cursor_loop_param
	:	record_name 'IN'
		(	cursor_name ( LPAREN plsql_expressions RPAREN )?
		|	LPAREN select_statement RPAREN
		)
	;

record_name
	:	identifier
	;

commit_statement
	:	'COMMIT'
	;

if_statement
	:	'IF'^ plsql_condition 'THEN' seq_of_statements
		(	//{ INPUT.LA(1) != ELSE }?
			keyELSIF plsql_condition 'THEN' seq_of_statements
		)*
		( 'ELSE' seq_of_statements )?
		'END' 'IF'
	;

sql_statement
	:	sql_command
	;

sql_command
	:	to_modify_data
	|	to_control_data
	;

to_modify_data
	:	select_command
	|	insert_command
	|	update_command
	|	delete_command
	|	set_transaction_command
	;

to_control_data
	:	close_statement
	|	commit_statement
	|	fetch_statement
	|	lock_table_statement
	|	open_statement
	|	rollback_statement
	|	savepoint_statement
	;

select_command
	:	select_statement// ( 'UNION' select_statement )*
	;

select_statement
	:	//( LPAREN select_command RPAREN ) => LPAREN select_command RPAREN |
		select_expression 
	;

select_expression
	:	
		'SELECT' /*( hint )?*/ ( 'DISTINCT' | 'UNIQUE' | 'ALL' )? select_list
		( keyBULK keyCOLLECT )?
		( 'INTO' lvalues )?
		'FROM' ( join_clause | LPAREN join_clause RPAREN | table_reference_list )
		( where_clause )? ( hierarchical_query_clause )? ( group_by_clause )?
		( 'HAVING' sql_condition )? ( model_clause )?
		(	(	'UNION' ( 'ALL' )?
			|	'INTERSECT'
			|	'MINUS'
			)
			(	select_expression //LPAREN subquery RPAREN
			|	subquery
			)
		)?
		( order_by_clause )?
	;

select_list 
	: 	ASTERISK
	|	displayed_column ( COMMA displayed_column )*
	;

table_reference_list_from
	:	'FROM' table_reference_list
	;

table_reference_list
	:	selected_table ( COMMA selected_table )*
	;

join_clause
	:	selected_table ( inner_cross_join_clause | outer_join_clause )+
	;
inner_cross_join_clause
	:	( keyINNER )? keyJOIN table_name ( 'ON' sql_condition | keyUSING LPAREN column_specs RPAREN )
	|	( keyCROSS | keyNATURAL ( keyINNER ) ) keyJOIN table_name
	;
outer_join_clause
	:	( query_partition_clause )?
		(	outer_join_type keyJOIN
		|	keyNATURAL ( outer_join_type )? keyJOIN
		)
		selected_table ( query_partition_clause )?
		( 'ON' sql_condition | keyUSING LPAREN column_specs RPAREN )?
	;
query_partition_clause
	:	keyPARTITION 'BY' expression_list
	;
outer_join_type
	:	( keyFULL | keyLEFT | keyRIGHT ) ( keyOUTER )?
	;
outer_join_sign
	:	LPAREN PLUS RPAREN
	;
where_clause
	:	'WHERE' sql_condition
	;
hierarchical_query_clause
	:	( 'START' 'WITH' sql_condition )? 'CONNECT' 'BY' ( keyNOCYCLE )? sql_condition
	;
group_by_clause
	:	'GROUP' 'BY' group_by_exprs
	;
group_by_exprs
	:	group_by_expr ( COMMA group_by_expr )*
	;
group_by_expr
	:	rollup_cube_clause
	|	grouping_sets_clause
	|	grouping_expression_list
	;
rollup_cube_clause
	:	( keyROLLUP | keyCUBE ) LPAREN grouping_expression_list RPAREN
	;
grouping_sets_clause
	:	keyGROUPING keySETS LPAREN grouping_expression_list RPAREN
	;
grouping_sets_exprs
	:	grouping_sets_expr ( COMMA grouping_sets_expr )*
	;
grouping_sets_expr
	:	rollup_cube_clause | grouping_expression_list
	;
model_clause
	:	keyMODEL ( cell_reference_options )
		( return_rows_clause )?
		( reference_model )+ main_model
	;
cell_reference_options
	:	( ( keyIGNORE | keyKEEP ) keyNAV )?
		( 'UNIQUE' ( keyDIMENSION | keySINGLE keyREFERENCE ) )?
	;
return_rows_clause
	:	keyRETURN ( keyUPDATED | 'ALL' ) 'ROWS'
	;
reference_model
	:	keyREFERENCE reference_model_name 'ON' LPAREN subquery RPAREN
		model_column_clauses ( cell_reference_options )
	;
reference_model_name
	:	identifier
	;
main_model
	:	( keyMAIN main_model_name )? model_column_clauses
		( cell_reference_options ) model_rules_clause
	;
main_model_name
	:	identifier
	;
model_column_clauses
	:	( query_partition_clause ( column_spec )? )?
		keyDIMENSION 'BY' LPAREN model_columns RPAREN
		keyMEASURES LPAREN model_columns RPAREN
	;
model_columns
	:	model_column ( COMMA model_column )*
	;
model_column
	:	sql_expression ( ( 'AS' )? column_spec )?
	;
model_rules_clause
	:	( keyRULES ( 'UPDATE' | keyUPSERT ( 'ALL' )? )? ( ( keyAUTOMATIC | keySEQUENTIAL ) 'ORDER' )? )?
		( keyITERATE LPAREN NUMBER RPAREN ( keyUNTIL LPAREN sql_condition RPAREN )? )?
		LPAREN model_rules_exprs RPAREN
	;
model_rules_exprs
	:	model_rules_expr ( COMMA model_rules_expr )*
	;
model_rules_expr
	:	( 'UPDATE' | keyUPSERT ( 'ALL' )? )? cell_assignment ( order_by_clause )? EQ sql_expression
	;
cell_assignment
	:	measure_column LBRACK ( multi_column_for_loop | cell_assignment_exprs ) RBRACK
	;
cell_assignment_exprs
	:	cell_assignment_expr ( COMMA cell_assignment_expr )*
	;
cell_assignment_expr
	:	sql_condition | sql_expression | single_column_for_loop
	;
measure_column
	:	column_name
	;
single_column_for_loop
	:	'FOR' column_name
		(	'IN' LPAREN ( literals | subquery ) RPAREN
		|	( 'LIKE' pattern )? 'FROM' literal 'TO' literal ( keyINCREMENT | keyDECREMENT ) literal
		)
	;
literal
	:	( PLUS | MINUS )? NUMBER
	|	QUOTED_STRING
	;
literals
	:	literal ( COMMA literal )*
	;
bracket_literals
	:	LPAREN literals RPAREN
	;
bracket_literals_list
	:	bracket_literals ( COMMA bracket_literals )*
	;
pattern
	:	QUOTED_STRING
	;
multi_column_for_loop
	:	'FOR' LPAREN column_specs RPAREN 'IN' LPAREN ( bracket_literals_list | subquery ) RPAREN
	;
order_by_clause
	:	'ORDER' ( keySIBLINGS )? 'BY' order_by_exprs
	;
order_by_exprs
	:	order_by_expr ( COMMA order_by_expr )*
	;
order_by_expr
	:	(	sql_expression
//		|	position
//		|	column_alias
		)
		( 'ASC' | 'DESC' )? ( keyNULLS keyFIRST | keyNULLS keyLAST )?
	;
for_update_clause
	:	'FOR' 'UPDATE' ( 'OF' column_specs )? ( keyWAIT integer | 'NOWAIT' )?
	;

where_condition_whole
	:	'WHERE' sql_condition
	;

where_condition
	:	sql_condition
	;

displayed_column
	:	(	column_spec DOT ASTERISK
//		|	keyCOUNT LPAREN ( ASTERISK | 'DISTINCT' LPAREN sql_expression RPAREN ) RPAREN
//		|	
		|	sql_expression
		)
		( alias_ )?
	;

schema_name
	:	sql_identifier
	;

table_name
	:	sql_identifier
	;

nested_expressions
	:	nested_expression ( COMMA nested_expression )*
	;

nested_expression
	:	{  is_sql }? sql_expression
	|	{ !is_sql }? plsql_expression
	;
plsql_condition
		@init { is_sql = false; }
	:	expr_bool
	;

plsql_expressions
	:	plsql_expression ( COMMA plsql_expression )*
	;

plsql_expression
		@init { is_sql = false; }
	:	expr_bool
	;


expr_bool
	:	expr_or ( 'OR' expr_or )*
	;
expr_or
	:	expr_and ( 'AND' expr_and )*
	;
expr_and
	:	( 'NOT' )? expr_not
	;
expr_not
	:	expr_add 
		(	relational_op expr_add
		|	FOUND_ATTR | NOTFOUND_ATTR | ISOPEN_ATTR | ROWCOUNT_ATTR | BULK_ROWCOUNT_ATTR
		|	'IS' ( 'NOT' )? 'NULL'
		|	( 'NOT' )? 'LIKE' expr_add
		|	( 'NOT' )? 'BETWEEN' expr_add 'AND' expr_add
		|	( 'NOT' )? 'IN' LPAREN nested_expressions RPAREN
		)*
	;

boolean_literal
	:	'TRUE' | 'FALSE'
	;

sql_expressions
	:	sql_expression ( COMMA sql_expression )*
	;
sql_expression
		@init { is_sql = true; }
	:	expr_add
	;
expr_add
	:	expr_mul ( ( PLUS | MINUS | DOUBLEVERTBAR ) expr_mul )*
	;
expr_mul
	:	expr_sign ( ( ASTERISK | DIVIDE ) expr_sign )*
	;
expr_sign
	:	( PLUS | MINUS )? expr_pow
	;
expr_pow
	:	expr_expr ( EXPONENT expr_expr )*
	;
expr_expr
	:	( expr_paren ) => expr_paren
	
//	|	( compound_expression ) => compound_expression
	|	( case_expression ) => case_expression
	|	( cursor_expression ) => cursor_expression
	|	( function_expression ) => function_expression
	|	( simple_expression ) => simple_expression
	|	( select_expression ) => select_expression
	
//	|	( special_expression ) => special_expression
//	|	datetime_expression
//	|	interval_expression
//	|	object_access_expression
//	|	scalar_subquery_expression
//	|	model_expression
//	|	type_constructor_expression
//	|	variable_expression
//	:	'NULL' | NUMBER | QUOTED_STRING | IDENTIFIER
	;
simple_expression
	:	boolean_literal
	|	'SQL' ( FOUND_ATTR | NOTFOUND_ATTR | ISOPEN_ATTR | ROWCOUNT_ATTR | BULK_ROWCOUNT_ATTR )
	|	QUOTED_STRING
	|	( column_spec ) => column_spec
	|	NUMBER
//	|	sequence_name DOT ( 'CURRVAL' | 'NEXTVAL' )
//	|	'ROWID'
//	|	'ROWNUM'
	|	'NULL'
	;
compound_expression
//	:	expr_paren
//	|	expr_sign
	:	expr_prior
//	|	expr_add
//	|	expr_cat
	;
expr_paren
	:	LPAREN nested_expression RPAREN
	;
expr_prior
	:	'PRIOR' expr_add
	;
case_expression
	:	'CASE' ( simple_case_expression | searched_case_expression ) ( else_case_expression )? 'END'
	;
simple_case_expression
	:	nested_expression ( 'WHEN' nested_expression 'THEN' nested_expression )+
	;
searched_case_expression
	:	( 'WHEN' nested_condition 'THEN' nested_expression )+
	;
else_case_expression
	:	'ELSE' nested_expression
	;
case_statement
	:	( label_name )? 'CASE'^ ( simple_case_statement | searched_case_statement ) ( else_case_statement )? 'END' 'CASE' ( label_name )?
	;
simple_case_statement
	:	plsql_expression ( 'WHEN' plsql_expression 'THEN' seq_of_statements )+
	;
searched_case_statement
	:	( 'WHEN' plsql_expression 'THEN' seq_of_statements )+
	;
else_case_statement
	:	'ELSE' seq_of_statements
	;
cursor_expression
	:	keyCURSOR LPAREN subquery RPAREN
	;
datetime_expression
	:	sql_expression 'AT'
		(	keyLOCAL
		|	keyTIME keyZONE ( keyDBTIMEZONE | keySESSIONTIMEZONE | sql_expression )
		)
	;
function_expression
	:	
		{ is_sql }?
		(	keyCOUNT LPAREN ( ASTERISK | nested_expression ) RPAREN
		|	'DISTINCT' ( LPAREN nested_expression RPAREN | nested_expression )
		|       function_call ( DOT nested_expression )?
		)
		|
		function_call ( DOT nested_expression )?
	;
special_expression
	:	{ is_sql }?
		(	keyCOUNT LPAREN ( ASTERISK | nested_expression ) RPAREN
		|	'DISTINCT' LPAREN nested_expression RPAREN
		)
	;
interval_expression
	:	sql_expression
		(	keyDAY ( LPAREN leading_field_precision RPAREN )? 'TO' keySECOND ( LPAREN fractional_second_precision RPAREN )?
		|	keyYEAR ( LPAREN leading_field_precision RPAREN )? 'TO' keyMONTH
		)
	;
leading_field_precision
	:	integer // TODO validate digit from 0 to 9
	;
fractional_second_precision
	:	integer // TODO validate digit from 0 to 9
	;
object_access_expression
	:
	;
scalar_subquery_expression
	:
	;
model_expression
	:
	;
type_constructor_expression
	:
	;
variable_expression
	:
	;
sequence_name
	:	identifier
	;
integer
	:	NUMBER
	;


alias_
	:	( 'AS' )? sql_identifier
	;

column_specs
	:	column_spec ( COMMA column_spec )*
	;

column_spec
	:	sql_identifier ( DOT sql_identifier ( DOT sql_identifier )? )?
//	|	{ is_sql }?
//		(	ASTERISK
//		|	sql_identifier ( DOT sql_identifier )* ( DOT ASTERISK )
//		)
//		( ( schema_name DOT )? table_name DOT )? column_name
	;

column_name
	:	sql_identifier
	;
nested_table
	:	sql_identifier
	;
nested_table_column_name
	:	( schema_name DOT )? table_name DOT nested_table DOT column_name
	;

user_defined_function
	:	sql_identifier ( DOT sql_identifier )* ( DOT ( 'EXISTS' | 'PRIOR' | 'DELETE' ) )? //( ( schema_name DOT )? package_name DOT )? identifier // sql_identifier ( DOT sql_identifier )*
	;

//function
//	:	user_defined_function
//		number_function
//	|	char_function
//	|	group_function
//	|	conversion_function
//	|	other_function
//	;

selected_table
	:	( table_spec | ( 'TABLE' | keyTHE )? subquery ) ( alias_ )?
	;

table_spec
	:	( schema_name DOT )? table_name ( AT_SIGN link_name )?
	;

table_alias
	:	( schema_name DOT )? table_name ( AT_SIGN link_name )? ( alias_ )?
	;

link_name
	:	sql_identifier
	;
nested_condition
	:	{  is_sql }? condition_or
	|	{ !is_sql }? expr_bool
	;
sql_condition
		@init { is_sql = true; }
	:	condition_or
//	|	column 'IS' 'NOT' 'NULL' // TODO must be any boolean expression with table columns
	;
condition_paren
	:	LPAREN sql_condition RPAREN
	;
condition_or
	:	condition_and ( 'OR' condition_and )*
	;
condition_and
	:	condition_not ( 'AND' condition_not )*
	;
condition_not
	:	'NOT' condition_expr
	|	condition_expr
	;
condition_expr
	:	condition_exists
	|	condition_is
	|	condition_comparison
	|	condition_group_comparison
	|	condition_in
	|	condition_is_a_set
	|	condition_is_any
	|	condition_is_empty
	|	condition_is_of_type
	|	condition_is_present
	|	condition_like
	|	condition_memeber
	|	condition_between
	|	condition_regexp_like
	|	condition_submultiset
	|	condition_equals_path
	|	condition_under_path
	|	condition_paren
	;
condition_exists
	:	'EXISTS' LPAREN select_command RPAREN
	;
condition_is
	:	sql_expression 'IS' ( 'NOT' )? ( keyNAN | keyINFINITE | 'NULL' )
	;
condition_comparison
	:	LPAREN sql_expressions RPAREN ( outer_join_sign )? ( EQ | NOT_EQ ) LPAREN select_command RPAREN ( outer_join_sign )?
	|	( 'PRIOR' )? sql_expression ( outer_join_sign )? ( EQ | NOT_EQ | GTH | GEQ | LTH | LEQ ) ( 'PRIOR' )? ( sql_expression | LPAREN select_command RPAREN ) ( outer_join_sign )?
	;
condition_group_comparison
	:	LPAREN sql_expressions RPAREN ( EQ | NOT_EQ ) ( 'ANY' | keySOME | 'ALL' ) LPAREN ( grouping_expression_list | select_command ) RPAREN
	|	sql_expression ( EQ | NOT_EQ | GTH | GEQ | LTH | LEQ ) ( 'ANY' | keySOME | 'ALL' ) LPAREN ( sql_expressions | select_command ) RPAREN
	;
condition_in
	:	LPAREN sql_expressions RPAREN ( 'NOT' )? 'IN' LPAREN ( grouping_expression_list | select_command ) RPAREN
	|	sql_expression ( 'NOT' )? 'IN' LPAREN ( expression_list | select_command ) RPAREN
	;
condition_is_a_set
	:	nested_table_column_name 'IS' ( 'NOT' )? keyA 'SET'
	;
condition_is_any
	:	( column_name 'IS' )? 'ANY'
	;
condition_is_empty
	:	nested_table_column_name 'IS' ( 'NOT' )? keyEMPTY
	;
condition_is_of_type
	:	sql_expression 'IS' ( 'NOT' )? 'OF' ( keyTYPE )? LPAREN type_name RPAREN
	;
condition_is_of_type_names
	:	condition_is_of_type_name ( COMMA condition_is_of_type_name )*
	;
condition_is_of_type_name
	:	( keyONLY )? type_name
	;
condition_is_present
	:	cell_reference 'IS' keyPRESENT
	;
condition_like
	:	sql_expression ( 'NOT' )? ( 'LIKE' | keyLIKEC | keyLIKE2 | keyLIKE4 ) sql_expression ( keyESCAPE sql_expression )?
	;
condition_memeber
	:	sql_expression ( 'NOT' )? keyMEMBER ( 'OF' )? nested_table_column_name
	;
condition_between
	:	sql_expression ( 'NOT' )? 'BETWEEN' sql_expression 'AND' sql_expression
	;
condition_regexp_like
	:	keyREGEXP_LIKE LPAREN call_parameters RPAREN
	;
condition_submultiset
	:	nested_table_column_name ( 'NOT' )? keySUBMULTISET ( 'OF' )? nested_table_column_name
	;
condition_equals_path
	:	keyEQUALS_PATH LPAREN column_name COMMA path_string ( COMMA correlation_integer )? RPAREN
	;
condition_under_path
	:	keyUNDER_PATH LPAREN column_name ( COMMA levels )? COMMA path_string ( COMMA correlation_integer )? RPAREN
	;
levels
	:	integer
	;
correlation_integer
	:	integer
	;
path_string
	:	QUOTED_STRING
	;
grouping_expression_list
	:	expression_list ( COMMA expression_list )*
	;
expression_list
	:	LPAREN sql_expressions RPAREN
	|	sql_expressions
	;
cell_reference
	:	sql_identifier
	;
call_parameters
	:	call_parameter ( COMMA call_parameter )*
	;
call_parameter
	:	( parameter_name ARROW )? nested_expression
	;

relational_op
	:	EQ | LTH | GTH | NOT_EQ | LEQ | GEQ
	;

exp_set
	:	( sql_expression ) => sql_expression
	|	subquery
	;

subquery
	:	LPAREN select_command RPAREN
	;

connect_clause
	:	( 'START' 'WITH' sql_condition )?
		'CONNECT' 'BY' 
		(	'PRIOR' sql_expression relational_op sql_expression
		|	sql_expression relational_op sql_expression 'PRIOR'
		)
		(	( ( 'PRIOR' )? sql_condition ) => ('PRIOR')? sql_condition
		|	sql_expression relational_op ( 'PRIOR' )? sql_expression ( 'AND' sql_condition )?
		)
		( 'START' 'WITH' sql_condition )?
	;

group_clause
	:	'GROUP' 'BY' sql_expression ( COMMA sql_expression )* ( 'HAVING' sql_condition )?
	;

set_clause
	:	( ( 'UNION' 'ALL' ) | 'INTERSECT' | 'MINUS' ) select_command 
	;

order_clause
	:	'ORDER' 'BY' sorted_def ( COMMA sorted_def )*
	;

sorted_def
	:	( ( sql_expression ) => sql_expression | ( NUMBER ) => NUMBER ) ( 'ASC' | 'DESC' )?
	;

update_clause
	:	'FOR' 'UPDATE' ( 'OF' column_name ( COMMA column_name )* )? ( 'NOWAIT' )?
	;

insert_command
	:	'INSERT' 'INTO' table_reference_list
		( LPAREN column_specs RPAREN )?
		(	'VALUES' LPAREN plsql_expressions RPAREN
		|	select_statement
		)
		( returning_clause )?
	;

update_command
	:	'UPDATE' selected_table
		'SET' 
		(	update_nested_column_specs
		|	update_column_specs
		)
		(	'WHERE'
			(	keyCURRENT_OF cursor_name
			|	sql_condition
			)
		)?
		( returning_clause )?
	;

update_column_specs
	:	update_column_spec ( COMMA update_column_spec )*
	;

update_column_spec
	:	column_spec EQ sql_expression
	;

update_nested_column_specs
	:	update_nested_column_spec ( COMMA update_nested_column_spec )*
	;

update_nested_column_spec
	:	LPAREN column_specs RPAREN EQ subquery
	;

delete_command
	:	'DELETE' ( 'FROM' )? selected_table
		(	'WHERE'
			(	keyCURRENT_OF cursor_name
			|	sql_condition
			)
		)?
		( returning_clause )?
	;

returning_clause
	:	( keyRETURN | keyRETURNING ) select_list ( keyBULK keyCOLLECT )? 'INTO' lvalues
	;

set_transaction_command
	:	'SET' keyTRANSACTION keyREAD keyONLY
	;

close_statement
	:	keyCLOSE cursor_name
	;

fetch_destination_item 
	:// variable_name	
	//| 
	identifier (DOT identifier)*;
	
	
 fetch_destination_list 
 	:fetch_destination_item ( COMMA fetch_destination_item )*;

fetch_statement
	:	'FETCH' cursor_name 'INTO' fetch_destination_list
	
	;

lock_table_statement
	:	'LOCK' 'TABLE' table_reference_list
		'IN' lock_mode 'MODE' ( 'NOWAIT' )?
	;

lock_mode
	:	'ROW' 'SHARE'
	|	'ROW' 'EXCLUSIVE'
	|	'SHARE' 'UPDATE'
	|	'SHARE'
	|	'SHARE' 'ROW' 'EXCLUSIVE'
	|	'EXCLUSIVE'
	;

open_statement
	:	keyOPEN cursor_name ( LPAREN plsql_expressions RPAREN )?
	;

rollback_statement
	:	keyROLLBACK ( keyWORK )?
		( 'TO' ( 'SAVEPOINT' )? savepoint_name )?
		( 'COMMENT' quoted_string )?
	;

savepoint_statement
	:	'SAVEPOINT' savepoint_name
	;

savepoint_name
	:	identifier
	;

identifier
	:	ID
	|	DOUBLEQUOTED_STRING 
//	|	keyword
   	;

quoted_string
	:	QUOTED_STRING
	;

match_string
	:	QUOTED_STRING 
	;
keyA                             : {input.LT(1).getText().toUpperCase()== "A"}? ID;
keyAUTOMATIC                     : {input.LT(1).getText().toUpperCase()== "AUTOMATIC"}? ID;
keyCOUNT                         : {input.LT(1).getText().toUpperCase()== "COUNT"}? ID;
keyCROSS                         : {input.LT(1).getText().toUpperCase()== "CROSS"}? ID;
keyCUBE                          : {input.LT(1).getText().toUpperCase()== "CUBE"}? ID;
keyCURRENT_OF                    : {input.LT(1).getText().toUpperCase()== "CURRENT_OF"}? ID;
keyDAY                           : {input.LT(1).getText().toUpperCase()== "DAY"}? ID;
keyDBTIMEZONE                    : {input.LT(1).getText().toUpperCase()== "DBTIMEZONE"}? ID;
keyDECREMENT                     : {input.LT(1).getText().toUpperCase()== "DECREMENT"}? ID;
keyDIMENSION                     : {input.LT(1).getText().toUpperCase()== "DIMENSION"}? ID;
keyEMPTY                         : {input.LT(1).getText().toUpperCase()== "EMPTY"}? ID;
keyEQUALS_PATH                   : {input.LT(1).getText().toUpperCase()== "EQUALS_PATH"}? ID;
keyESCAPE                        : {input.LT(1).getText().toUpperCase()== "ESCAPE"}? ID;
keyFIRST                         : {input.LT(1).getText().toUpperCase()== "FIRST"}? ID;
keyFULL                          : {input.LT(1).getText().toUpperCase()== "FULL"}? ID;
keyGROUPING                      : {input.LT(1).getText().toUpperCase()== "GROUPING"}? ID;
keyIGNORE                        : {input.LT(1).getText().toUpperCase()== "IGNORE"}? ID;
keyINCREMENT                     : {input.LT(1).getText().toUpperCase()== "INCREMENT"}? ID;
keyINFINITE                      : {input.LT(1).getText().toUpperCase()== "INFINITE"}? ID;
keyINNER                         : {input.LT(1).getText().toUpperCase()== "INNER"}? ID;
keyINTERVAL                      : {input.LT(1).getText().toUpperCase()== "INTERVAL"}? ID;
keyITERATE                       : {input.LT(1).getText().toUpperCase()== "ITERATE"}? ID;
keyJOIN                          : {input.LT(1).getText().toUpperCase()== "JOIN"}? ID;
keyKEEP                          : {input.LT(1).getText().toUpperCase()== "KEEP"}? ID;
keyLAST                          : {input.LT(1).getText().toUpperCase()== "LAST"}? ID;
keyLEFT                          : {input.LT(1).getText().toUpperCase()== "LEFT"}? ID;
keyLIKE2                         : {input.LT(1).getText().toUpperCase()== "LIKE2"}? ID;
keyLIKE4                         : {input.LT(1).getText().toUpperCase()== "LIKE4"}? ID;
keyLIKEC                         : {input.LT(1).getText().toUpperCase()== "LIKEC"}? ID;
keyLOCAL                         : {input.LT(1).getText().toUpperCase()== "LOCAL"}? ID;
keyMAIN                          : {input.LT(1).getText().toUpperCase()== "MAIN"}? ID;
keyMEASURES                      : {input.LT(1).getText().toUpperCase()== "MEASURES"}? ID;
keyMEMBER                        : {input.LT(1).getText().toUpperCase()== "MEMBER"}? ID;
keyMODEL                         : {input.LT(1).getText().toUpperCase()== "MODEL"}? ID;
keyMONTH                         : {input.LT(1).getText().toUpperCase()== "MONTH"}? ID;
keyNAN                           : {input.LT(1).getText().toUpperCase()== "NAN"}? ID;
keyNATURAL                       : {input.LT(1).getText().toUpperCase()== "NATURAL"}? ID;
keyNAV                           : {input.LT(1).getText().toUpperCase()== "NAV"}? ID;
keyNOCYCLE                       : {input.LT(1).getText().toUpperCase()== "NOCYCLE"}? ID;
keyNULLS                         : {input.LT(1).getText().toUpperCase()== "NULLS"}? ID;
keyONLY                          : {input.LT(1).getText().toUpperCase()== "ONLY"}? ID;
keyOUTER                         : {input.LT(1).getText().toUpperCase()== "OUTER"}? ID;
keyPARTITION                     : {input.LT(1).getText().toUpperCase()== "PARTITION"}? ID;
keyPRECISION                     : {input.LT(1).getText().toUpperCase()== "PRECISION"}? ID;
keyPRESENT                       : {input.LT(1).getText().toUpperCase()== "PRESENT"}? ID;
keyREFERENCE                     : {input.LT(1).getText().toUpperCase()== "REFERENCE"}? ID;
keyREGEXP_LIKE                   : {input.LT(1).getText().toUpperCase()== "REGEXP_LIKE"}? ID;
//keyRETURN                        : {input.LT(1).getText().toUpperCase()== "RETURN"}? ID;
keyRIGHT                         : {input.LT(1).getText().toUpperCase()== "RIGHT"}? ID;
keyROLLUP                        : {input.LT(1).getText().toUpperCase()== "ROLLUP"}? ID;
keyRULES                         : {input.LT(1).getText().toUpperCase()== "RULES"}? ID;
keySECOND                        : {input.LT(1).getText().toUpperCase()== "SECOND"}? ID;
keySECONDS                       : {input.LT(1).getText().toUpperCase()== "SECONDS"}? ID;
keySEQUENTIAL                    : {input.LT(1).getText().toUpperCase()== "SEQUENTIAL"}? ID;
keySESSIONTIMEZONE               : {input.LT(1).getText().toUpperCase()== "SESSIONTIMEZONE"}? ID;
keySETS                          : {input.LT(1).getText().toUpperCase()== "SETS"}? ID;
keySIBLINGS                      : {input.LT(1).getText().toUpperCase()== "SIBLINGS"}? ID;
keySINGLE                        : {input.LT(1).getText().toUpperCase()== "SINGLE"}? ID;
keySOME                          : {input.LT(1).getText().toUpperCase()== "SOME"}? ID;
keySUBMULTISET                   : {input.LT(1).getText().toUpperCase()== "SUBMULTISET"}? ID;
keyTIME                          : {input.LT(1).getText().toUpperCase()== "TIME"}? ID;
keyTIMESTAMP                     : {input.LT(1).getText().toUpperCase()== "TIMESTAMP"}? ID;
keyTHE                           : {input.LT(1).getText().toUpperCase()== "THE"}? ID;
keyUNDER_PATH                    : {input.LT(1).getText().toUpperCase()== "UNDER_PATH"}? ID;
keyUNTIL                         : {input.LT(1).getText().toUpperCase()== "UNTIL"}? ID;
keyUPDATED                       : {input.LT(1).getText().toUpperCase()== "UPDATED"}? ID;
keyUPSERT                        : {input.LT(1).getText().toUpperCase()== "UPSERT"}? ID;
keyWAIT                          : {input.LT(1).getText().toUpperCase()== "WAIT"}? ID;
keyYEAR                          : {input.LT(1).getText().toUpperCase()== "YEAR"}? ID;
keyZONE                          : {input.LT(1).getText().toUpperCase()== "ZONE"}? ID;

keyARRAY                         : {input.LT(1).getText().toUpperCase()== "ARRAY"}? ID;
keyAUTONOMOUS_TRANSACTION        : {input.LT(1).getText().toUpperCase()== "AUTONOMOUS_TRANSACTION"}? ID;
keyBODY                          : {input.LT(1).getText().toUpperCase()== "BODY"}? ID;
keyBUILTIN                       : {input.LT(1).getText().toUpperCase()== "BUILTIN"}? ID;
keyBULK                          : {input.LT(1).getText().toUpperCase()== "BULK"}? ID;
keyBYTE                          : {input.LT(1).getText().toUpperCase()== "BYTE"}? ID;
keyCLOSE                         : {input.LT(1).getText().toUpperCase()== "CLOSE"}? ID;
keyCOLLECT                       : {input.LT(1).getText().toUpperCase()== "COLLECT"}? ID;
keyCURSOR                        : {input.LT(1).getText().toUpperCase()== "CURSOR"}? ID;
keyELSIF                         : 'ELSIF'; //{input.LT(1).getText().toUpperCase()== "ELSIF"}? ID;
keyEXCEPTION_INIT                : {input.LT(1).getText().toUpperCase()== "EXCEPTION_INIT"}? ID;
keyEXIT                          : {input.LT(1).getText().toUpperCase()== "EXIT"}? ID;
keyFIPSFLAG                      : {input.LT(1).getText().toUpperCase()== "FIPSFLAG"}? ID;
keyFUNCTION                      : 'FUNCTION'; //{input.LT(1).getText().toUpperCase()== "FUNCTION"}? ID;
keyINTERFACE                     : {input.LT(1).getText().toUpperCase()== "INTERFACE"}? ID;
keyLOOP                          : 'LOOP'; //{input.LT(1).getText().toUpperCase()== "LOOP"}? ID;
keyNEW                           : {input.LT(1).getText().toUpperCase()== "NEW"}? ID;
keyNEW_NAMES                     : {input.LT(1).getText().toUpperCase()== "NEW_NAMES"}? ID;
keyOPEN                          : {input.LT(1).getText().toUpperCase()== "OPEN"}? ID;
keyOUT                           : 'OUT'; //{input.LT(1).getText().toUpperCase()== "OUT"}? ID;
keyPACKAGE                       : 'PACKAGE'; //{input.LT(1).getText().toUpperCase()== "PACKAGE"}? ID;
keyPRAGMA                        : 'PRAGMA'; //{input.LT(1).getText().toUpperCase()== "PRAGMA"}? ID;
keyRAISE                         : 'RAISE'; //{input.LT(1).getText().toUpperCase()== "RAISE"}? ID;
keyRANGE                         : {input.LT(1).getText().toUpperCase()== "RANGE"}? ID;
keyREAD                          : {input.LT(1).getText().toUpperCase()== "READ"}? ID;
keyRECORD                        : 'RECORD'; //{input.LT(1).getText().toUpperCase()== "RECORD"}? ID;
keyREF                           : {input.LT(1).getText().toUpperCase()== "REF"}? ID;
keyREPLACE                       : {input.LT(1).getText().toUpperCase()== "REPLACE"}? ID;
keyRESTRICT_REFERENCES           : {input.LT(1).getText().toUpperCase()== "RESTRICT_REFERENCES"}? ID;
keyRETURN                        : 'RETURN'; //{input.LT(1).getText().toUpperCase()== "RETURN"}? ID;
keyRETURNING                     : 'RETURNING'; //{input.LT(1).getText().toUpperCase()== "RETURNING"}? ID;
keyREVERSE                       : {input.LT(1).getText().toUpperCase()== "REVERSE"}? ID;
keyROLLBACK                      : 'ROLLBACK'; //{input.LT(1).getText().toUpperCase()== "ROLLBACK"}? ID;
keySERIALLY_REUSABLE             : {input.LT(1).getText().toUpperCase()== "SERIALLY_REUSABLE"}? ID;
keySUBTYPE                       : {input.LT(1).getText().toUpperCase()== "SUBTYPE"}? ID;
keyTRANSACTION                   : {input.LT(1).getText().toUpperCase()== "TRANSACTION"}? ID;
keyTYPE                          : {input.LT(1).getText().toUpperCase()== "TYPE"}? ID;
keyUSING                         : {input.LT(1).getText().toUpperCase()== "USING"}? ID;
keyVARRAY                        : {input.LT(1).getText().toUpperCase()== "VARRAY"}? ID;
keyVARYING                      : {input.LT(1).getText().toUpperCase()== "VARYING"}? ID;
keyWHILE                         : 'WHILE'; //{input.LT(1).getText().toUpperCase()== "WHILE"}? ID;
keyWORK                          : {input.LT(1).getText().toUpperCase()== "WORK"}? ID;


sql_identifier
	:	identifier
	|	'ROWID'
//	|	'ROWNUM'
	;
	
/*qoperator
	: 'q\'';	*/

Qoperator 
	: 'Q\''
	;

QUOTED_STRING
	: SINGLE_QUOTE	
	| QSTRING //  Qoperator starts=. (. {if (LA(1)==starts && LA(2)=='\'') {goto loop1;}})* . .
	;
	
/* Perl-style quoted string */
fragment QSTRING             : ('q'|'Q') ( QS_ANGLE | QS_BRACE | QS_BRACK | QS_PAREN | QS_OTHER) ;
fragment QS_ANGLE   : QUOTE '<' ( options {greedy=false;} : . )* '>' QUOTE ;
fragment QS_BRACE   : QUOTE '{' ( options {greedy=false;} : . )* '}' QUOTE ;
fragment QS_BRACK   : QUOTE '[' ( options {greedy=false;} : . )* ']' QUOTE ;
fragment QS_PAREN   : QUOTE '(' ( options {greedy=false;} : . )* ')' QUOTE ;

fragment QS_OTHER_CH: ~('<'|'{'|'['|'('|' '|'\t'|'\n'|'\r');
fragment QS_OTHER @declarations {
ANTLR3_UINT32 (*oldLA)(struct ANTLR3_INT_STREAM_struct *, ANTLR3_INT32);
}
		@init {
    		
		//	oldLA = INPUT.istream._LA;
            //INPUT.setUcaseLA(INPUT, ANTLR3_FALSE);
		}
		:	
		QUOTE delimiter=QS_OTHER_CH
/* JAVA Syntax */        
 		( { input.LT(1) != $delimiter.text.charAt(0) || ( input.LT(1) == $delimiter.text.charAt(0) && input.LT(2) != '\'') }? => . )*
 		( { input.LT(1) == $delimiter.text.charAt(0) && input.LT(2) == '\'' }? => . ) QUOTE
/* C Syntax */ 
	//	( { input.LA(1) != $delimiter.text.charAt(0) ||input. LA(2) != '\'' }? => . )*
//		( { input.LA(1) == $delimiter.text.charAt(0) && input.LA(2) == '\'' }? => . ) QUOTE
 	//	{ INPUT.istream._LA = oldLA; }
		;
	
fragment SINGLE_QUOTE
	: ( 'n' )? '\'' ( '\'\'' | ~('\'') )* '\'';	

ID /*options { testLiterals=true; }*/
    :	('A' .. 'Z' | 'a' .. 'z') ( 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '_' | '$' | '#' )*
    |	DOUBLEQUOTED_STRING
    ;
SEMI
	:	';'
	;
COLON
	:	':'
	;
DOUBLEDOT
	:	POINT POINT
	;
DOT
	:	POINT
	;
fragment
POINT
	:	'.'
	;
COMMA
	:	','
	;
EXPONENT
	:	'**'
	;
ASTERISK
	:	'*'
	;
AT_SIGN
	:	'@'
	;
RPAREN
	:	')'
	;
LPAREN
	:	'('
	;
RBRACK
	:	']'
	;
LBRACK
	:	'['
	;
PLUS
	:	'+'
	;
MINUS
	:	'-'
	;
DIVIDE
	:	'/'
	;
EQ
	:	'='
	;
PERCENTAGE
	:	'%'
	;
LLABEL
	:	'<<'
	;
RLABEL
	:	'>>'
	;
ASSIGN
	:	':='
	;
ARROW
	:	'=>'
	;
VERTBAR
	:	'|'
	;
DOUBLEVERTBAR
	:	'||'
	;
NOT_EQ
	:	'<>' | '!=' | '^='
	;
LTH
	:	'<'
	;
LEQ
	:	'<='
	;
GTH
	:	'>'
	;
GEQ
	:	'>='
	;
NUMBER
	:	//( PLUS | MINUS )?
		(	( N POINT N ) => N POINT N
		|	POINT N
		|	N
		)
		( 'E' ( PLUS | MINUS )? N )?
    ;
fragment
N
	: '0' .. '9' ( '0' .. '9' )*
	;
QUOTE
	:	'\''
	;
fragment
DOUBLEQUOTED_STRING
	:	'"' ( ~('"') )* '"'
	;
WS	:	(' '|'\r'|'\t'|'\n') {$channel=HIDDEN;}
	;
SL_COMMENT
	:	'--' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
	;
ML_COMMENT
	:	'/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
	;
TYPE_ATTR
	:	'%TYPE'
	;
ROWTYPE_ATTR
	:	'%ROWTYPE'
	;
NOTFOUND_ATTR
	:	'%NOTFOUND'
	;
FOUND_ATTR
	:	'%FOUND'
	;
ISOPEN_ATTR
	:	'%ISOPEN'
	;
ROWCOUNT_ATTR
	:	'%ROWCOUNT'
	;
BULK_ROWCOUNT_ATTR
	:	'%BULK_ROWCOUNT'
	;
CHARSET_ATTR
	:	'%CHARSET'
	;
