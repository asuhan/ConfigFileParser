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
module antlr.runtime.ANTLRFileStream;

private import antlr.runtime.ANTLRStringStream;
private import std.stream;
private import std.file;
debug(antlrfilestream) private import std.stdio;

/** This is a char buffer stream that is loaded from a file
 *  all at once when you construct the object.  This looks very
 *  much like an ANTLReader or ANTLRInputStream, but it's a special case
 *  since we know the exact size of the object to load.  We can avoid lots
 *  of data copying. 
 */
public class ANTLRFileStream : ANTLRStringStream {
	protected string fileName;

	public this(string fileName)  {
		this(fileName, null);
	}

	public this(string fileName, string encoding)  {
		this.fileName = fileName;
		load(fileName, encoding);
	}

	public void load(string fileName, string encoding)
		
	{
		if ( fileName=="" ) {
			return;
		}
	
		//int size = cast(int)getSize(fileName);
		//InputStreamReader isr;
		//File fis = new File(fileName);
		if ( encoding!="" ) {
			//isr = new InputStreamReader(fis, encoding);
			throw new Exception("encoding is not supported/implemented in ANTLRFileStream");
		}
		else {
			//isr = new InputStreamReader(fis);
		}
		try {
			data = cast(char[])read(fileName);//[size];
			debug(antlrfilestream) writeln("Input source:",data);
			super.n = cast(int)data.length;
		}
		finally {
			//fis.close();
		}
	}

	public string getSourceName() {
		return fileName;
	}
}
