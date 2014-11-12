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

module antlr.runtime.BufferedTokenStream;

private import antlr.runtime.TokenStream;
private import antlr.runtime.TokenSource;
private import antlr.runtime.Token;
private import antlr.runtime.BitSet;
private import antlr.runtime.JavaExceptions;
private import std.conv;
private import std.array;
private import std.stdio;

/*import java.util.List;
import java.util.ArrayList;
import java.util.NoSuchElementException;*/

/** Buffer all input tokens but do on-demand fetching of new tokens from
 *  lexer. Useful when the parser or lexer has to set context/mode info before
 *  proper lexing of future tokens. The ST template parser needs this,
 *  for example, because it has to constantly flip back and forth between
 *  inside/output templates. E.g., <names:{hi, <it>}> has to parse names
 *  as part of an expression but "hi, <it>" as a nested template.
 *
 *  You can't use this stream if you pass whitespace or other off-channel
 *  tokens to the parser. The stream can't ignore off-channel tokens.
 *  (UnbufferedTokenStream is the same way.)
 *
 *  This is not a subclass of UnbufferedTokenStream because I don't want
 *  to confuse small moving window of tokens it uses for the full buffer.
 */
public class BufferedTokenStream : TokenStream {
    protected TokenSource tokenSource;

    /** Record every single token pulled from the source so we can reproduce
     *  chunks of it later.  The buffer in LookaheadStream overlaps sometimes
     *  as its moving window moves through the input.  This list captures
     *  everything so we can access complete input text.
     */
    protected Token[] tokens ;//= new ArrayList<Token>(100);

    /** Track the last mark() call result value for use in rewind(). */
    protected int lastMarker;

    /** The index into the tokens list of the current token (next token
     *  to consume).  tokens[p] should be LT(1).  p=-1 indicates need
     *  to initialize with first token.  The ctor doesn't get a token.
     *  First call to LT(1) or whatever gets the first token and sets p=0;
     */
    protected int p = -1;

	protected int range = -1; // how deep have we gone?

    public this() {;}

    public this(TokenSource tokenSource) {
        this.tokenSource = tokenSource;
    }

    public TokenSource getTokenSource() { return tokenSource; }

	public int index() { return p; }

	public int getRange() { return range; }

    public int mark() {
        if ( p == -1 ) setup();
		lastMarker = index();
		return lastMarker;
	}

	public void release(int marker) {
		// no resources to release
	}

    public void rewind(int marker) {
        seek(marker);
    }

    public void rewind() {
        seek(lastMarker);
    }

    public void reset() {
        p = 0;
        lastMarker = 0;
    }

    public void seek(int index) { p = index; }

    public int size() { return cast(int)tokens.length; }

    /** Move the input pointer to the next incoming token.  The stream
     *  must become active with LT(1) available.  consume() simply
     *  moves the input pointer so that LT(1) points at the next
     *  input symbol. Consume at least one token.
     *
     *  Walk past any token not on the channel the parser is listening to.
     */
    public void consume() {
        if ( p == -1 ) setup();
        p++;
        sync(p);
    }

    /** Make sure index i in tokens has a token. */
    protected void sync(int i) {
        int n = i - cast(int)tokens.length + 1; // how many more elements we need?
        //System.out.println("sync("+i+") needs "+n);
        if ( n > 0 ) fetch(n);
    }

    /** add n elements to buffer */
    protected void fetch(int n) {
        for (int i=1; i<=n; i++) {
            Token t = tokenSource.nextToken();
            t.setTokenIndex(cast(int)tokens.length);
            //System.out.println("adding "+t+" at index "+tokens.size());
            tokens~= t;
            if ( t.getType()==Token.EOF ) break;
        }
    }

    public Token get(int i) {
        if ( i < 0 || i >= tokens.length ) {
            throw new NoSuchElementException("token index "~to!string(i)~" out of range 0.."~to!string(tokens.length-1));
        }
        return tokens[i];
    }

	/** Get all tokens from start..stop inclusively */
	public Token[] get(int start, int stop) {
		if ( start<0 || stop<0 ) return null;
		if ( p == -1 ) setup();
		Token[] subset ;// = new ArrayList();
		if ( stop>=tokens.length ) stop = cast(int)tokens.length-1;
		for (int i = start; i <= stop; i++) {
			Token t = tokens[i];
			if ( t.getType()==Token.EOF ) break;
			subset~=t;
		}
		return subset;
	}

	public int LA(int i) 
	{ 
	debug(tokenla) 
	{
	 auto t=LT(i).getType();
	 writeln("token LA(",i,"):",t);
	 return t;
	}
	else
	return LT(i).getType(); 
	
	}

    protected Token LB(int k) {
        if ( (p-k)<0 ) return null;
        return tokens[p-k];
    }

    public Token LT(int k) {
      
        if ( p == -1 ) setup();
        if ( k==0 ) {  debug(tokenla)  writeln("token LT(",k,"):null"); return null;}
        if ( k < 0 ) 
        {
          debug(tokenla)  writeln("token LT(",k,"):",LB(-k));
          return LB(-k);
        }

	int i = p + k - 1;
	sync(i);
		
        if ( i >= tokens.length ) { // return EOF token
            // EOF must be last token
            debug(tokenla) 
	{
	 writeln("token LT(",k,"):",tokens[tokens.length-1]);
	}
            return tokens[tokens.length-1];
        }
        
	if ( i>range ) range = i; 	
	
	debug(tokenla) 
	{
	 writeln("token LT(",k,"):",tokens[i]);
	}	
        return tokens[i];
    }

    protected void setup() { sync(0); p = 0; }

    /** Reset this token stream by setting its token source. */
    public void setTokenSource(TokenSource tokenSource) {
        this.tokenSource = tokenSource;
        tokens.clear();
        p = -1;
    }
    
    public Token[] getTokens() { return tokens; }

    public Token[] getTokens(int start, int stop) {
        return getTokens(start, stop, cast(BitSet)null);
    }

    /** Given a start and stop index, return a List of all tokens in
     *  the token type BitSet.  Return null if no tokens were found.  This
     *  method looks at both on and off channel tokens.
     */
    public Token[] getTokens(int start, int stop, BitSet types) {
        if ( p == -1 ) setup();
        if ( stop>=tokens.length ) stop=cast(int)tokens.length-1;
        if ( start<0 ) start=0;
        if ( start>stop ) return null;

        // list = tokens[start:stop]:{Token t, t.getType() in types}
        Token[] filteredTokens ;//= new ArrayList<Token>();
        for (int i=start; i<=stop; i++) {
            Token t = tokens[i];
            if ( types is null || types.member(t.getType()) ) {
                filteredTokens~=t;
            }
        }
        if ( filteredTokens.length==0 ) {
            filteredTokens = null;
        }
        return filteredTokens;
    }

    public Token[] getTokens(int start, int stop, int[] types) {
        return getTokens(start,stop,new BitSet(types));
    }

    public Token[] getTokens(int start, int stop, int ttype) {
        return getTokens(start,stop,BitSet.of(ttype));
    }

    public string getSourceName() {	return tokenSource.getSourceName();	}

    /** Grab *all* tokens from stream and return string */
    public string toString() {
        if ( p == -1 ) setup();
        fill();
        return toString(0, cast(int)tokens.length-1);
    }

    public string toString(int start, int stop) {
        if ( start<0 || stop<0 ) return null;
        if ( p == -1 ) setup();
        if ( stop>=tokens.length ) stop = cast(int)tokens.length-1;
        auto buf = appender!string;// new StringBuffer();
        for (int i = start; i <= stop; i++) {
            Token t = tokens[i];
            if ( t.getType()==Token.EOF ) break;
            buf.put(t.getText());
        }
        return buf.data;
    }

    public string toString(Token start, Token stop) {
        if ( start is null && stop is null ) {
            return toString(start.getTokenIndex(), stop.getTokenIndex());
        }
        return null;
    }

    /** Get all tokens from lexer until EOF */
    public void fill() {
        if ( p == -1 ) setup();
        if ( tokens[p].getType()==Token.EOF ) return;

        int i = p+1;
        sync(i);
        while ( tokens[i].getType()!=Token.EOF ) {
            i++;
            sync(i);
        }
    }
}
