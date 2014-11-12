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
module antlr.runtime.Parser;

private import antlr.runtime.BaseRecognizer;
private import antlr.runtime.TokenStream;
private import antlr.runtime.RecognizerSharedState;
private import antlr.runtime.IntStream;
private import antlr.runtime.RecognitionException;
private import antlr.runtime.BitSet;
private import antlr.runtime.Token;
private import antlr.runtime.CommonToken;

/** A parser for TokenStreams.  "parser grammars" result in a subclass
 *  of this.
 */
public class Parser : BaseRecognizer {
	public TokenStream input;

	public this(TokenStream input) {
		super(); // highlight that we go to super to set state object
		setTokenStream(input);
    }

	public this(TokenStream input, RecognizerSharedState state) {
		super(state); // share the state object with another parser
		this.input = input;
    }

	public void reset() {
		super.reset(); // reset all recognizer state variables
		if ( input! is null ) {
			input.seek(0); // rewind the input
		}
	}

	protected Object getCurrentInputSymbol(IntStream input) {
		return cast(Object)(cast(TokenStream)input).LT(1);
	}

	protected Object getMissingSymbol(IntStream input,
									  RecognitionException e,
									  int expectedTokenType,
									  BitSet follow)
	{
		string tokenText = null;
		if ( expectedTokenType==Token.EOF ) tokenText = "<missing EOF>";
		else tokenText = "<missing "~getTokenNames()[expectedTokenType]~">";
		CommonToken t = new CommonToken(expectedTokenType, tokenText);
		Token current = (cast(TokenStream)input).LT(1);
		if ( current.getType() == Token.EOF ) {
			current = (cast(TokenStream)input).LT(-1);
		}
                if (current !is null)
                {
		  t.setLine ( current.getLine());
		  t.setCharPositionInLine (current.getCharPositionInLine());
                  t.setInputStream (current.getInputStream());
                }
                else
                {
                  t.setLine ( 1);
		  t.setCharPositionInLine (0);         
                }

		t.setChannel (DEFAULT_TOKEN_CHANNEL);
		return t;
	}

	/** Set the token stream and reset the parser */
	public void setTokenStream(TokenStream input) {
		this.input = null;
		reset();
		this.input = input;
	}

    public TokenStream getTokenStream() {
		return input;
	}

	public string getSourceName() {
		return input.getSourceName();
	}

	public void traceIn(string ruleName, int ruleIndex)  {
		super.traceIn(ruleName, ruleIndex, cast(Object) input.LT(1));
	}

	public void traceOut(string ruleName, int ruleIndex)  {
		super.traceOut(ruleName, ruleIndex, cast(Object) input.LT(1));
	}
}
