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
module antlr.runtime.tree.BaseTreeAdaptor;

private import antlr.runtime.Token;
private import antlr.runtime.TokenStream;
private import antlr.runtime.RecognitionException;
private import antlr.runtime.tree.TreeAdaptor;
private import antlr.runtime.tree.Tree;
private import antlr.runtime.tree.CommonErrorNode;
private import antlr.runtime.JavaExceptions;


/** A TreeAdaptor that works with any Tree implementation. */
public abstract class BaseTreeAdaptor : TreeAdaptor {
	/** System.identityHashCode() is not always unique; we have to
	 *  track ourselves.  That's ok, it's only for debugging, though it's
	 *  expensive: we have to create a hashtable with all tree nodes in it.
	 */
	protected int[Object] treeToUniqueIDMap;
	protected int uniqueNodeID = 1;

	public Object nil() {
		return create(null);
	}

	/** create tree node that holds the start and stop tokens associated
	 *  with an error.
	 *
	 *  If you specify your own kind of tree nodes, you will likely have to
	 *  override this method. CommonTree returns Token.INVALID_TOKEN_TYPE
	 *  if no token payload but you might have to set token type for diff
	 *  node type.
     *
     *  You don't have to subclass CommonErrorNode; you will likely need to
     *  subclass your own tree node class to avoid class cast exception.
	 */
	public Object errorNode(TokenStream input, Token start, Token stop,
							RecognitionException e)
	{
		CommonErrorNode t = new CommonErrorNode(input, start, stop, e);
		//System.out.println("returning error node '"+t+"' @index="+input.index());
		return t;
	}

	public bool isNil(Object tree) {
		return (cast(Tree)tree).isNil();
	}

	public Object dupTree(Object tree) {
		return dupTree(tree, null);
	}

	/** This is generic in the sense that it will work with any kind of
	 *  tree (not just Tree interface).  It invokes the adaptor routines
	 *  not the tree node routines to do the construction.  
	 */
	public Object dupTree(Object t, Object parent) {
		if ( t is null ) {
			return null;
		}
		Object newTree = dupNode(t);
		// ensure new subtree root has parent/child index set
		setChildIndex(newTree, getChildIndex(t)); // same index in new tree
		setParent(newTree, parent);
		int n = getChildCount(t);
		for (int i = 0; i < n; i++) {
			Object child = getChild(t, i);
			Object newSubTree = dupTree(child, t);
			addChild(newTree, newSubTree);
		}
		return newTree;
	}

	/** Add a child to the tree t.  If child is a flat tree (a list), make all
	 *  in list children of t.  Warning: if t has no children, but child does
	 *  and child isNil then you can decide it is ok to move children to t via
	 *  t.children = child.children; i.e., without copying the array.  Just
	 *  make sure that this is consistent with have the user will build
	 *  ASTs.
	 */
	public void addChild(Object t, Object child) {
		if ( t!is null && child!is null ) {
			(cast(Tree)t).addChild(cast(Tree)child);
		}
	}

	/** If oldRoot is a nil root, just copy or move the children to newRoot.
	 *  If not a nil root, make oldRoot a child of newRoot.
	 *
	 *    old=^(nil a b c), new=r yields ^(r a b c)
	 *    old=^(a b c), new=r yields ^(r ^(a b c))
	 *
	 *  If newRoot is a nil-rooted single child tree, use the single
	 *  child as the new root node.
	 *
	 *    old=^(nil a b c), new=^(nil r) yields ^(r a b c)
	 *    old=^(a b c), new=^(nil r) yields ^(r ^(a b c))
	 *
	 *  If oldRoot was null, it's ok, just return newRoot (even if isNil).
	 *
	 *    old=null, new=r yields r
	 *    old=null, new=^(nil r) yields ^(nil r)
	 *
	 *  Return newRoot.  Throw an exception if newRoot is not a
	 *  simple node or nil root with a single child node--it must be a root
	 *  node.  If newRoot is ^(nil x) return x as newRoot.
	 *
	 *  Be advised that it's ok for newRoot to point at oldRoot's
	 *  children; i.e., you don't have to copy the list.  We are
	 *  constructing these nodes so we should have this control for
	 *  efficiency.
	 */
	public Object becomeRoot(Object newRoot, Object oldRoot) {
        //System.out.println("becomeroot new "+newRoot.toString()+" old "+oldRoot);
        Tree newRootTree = cast(Tree)newRoot;
		Tree oldRootTree = cast(Tree)oldRoot;
		if ( oldRoot is null ) {
			return newRoot;
		}
		// handle ^(nil real-node)
		if ( newRootTree.isNil() ) {
            int nc = newRootTree.getChildCount();
            if ( nc==1 ) newRootTree = cast(Tree)newRootTree.getChild(0);
            else if ( nc >1 ) {
				// TODO: make tree run time exceptions hierarchy
				throw new RuntimeException("more than one node as root (TODO: make exception hierarchy)");
			}
        }
		// add oldRoot to newRoot; addChild takes care of case where oldRoot
		// is a flat list (i.e., nil-rooted tree).  All children of oldRoot
		// are added to newRoot.
		newRootTree.addChild(oldRootTree);
		return cast(Object)newRootTree;
	}

	/** Transform ^(nil x) to x and nil to null */
	public Object rulePostProcessing(Object root) {
		//System.out.println("rulePostProcessing: "+(cast(Tree)root).toStringTree());
		Tree r = cast(Tree)root;
		if ( r!is null && r.isNil() ) {
			if ( r.getChildCount()==0 ) {
				r = null;
			}
			else if ( r.getChildCount()==1 ) {
				r = cast(Tree)r.getChild(0);
				// whoever invokes rule will set parent and child index
				r.setParent(null);
				r.setChildIndex(-1);
			}
		}
		return cast(Object)r;
	}

	public Object becomeRoot(Token newRoot, Object oldRoot) {
		return becomeRoot(create(newRoot), oldRoot);
	}

	public Object create(int tokenType, Token fromToken) {
		fromToken = createToken(fromToken);
		//((ClassicToken)fromToken).setType(tokenType);
		fromToken.setType(tokenType);
		Tree t = cast(Tree)create(fromToken);
		return cast(Object)t;
	}

	public Object create(int tokenType, Token fromToken, string text) {
        if (fromToken is null) return create(tokenType, text);
		fromToken = createToken(fromToken);
		fromToken.setType(tokenType);
		fromToken.setText(text);
		Tree t = cast(Tree)create(fromToken);
		return cast(Object)t;
	}

	public Object create(int tokenType, string text) {
		Token fromToken = createToken(tokenType, text);
		Tree t = cast(Tree)create(fromToken);
		return cast(Object)t;
	}

        

        public Object create(Token payload)
        {
           throw new NoSuchMethodError("don't know enough about create in BaseTreeAdaptor");
           return null;
        }

	public int getType(Object t) {
		return (cast(Tree)t).getType();
	}

	public void setType(Object t, int type) {
		throw new NoSuchMethodError("don't know enough about Tree node");
	}

	public string getText(Object t) {
		return (cast(Tree)t).getText();
	}

	public void setText(Object t, string text) {
		throw new NoSuchMethodError("don't know enough about Tree node");
	}

	public Object getChild(Object t, int i) {
		return cast(Object)(cast(Tree)t).getChild(i);
	}

	public void setChild(Object t, int i, Object child) {
		(cast(Tree)t).setChild(i, cast(Tree)child);
	}

	public Object deleteChild(Object t, int i) {
		return cast(Object)(cast(Tree)t).deleteChild(i);
	}

	public int getChildCount(Object t) {
		return (cast(Tree)t).getChildCount();
	}

	public int getUniqueID(Object node) {
		//if ( treeToUniqueIDMap==null ) {
		//	 treeToUniqueIDMap = new HashMap();
		//}
		auto prevID = node in treeToUniqueIDMap;
		if ( prevID!=null ) {
			return *prevID;
		}
		int ID = uniqueNodeID;
		treeToUniqueIDMap[node]=ID;
		uniqueNodeID++;
		return ID;
		// GC makes these nonunique:
		// return System.identityHashCode(node);
	}

	/** Tell me how to create a token for use with imaginary token nodes.
	 *  For example, there is probably no input symbol associated with imaginary
	 *  token DECL, but you need to create it as a payload or whatever for
	 *  the DECL node as in ^(DECL type ID).
	 *
	 *  If you care what the token payload objects' type is, you should
	 *  override this method and any other createToken variant.
	 */
	public abstract Token createToken(int tokenType, string text);

	/** Tell me how to create a token for use with imaginary token nodes.
	 *  For example, there is probably no input symbol associated with imaginary
	 *  token DECL, but you need to create it as a payload or whatever for
	 *  the DECL node as in ^(DECL type ID).
	 *
	 *  This is a variant of createToken where the new token is derived from
	 *  an actual real input token.  Typically this is for converting '{'
	 *  tokens to BLOCK etc...  You'll see
	 *
	 *    r : lc='{' ID+ '}' -> ^(BLOCK[$lc] ID+) ;
	 *
	 *  If you care what the token payload objects' type is, you should
	 *  override this method and any other createToken variant.
	 */
	public abstract Token createToken(Token fromToken);
}

