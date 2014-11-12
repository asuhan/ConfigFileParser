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
module antlr.runtime.tree.ParseTree;

private import antlr.runtime.Token;
private import antlr.runtime.tree.BaseTree;
private import antlr.runtime.tree.Tree;



/** A record of the rules used to match a token sequence.  The tokens
 *  end up as the leaves of this tree and rule nodes are the interior nodes.
 *  This really adds no functionality, it is just an alias for CommonTree
 *  that is more meaningful (specific) and holds a String to display for a node.
 */
public class ParseTree : BaseTree {
	public Object payload;
	public Token[] hiddenTokens;

	public this(Object label) {
		this.payload = label;
	}

	public Tree dupNode() {
		return null;
	}

	public int getType() {
		return 0;
	}

	public string getText() {
		return toString();
	}

	public int getTokenStartIndex() {
		return 0;
	}

	public void setTokenStartIndex(int index) {
	}

	public int getTokenStopIndex() {
		return 0;
	}

	public void setTokenStopIndex(int index) {
	}

	public string toString() {
		if ( cast(Token)payload !is null ) {
			Token t = cast(Token)payload;
			if ( t.getType() == Token.EOF ) {
				return "<EOF>";
			}
			return t.getText();
		}
		return payload.toString();
	}

	/** Emit a token and all hidden nodes before.  EOF node holds all
	 *  hidden tokens after last real token.
	 */
	public string toStringWithHiddenTokens() {
		string buf; 
		if ( hiddenTokens!=null ) {
			for (int i = 0; i < hiddenTokens.length; i++) {
				Token hidden =  hiddenTokens[i];
				buf~=hidden.getText();
			}
		}
		string nodeText = this.toString();
		if ( nodeText!="<EOF>" ) buf~=nodeText;
		return buf;
	}

	/** Print out the leaves of this tree, which means printing original
	 *  input back out.
	 */
	public string toInputString() {
		string buf;
		_toStringLeaves(buf);
		return buf;
	}

	public void _toStringLeaves(ref string buf) {
		if ( cast(Token)payload !is null ) { // leaf node token?
			buf~=this.toStringWithHiddenTokens();
			return;
		}
		for (int i = 0; children!=null && i < children.length; i++) {
			ParseTree t = cast(ParseTree)children[i];
			t._toStringLeaves(buf);
		}
	}
}
