package Parse;
import ErrorMsg.ErrorMsg;

%% 

%implements Lexer
%function nextToken
%type java_cup.runtime.Symbol
%char

%{
private void newline() {
  errorMsg.newline(yychar);
}

private void err(int pos, String s) {
  errorMsg.error(pos,s);
}

private void err(String s) {
  err(yychar,s);
}

private java_cup.runtime.Symbol tok(int kind) {
    return tok(kind, null);
}

private java_cup.runtime.Symbol tok(int kind, Object value) {
    return new java_cup.runtime.Symbol(kind, yychar, yychar+yylength(), value);
}

private ErrorMsg errorMsg;

private int nested = 0;
private String string;
private char ch;

Yylex(java.io.InputStream s, ErrorMsg e) {
  this(s);
  errorMsg=e;
}

%}

%eofval{
	{
	 return tok(sym.EOF, null);
  }
%eofval}

%state COMMENT
%state STRING
%state IGNORE

%%
<YYINITIAL> " "	{}
<YYINITIAL> \n	{newline();}

<YYINITIAL> "/*" {yybegin(COMMENT);}
<COMMENT> "/*" { nested++; yybegin(COMMENT); }
<COMMENT> "*/" {
  if(nested >= 1) { nested--; }
  else {yybegin(YYINITIAL);}
}
<COMMENT> . {}

<YYINITIAL> "function" {return tok(sym.FUNCTION);}
<YYINITIAL> "else" {return tok(sym.ELSE);}
<YYINITIAL> "nil" {return tok(sym.NIL);}
<YYINITIAL> "do" {return tok(sym.DO);}
<YYINITIAL> "of" {return tok(sym.OF);}
<YYINITIAL> "array" {return tok(sym.ARRAY);}
<YYINITIAL> "type" {return tok(sym.TYPE);}
<YYINITIAL> "for" {return tok(sym.FOR);}
<YYINITIAL> "to" {return tok(sym.TO);}
<YYINITIAL> "in" {return tok(sym.IN);}
<YYINITIAL> "end" {return tok(sym.END);}
<YYINITIAL> "if" {return tok(sym.IF);}
<YYINITIAL> "while" {return tok(sym.WHILE);}
<YYINITIAL> "var" {return tok(sym.VAR);}
<YYINITIAL> "break" {return tok(sym.BREAK);}
<YYINITIAL> "let" {return tok(sym.LET);}
<YYINITIAL> "then" {return tok(sym.THEN);}

<YYINITIAL> [0-9]+ {return tok(sym.INT, new Integer(yytext()));}
<YYINITIAL> [a-zA-Z][a-zA-Z0-9_]* {return tok(sym.ID, yytext());}

<YYINITIAL> ","	{return tok(sym.COMMA, null);}
<YYINITIAL> ":" {return tok(sym.COLON, null);}
<YYINITIAL> "<>" {return tok(sym.NEQ, null);}
<YYINITIAL> ">" {return tok(sym.GT, null);}
<YYINITIAL> "<" {return tok(sym.LT, null);}
<YYINITIAL> ">=" {return tok(sym.GE, null);}
<YYINITIAL> "<=" {return tok(sym.LE, null);}
<YYINITIAL> "=" {return tok(sym.EQ, null);}
<YYINITIAL> ":=" {return tok(sym.ASSIGN, null);}
<YYINITIAL> "/" {return tok(sym.DIVIDE, null);}
<YYINITIAL> "-" {return tok(sym.MINUS, null);}
<YYINITIAL> "*" {return tok(sym.TIMES, null);}
<YYINITIAL> "+" {return tok(sym.PLUS, null);}
<YYINITIAL> ";" {return tok(sym.SEMICOLON, null);}
<YYINITIAL> "(" {return tok(sym.LPAREN, null);}
<YYINITIAL> ")" {return tok(sym.RPAREN, null);}
<YYINITIAL> "{" {return tok(sym.LBRACE, null);}
<YYINITIAL> "}" {return tok(sym.RBRACE, null);}
<YYINITIAL> "[" {return tok(sym.LBRACK, null);}
<YYINITIAL> "]" {return tok(sym.RBRACK, null);}
<YYINITIAL> "." {return tok(sym.DOT, null);}
<YYINITIAL> "&" {return tok(sym.AND, null);}
<YYINITIAL> "|" {return tok(sym.OR, null);}

<YYINITIAL> \" {string = ""; yybegin(STRING);}

<STRING> \" {yybegin(YYINITIAL); return tok(sym.STRING, string);}
<STRING> \\ {yybegin(IGNORE);}
<STRING> . {string += yytext(); }

<IGNORE> "^"[A-Za-z] {
	StringBuffer s = new StringBuffer(yytext());
	char ch = s.charAt(1);
	int chInt = ch;
	int a = 'a';
	int z = 'z';
	if(chInt >= a && chInt <= z) {
		chInt -= 32;
	}
	int at = '@';
	int u = '_';
	if(chInt >= at && chInt <= u) {
		chInt -= at;
	}
	ch = (char) chInt;
	string += ch;
	yybegin(STRING);
}
<IGNORE> n {string += "\n"; yybegin(STRING);}
<IGNORE> t {string += "\t"; yybegin(STRING);}
<IGNORE> [0-9][0-9][0-9] {
	StringBuffer s = new StringBuffer(yytext());
	String sub = "";
	if (s.charAt(0) == '0' && s.charAt(1) == '0') {
		sub = s.substring(2);
	} else if (s.charAt(0) == '0') {
		sub = s.substring(1);
	} else {
		sub = yytext();
	}
	int num = Integer.parseInt(sub);
	char c = (char) num;	
	string += c;
	yybegin(STRING);
}
<IGNORE> [0-9]|[0-9][0-9] {
	yybegin(STRING);
	err("Illegal escape sequence: "+yytext());
}
<IGNORE> \" {string += "\""; yybegin(STRING);}
<IGNORE> \\ { yybegin(STRING);}
<IGNORE> [\f\s\n\t]+ {}

. { err("Illegal fella: " + yytext()); }
