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
module antlr.runtime.tree.CommonErrorNode;

private import antlr.runtime.Token;
private import antlr.runtime.TokenStream;
private import antlr.runtime.tree.CommonTree;
private import antlr.runtime.RecognitionException;
private import antlr.runtime.IntStream;
private import antlr.runtime.tree.Tree;
private import antlr.runtime.tree.TreeNodeStream;
private import antlr.runtime.MissingTokenException;
private import antlr.runtime.UnwantedTokenException;
private import antlr.runtime.MismatchedTokenException;
private import antlr.runtime.NoViableAltException;
private import std.conv;


/** A node representing erroneous token range in token stream */
public class CommonErrorNode : CommonTree {
	public IntStream input;
	public Token start;
	public Token stop;
	public RecognitionException trappedException;

	public this(TokenStream input, Token start, Token stop,
						   RecognitionException e)
	{
		//System.out.println("start: "+start+", stop: "+stop);
		if ( stop is null ||
			 (stop.getTokenIndex() < start.getTokenIndex() &&
			  stop.getType()!=Token.EOF) )
		{
			// sometimes resync does not consume a token (when LT(1) is
			// in follow set.  So, stop will be 1 to left to start. adjust.
			// Also handle case where start is the first token and no token
			// is consumed during recovery; LT(-1) will return null.
			stop = start;
		}
		this.input = input;
		this.start = start;
		this.stop = stop;
		this.trappedException = e;
	}

	public bool isNil() {
		return false;
	}

	public int getType() {
		return Token.INVALID_TOKEN_TYPE;
	}

	public string getText() {
		string badText = null;
		if ( cast(Token)start !is null ) {
			int i = (cast(Token)start).getTokenIndex();
			int j = (cast(Token)stop).getTokenIndex();
			if ( (cast(Token)stop).getType() == Token.EOF ) {
				j = (cast(TokenStream)input).size();
			}
			badText = (cast(TokenStream)input).toString(i, j);
		}
		else if ( cast(Tree)start !is null ) {
			badText = (cast(TreeNodeStream)input).toString(cast(Object)start, cast(Object)stop);
		}
		else {
			// people should subclass if they alter the tree type so this
			// next one is for sure correct.
			badText = "<unknown>";
		}
		return badText;
	}

	public string toString() {
		if ( cast(MissingTokenException)trappedException !is null) {
			return "<missing type: "~
				   to!string((cast(MissingTokenException)trappedException).getMissingType())~
				   ">";
		}
		else if ( cast(UnwantedTokenException)trappedException !is null) {
			return "<extraneous: "~
				   (cast(Object)((cast(UnwantedTokenException)trappedException).getUnexpectedToken())).toString()~
				   ", resync="~getText()~">";
		}
		else if ( cast(MismatchedTokenException)trappedException !is null) {
			return "<mismatched token: "~(cast(Object)trappedException.token).toString()~", resync="~getText()~">";
		}
		else if ( cast(NoViableAltException)trappedException !is null) {
			return "<unexpected: "~(cast(Object)trappedException.token).toString()~
				   ", resync="~getText()~">";
		}
		return "<error: "~getText()~">";
	}
}
