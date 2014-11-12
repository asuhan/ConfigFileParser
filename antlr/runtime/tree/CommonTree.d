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
module antlr.runtime.tree.CommonTree;

private import antlr.runtime.Token;
private import antlr.runtime.tree.Tree;
private import antlr.runtime.tree.BaseTree;

/** A tree node that is wrapper for a Token object.  After 3.0 release
 *  while building tree rewrite stuff, it became clear that computing
 *  parent and child index is very difficult and cumbersome.  Better to
 *  spend the space in every tree node.  If you don't want these extra
 *  fields, it's easy to cut them out in your own BaseTree subclass.
 */
public class CommonTree : BaseTree {
	/** A single token is the payload */
	public Token token;

	/** What token indexes bracket all tokens associated with this node
	 *  and below?
	 */
	protected int startIndex=-1, stopIndex=-1;

	/** Who is the parent node of this node; if null, implies node is root */
	public CommonTree parent;

	/** What index is this node in the child list? Range: 0..n-1 */
	public int childIndex = -1;

	public this() { }
	
	public this(CommonTree node) {
		super(node);
		this.token = node.token;
		this.startIndex = node.startIndex;
		this.stopIndex = node.stopIndex;
	}

	public this(Token t) {
		this.token = t;
	}

	public Token getToken() {
		return token;
	}

	public Tree dupNode() {
		return new CommonTree(this);
	}

	public bool isNil() {
		return token is null;
	}

	public int getType() {
		if ( token is null ) {
			return Token.INVALID_TOKEN_TYPE;
		}
		return token.getType();
	}

	public string getText() {
		if ( token is null ) {
			return null;
		}
		return token.getText();
	}

	public int getLine() {
		if ( token is null || token.getLine()==0 ) {
			if ( getChildCount()>0 ) {
				return getChild(0).getLine();
			}
			return 0;
		}
		return token.getLine();
	}

	public int getCharPositionInLine() {
		if ( token is null || token.getCharPositionInLine()==-1 ) {
			if ( getChildCount()>0 ) {
				return getChild(0).getCharPositionInLine();
			}
			return 0;
		}
		return token.getCharPositionInLine();
	}

	public int getTokenStartIndex() {
		if ( startIndex==-1 && token! is null ) {
			return token.getTokenIndex();
		}
		return startIndex;
	}

	public void setTokenStartIndex(int index) {
		startIndex = index;
	}

	public int getTokenStopIndex() {
		if ( stopIndex==-1 && token! is null ) {
			return token.getTokenIndex();
		}
		return stopIndex;
	}

	public void setTokenStopIndex(int index) {
		stopIndex = index;
	}

    /** For every node in this subtree, make sure it's start/stop token's
     *  are set.  Walk depth first, visit bottom up.  Only updates nodes
     *  with at least one token index < 0.
     */
    public void setUnknownTokenBoundaries() {
        if ( children==null ) {
            if ( startIndex<0 || stopIndex<0 ) {
                startIndex = stopIndex = token.getTokenIndex();
            }
            return;
        }
        for (int i=0; i<children.length; i++) {
            (cast(CommonTree)children[i]).setUnknownTokenBoundaries();
        }
        if ( startIndex>=0 && stopIndex>=0 ) return; // already set
        if ( children.length > 0 ) {
            CommonTree firstChild = cast(CommonTree)children[0];
            CommonTree lastChild = cast(CommonTree)children[children.length-1];
            startIndex = firstChild.getTokenStartIndex();
            stopIndex = lastChild.getTokenStopIndex();
        }
    }

	public int getChildIndex() {
		return childIndex;
	}

	public Tree getParent() {
		return parent;
	}

	public void setParent(Tree t) {
		this.parent = cast(CommonTree)t;
	}

	public void setChildIndex(int index) {
		this.childIndex = index;
	}

	public string toString() {
		if ( isNil() ) {
			return "nil";
		}
		if ( getType()==Token.INVALID_TOKEN_TYPE ) {
			return "<errornode>";
		}
		if ( token is null ) {
			return null;
		}
		return token.getText();
	}
}
