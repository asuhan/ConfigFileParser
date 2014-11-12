/*
 [The "BSD license"]
 Copyright (c) 2005-2009 Terence Parr
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
     derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
module antlr.runtime.TokenRewriteStream;


private import antlr.runtime.CommonTokenStream;
private import antlr.runtime.TokenSource;
private import antlr.runtime.Token;
private import std.string;
private import std.stdio;
private import antlr.runtime.JavaExceptions;
private import std.algorithm;

/** Useful for dumping out the input stream after doing some
 *  augmentation or other manipulations.
 *
 *  You can insert stuff, replace, and delete chunks.  Note that the
 *  operations are done lazily--only if you convert the buffer to a
 *  String.  This is very efficient because you are not moving data around
 *  all the time.  As the buffer of tokens is converted to strings, the
 *  toString() method(s) check to see if there is an operation at the
 *  current index.  If so, the operation is done and then normal String
 *  rendering continues on the buffer.  This is like having multiple Turing
 *  machine instruction streams (programs) operating on a single input tape. :)
 *
 *  Since the operations are done lazily at toString-time, operations do not
 *  screw up the token index values.  That is, an insert operation at token
 *  index i does not change the index values for tokens i+1..n-1.
 *
 *  Because operations never actually alter the buffer, you may always get
 *  the original token stream back without undoing anything.  Since
 *  the instructions are queued up, you can easily simulate transactions and
 *  roll back any changes if there is an error just by removing instructions.
 *  For example,
 *
 *   CharStream input = new ANTLRFileStream("input");
 *   TLexer lex = new TLexer(input);
 *   TokenRewriteStream tokens = new TokenRewriteStream(lex);
 *   T parser = new T(tokens);
 *   parser.startRule();
 *
 * 	 Then in the rules, you can execute
 *      Token t,u;
 *      ...
 *      input.insertAfter(t, "text to put after t");}
 * 		input.insertAfter(u, "text after u");}
 * 		System.out.println(tokens.toString());
 *
 *  Actually, you have to cast the 'input' to a TokenRewriteStream. :(
 *
 *  You can also have multiple "instruction streams" and get multiple
 *  rewrites from a single pass over the input.  Just name the instruction
 *  streams and use that name again when printing the buffer.  This could be
 *  useful for generating a C file and also its header file--all from the
 *  same buffer:
 *
 *      tokens.insertAfter("pass1", t, "text to put after t");}
 * 		tokens.insertAfter("pass2", u, "text after u");}
 * 		System.out.println(tokens.toString("pass1"));
 * 		System.out.println(tokens.toString("pass2"));
 *
 *  If you don't use named rewrite streams, a "default" stream is used as
 *  the first example shows.
 */
public class TokenRewriteStream : CommonTokenStream {
	public const string DEFAULT_PROGRAM_NAME = "default";
    public const int PROGRAM_INIT_SIZE = 100;
	public const int MIN_TOKEN_INDEX = 0;

	// Define the rewrite operation hierarchy

	class RewriteOperation {
        /** What index into rewrites List are we? */
        protected int instructionIndex;
        /** Token buffer index. */
        protected int index;
		protected string text;

		protected this(int index) {
			this.index = index;
		}

		protected this(int index, string text) {
			this.index = index;
			this.text = text;
		}
		/** Execute the rewrite operation by possibly adding to the buffer.
		 *  Return the index of the next token to operate on.
		 */
		public int execute(string buf) {
			return index;
		}
		public string toString() {
			string opName = this.classinfo.stringof;
			int index = std.string.indexOf(opName,'$');
			opName = opName[index+1..$];
			return "<"~opName~"@"~tokens[index].toString()~
				   ":\""~text~"\">";
		}
	}

	class InsertBeforeOp : RewriteOperation {
		public this(int index, string text) {
			super(index,text);
		}
		public int execute(string buf) {
			buf~=text;
			if ( tokens[index].getType()!=Token.EOF ) {
				buf~=tokens[index].getText();
			}
			return index+1;
		}
	}

	/** I'm going to try replacing range from x..y with (y-x)+1 ReplaceOp
	 *  instructions.
	 */
	class ReplaceOp : RewriteOperation {
		protected int lastIndex;
		public this(int from, int to, string text) {
			super(from,text);
			lastIndex = to;
		}
		public int execute(string buf) {
			if ( text!=null ) {
				buf~=text;
			}
			return lastIndex+1;
		}
		public string toString() {
			if ( text==null ) {
				return "<DeleteOp@"~tokens[index].toString()~
					   ".."~tokens[lastIndex].toString()~">";
			}
			return "<ReplaceOp@"~tokens[index].toString()~
				   ".."~tokens[lastIndex].toString()~":\""~text~"\">";
		}
	}

	/** You may have multiple, named streams of rewrite operations.
	 *  I'm calling these things "programs."
	 *  Maps String (name) -> rewrite (List)
	 */
	protected RewriteOperation programs[string][] = null;

	/** Map String (program name) -> Integer index */
	protected int lastRewriteTokenIndexes[string] = null;

	public this() {
		init();
	}

	protected void init() {
		programs = null;
		programs[DEFAULT_PROGRAM_NAME] = null;
		lastRewriteTokenIndexes = null;
	}

	public this(TokenSource tokenSource) {
	    super(tokenSource);
		init();
	}

	public this(TokenSource tokenSource, int channel) {
		super(tokenSource, channel);
		init();
	}

	public void rollback(int instructionIndex) {
		rollback(DEFAULT_PROGRAM_NAME, instructionIndex);
	}

	/** Rollback the instruction stream for a program so that
	 *  the indicated instruction (via instructionIndex) is no
	 *  longer in the stream.  UNTESTED!
	 */
	public void rollback(string programName, int instructionIndex) {
		auto i = programName in programs;
		if ( i!=null ) {
			programs[programName] =  (*i)[MIN_TOKEN_INDEX .. instructionIndex];
		}
	}

	public void deleteProgram() {
		deleteProgram(DEFAULT_PROGRAM_NAME);
	}

	/** Reset the program so that no instructions exist */
	public void deleteProgram(string programName) {
		rollback(programName, MIN_TOKEN_INDEX);
	}

	public void insertAfter(Token t, string text) {
		insertAfter(DEFAULT_PROGRAM_NAME, t, text);
	}

	public void insertAfter(int index, string text) {
		insertAfter(DEFAULT_PROGRAM_NAME, index, text);
	}

	public void insertAfter(string programName, Token t, string text) {
		insertAfter(programName,t.getTokenIndex(), text);
	}

	public void insertAfter(string programName, int index, string text) {
		// to insert after, just insert before next index (even if past end)
		insertBefore(programName,index+1, text);
	}

	public void insertBefore(Token t, string text) {
		insertBefore(DEFAULT_PROGRAM_NAME, t, text);
	}

	public void insertBefore(int index, string text) {
		insertBefore(DEFAULT_PROGRAM_NAME, index, text);
	}

	public void insertBefore(string programName, Token t, string text) {
		insertBefore(programName, t.getTokenIndex(), text);
	}

	public void insertBefore(string programName, int index, string text) {
		RewriteOperation op = new InsertBeforeOp(index,text);
		RewriteOperation[]* rewrites = getProgram(programName);
        op.instructionIndex = (*rewrites).length;
        (*rewrites)~=op;		
	}

	public void replace(int index, string text) {
		replace(DEFAULT_PROGRAM_NAME, index, index, text);
	}

	public void replace(int from, int to, string text) {
		replace(DEFAULT_PROGRAM_NAME, from, to, text);
	}

	public void replace(Token indexT, string text) {
		replace(DEFAULT_PROGRAM_NAME, indexT, indexT, text);
	}

	public void replace(Token from, Token to, string text) {
		replace(DEFAULT_PROGRAM_NAME, from, to, text);
	}

	public void replace(string programName, int from, int to, string text) {
		if ( from > to || from<0 || to<0 || to >= tokens.length ) {
			throw new IllegalArgumentException("replace: range invalid: "~std.conv.to!(string)(from)~".."~std.conv.to!(string)(to)~"(size="~std.conv.to!(string)(tokens.length)~")");
		}
		RewriteOperation op = new ReplaceOp(from, to, text);
		RewriteOperation[]* rewrites = getProgram(programName);
        op.instructionIndex = (*rewrites).length;
        (*rewrites)~=op;
	}

	public void replace(string programName, Token from, Token to, string text) {
		replace(programName,
				from.getTokenIndex(),
				to.getTokenIndex(),
				text);
	}

	public void deleteat(int index) {
		deleterange(DEFAULT_PROGRAM_NAME, index, index);
	}

	public void deleterange(int from, int to) {
		deleterange(DEFAULT_PROGRAM_NAME, from, to);
	}

	public void deletetoken(Token indexT) {
		deleterange(DEFAULT_PROGRAM_NAME, indexT, indexT);
	}

	public void deletetokenrange(Token from, Token to) {
		deleterange(DEFAULT_PROGRAM_NAME, from, to);
	}

	public void deleterange(string programName, int from, int to) {
		replace(programName,from,to,null);
	}

	public void deleterange(string programName, Token from, Token to) {
		replace(programName,from,to,null);
	}

	public int getLastRewriteTokenIndex() {
		return getLastRewriteTokenIndex(DEFAULT_PROGRAM_NAME);
	}

	protected int getLastRewriteTokenIndex(string programName) {
		int *I = programName in lastRewriteTokenIndexes;
		if ( I==null ) {
			return -1;
		}
		return *I;
	}

	protected void setLastRewriteTokenIndex(string programName, int i) {
		lastRewriteTokenIndexes[programName] = i;
	}

	protected RewriteOperation[]* getProgram(string name) {
		auto i = name in programs;
		if ( i==null ) {
			return initializeProgram(name);
		}
		return i;
	}

	private RewriteOperation[]* initializeProgram(string name) {
		programs[name] = null; 
		return name in programs;
	}

	public string toOriginalString() {
        fill();
		return toOriginalString(MIN_TOKEN_INDEX, size()-1);
	}

	public string toOriginalString(int start, int end) {
		char[] buf ;
		for (int i=start; i>=MIN_TOKEN_INDEX && i<=end && i<tokens.length; i++) {
			if ( get(i).getType()!=Token.EOF ) buf~=get(i).getText();
		}
		return buf.idup;
	}

	public string toString() {
        fill();
		return toString(MIN_TOKEN_INDEX, size()-1);
	}

	public string toString(string programName) {
        fill();
		return toString(programName, MIN_TOKEN_INDEX, size()-1);
	}

	public string toString(int start, int end) {
		return toString(DEFAULT_PROGRAM_NAME, start, end);
	}

	public string toString(string programName, int start, int end) {
		auto rewrites = programName in programs;;

        // ensure start/end are in range
        if ( end>tokens.length-1 ) end = tokens.length-1;
        if ( start<0 ) start = 0;

        if ( rewrites==null || (*rewrites).length==0 ) {
			return toOriginalString(start,end); // no instructions to execute
		}
		char[] buf ;

		// First, optimize instruction stream
		RewriteOperation[int] indexToOp = reduceToSingleOperationPerIndex(*rewrites);

        // Walk buffer, executing instructions and emitting tokens
        int i = start;
        while ( i <= end && i < tokens.length ) {
			RewriteOperation op = cast(RewriteOperation)indexToOp[i];
			indexToOp.remove(i); // remove so any left have index size-1
			Token t = cast (Token) tokens[i];
			if ( op is null ) {
				// no operation at that index, just dump token
				if ( t.getType()!=Token.EOF ) buf~=t.getText();
				i++; // move to next token
			}
			else {
				i = op.execute(buf.idup); // execute operation and skip
			}
		}

        // include stuff after end if it's last index in buffer
        // So, if they did an insertAfter(lastValidIndex, "foo"), include
        // foo if end==lastValidIndex.
        if ( end==tokens.length-1 ) {
            // Scan any remaining operations after last token
            // should be included (they will be inserts).
            //Iterator it = indexToOp.values().iterator();
            foreach (op; indexToOp) {
                //RewriteOperation op = cast(RewriteOperation)it.next();
                if ( op.index >= tokens.length-1 ) buf~=op.text;
            }
        }
        return buf.idup;
	}

	/** We need to combine operations and report invalid operations (like
	 *  overlapping replaces that are not completed nested).  Inserts to
	 *  same index need to be combined etc...   Here are the cases:
	 *
	 *  I.i.u I.j.v								leave alone, nonoverlapping
	 *  I.i.u I.i.v								combine: Iivu
	 *
	 *  R.i-j.u R.x-y.v	| i-j in x-y			delete first R
	 *  R.i-j.u R.i-j.v							delete first R
	 *  R.i-j.u R.x-y.v	| x-y in i-j			ERROR
	 *  R.i-j.u R.x-y.v	| boundaries overlap	ERROR
	 *
	 *  Delete special case of replace (text==null):
	 *  D.i-j.u D.x-y.v	| boundaries overlap	combine to max(min)..max(right)
	 *
	 *  I.i.u R.x-y.v | i in (x+1)-y			delete I (since insert before
	 *											we're not deleting i)
	 *  I.i.u R.x-y.v | i not in (x+1)-y		leave alone, nonoverlapping
	 *  R.x-y.v I.i.u | i in x-y				ERROR
	 *  R.x-y.v I.x.u 							R.x-y.uv (combine, delete I)
	 *  R.x-y.v I.i.u | i not in x-y			leave alone, nonoverlapping
	 *
	 *  I.i.u = insert u before op @ index i
	 *  R.x-y.u = replace x-y indexed tokens with u
	 *
	 *  First we need to examine replaces.  For any replace op:
	 *
	 * 		1. wipe out any insertions before op within that range.
	 *		2. Drop any replace op before that is contained completely within
	 *         that range.
	 *		3. Throw exception upon boundary overlap with any previous replace.
	 *
	 *  Then we can deal with inserts:
	 *
	 * 		1. for any inserts to same index, combine even if not adjacent.
	 * 		2. for any prior replace with same left boundary, combine this
	 *         insert with replace and delete this replace.
	 * 		3. throw exception if index in same range as previous replace
	 *
	 *  Don't actually delete; make op null in list. Easier to walk list.
	 *  Later we can throw as we add to index -> op map.
	 *
	 *  Note that I.2 R.2-2 will wipe out I.2 even though, technically, the
	 *  inserted stuff would be before the replace range.  But, if you
	 *  add tokens in front of a method body '{' and then delete the method
	 *  body, I think the stuff before the '{' you added should disappear too.
	 *
	 *  Return a map from token index to operation.
	 */
	protected RewriteOperation  [int] reduceToSingleOperationPerIndex(RewriteOperation[] rewrites) {
//		System.out.println("rewrites="+rewrites);

		// WALK REPLACES
		for (int i = 0; i < rewrites.length; i++) {
			RewriteOperation op = cast(RewriteOperation)rewrites[i];
			if ( op is null ) continue;
			if (cast(ReplaceOp)op is null ) continue;
			ReplaceOp rop = cast(ReplaceOp)rewrites[i];
			// Wipe prior inserts within range
			RewriteOperation[] inserts = getKindOfOps(rewrites, InsertBeforeOp.classinfo, i);
			for (int j = 0; j < inserts.length; j++) {
				InsertBeforeOp iop = cast(InsertBeforeOp) inserts[j];
				if ( iop.index == rop.index ) {
					// E.g., insert before 2, delete 2..2; update replace
					// text to include insert before, kill insert
					rewrites[iop.instructionIndex] = null;
					rop.text = iop.text ~ (rop.text!=null?rop.text:"");
				}
				else if ( iop.index > rop.index && iop.index <= rop.lastIndex ) {
                    // delete insert as it's a no-op.
                    rewrites[iop.instructionIndex] = null;
				}
			}
			// Drop any prior replaces contained within
			RewriteOperation[] prevReplaces = getKindOfOps(rewrites, ReplaceOp.classinfo, i);
			for (int j = 0; j < prevReplaces.length; j++) {
				ReplaceOp prevRop = cast(ReplaceOp) prevReplaces[j];
				if ( prevRop.index>=rop.index && prevRop.lastIndex <= rop.lastIndex ) {
                    // delete replace as it's a no-op.
                    rewrites[prevRop.instructionIndex] =  null;
					continue;
				}
				// throw exception unless disjoint or identical
				bool disjoint =
					prevRop.lastIndex<rop.index || prevRop.index > rop.lastIndex;
				bool same =
					prevRop.index==rop.index && prevRop.lastIndex==rop.lastIndex;
				// Delete special case of replace (text==null):
				// D.i-j.u D.x-y.v	| boundaries overlap	combine to max(min)..max(right)
				if ( prevRop.text==null && rop.text==null && !disjoint ) {
					//System.out.println("overlapping deletes: "+prevRop+", "+rop);
					rewrites[prevRop.instructionIndex] =  null; // kill first delete
					rop.index = min(prevRop.index, rop.index);
					rop.lastIndex = max(prevRop.lastIndex, rop.lastIndex);
					stdout.writeln("new rop "~rop.toString());
				}
				else if ( !disjoint && !same ) {
					throw new IllegalArgumentException("replace op boundaries of "~rop.toString()~
													   " overlap with previous "~prevRop.toString());
				}
			}
		}

		// WALK INSERTS
		for (int i = 0; i < rewrites.length; i++) {
			RewriteOperation op = cast(RewriteOperation)rewrites[i];
			if ( op is null ) continue;
			if ( cast(InsertBeforeOp)op is null  ) continue;
			InsertBeforeOp iop = cast(InsertBeforeOp)rewrites[i];
			// combine current insert with prior if any at same index
			RewriteOperation[] prevInserts = getKindOfOps(rewrites, InsertBeforeOp.classinfo, i);
			for (int j = 0; j < prevInserts.length; j++) {
				InsertBeforeOp prevIop = cast(InsertBeforeOp) prevInserts[j];
				if ( prevIop.index == iop.index ) { // combine objects
					// convert to strings...we're in process of toString'ing
					// whole token buffer so no lazy eval issue with any templates
					iop.text = iop.text ~ prevIop.text ;//catOpText(iop.text,);
                    // delete redundant prior insert
                    rewrites[prevIop.instructionIndex] = null;
				}
			}
			// look for replaces where iop.index is in range; error
			RewriteOperation[] prevReplaces = getKindOfOps(rewrites, ReplaceOp.classinfo, i);
			for (int j = 0; j < prevReplaces.length; j++) {
				ReplaceOp rop = cast(ReplaceOp) prevReplaces[j];
				if ( iop.index == rop.index ) {
					rop.text = iop.text~ rop.text ;//catOpText(iop.text,rop.text);
					rewrites[i] = null;  // delete current insert
					continue;
				}
				if ( iop.index >= rop.index && iop.index <= rop.lastIndex ) {
					throw new IllegalArgumentException("insert op "~iop.toString()~
													   " within boundaries of previous "~rop.toString());
				}
			}
		}
		// System.out.println("rewrites after="+rewrites);
		RewriteOperation  [int] m;
		for (int i = 0; i < rewrites.length; i++) {
			RewriteOperation op = cast(RewriteOperation)rewrites[i];
			if ( op is null ) continue; // ignore deleted ops
			if ( (op.index in m) != null) {
				throw new Error("should only be one op per index");
			}
			m[op.index] = op;
		}
		//System.out.println("index to op: "+m);
		return m;
	}

	protected string catOpText(Object a, Object b) {
		string x = "";
		string y = "";
		if ( a! is null ) x = a.toString();
		if ( b! is null ) y = b.toString();
		return x~y;
	}
	protected RewriteOperation[] getKindOfOps(RewriteOperation[] rewrites, object.TypeInfo_Class kind) {
		return getKindOfOps(rewrites, kind, rewrites.length);
	}

    /** Get all operations before an index of a particular kind */
    protected RewriteOperation[] getKindOfOps(RewriteOperation[] rewrites, TypeInfo_Class kind, int before) {
		RewriteOperation[] ops;
		for (int i=0; i<before && i<rewrites.length; i++) {
			RewriteOperation op = cast(RewriteOperation)rewrites[i];
			if ( op is null ) continue; // ignore deleted
			if ( op.classinfo == kind ) ops~=op;
		}		
		return ops;
	}

	public string toDebugString() {
		return toDebugString(MIN_TOKEN_INDEX, size()-1);
	}

	public string toDebugString(int start, int end) {
		char[] buf;
		for (int i=start; i>=MIN_TOKEN_INDEX && i<=end && i<tokens.length; i++) {
			buf~=get(i).toString();
		}
		return buf.idup;
	}
}
