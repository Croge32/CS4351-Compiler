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

Yylex(java.io.InputStream s, ErrorMsg e) {
  this(s);
  errorMsg=e;
}

private int nested = 0;
private String string = "";

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

<YYINITIAL> "function" {return tok{sym.FUNCTION, null);}
<YYINITIAL> "else" {return tok{sym.ELSE, null);}
<YYINITIAL> "nil" {return tok{sym.NIL, null);}
<YYINITIAL> "do" {return tok{sym.DO, null);}
<YYINITIAL> "of" {return tok{sym.OF, null);}
<YYINITIAL> "array" {return tok{sym.ARRAY, null);}
<YYINITIAL> "type" {return tok{sym.TYPE, null);}
<YYINITIAL> "for" {return tok{sym.FOR, null);}
<YYINITIAL> "to" {return tok{sym.TO, null);}
<YYINITIAL> "in" {return tok{sym.IN, null);}
<YYINITIAL> "end" {return tok{sym.END, null);}
<YYINITIAL> "if" {return tok{sym.IF, null);}
<YYINITIAL> "while" {return tok{sym.WHILE, null);}
<YYINITIAL> "var" {return tok{sym.VAR, null);}
<YYINITIAL> "break" {return tok{sym.BREAK, null);}
<YYINITIAL> "let" {return tok{sym.LET, null);}
<YYINITIAL> "then" {return tok{sym.THEN, null);}

<YYINITIAL> [0-9]+ {return tok{sym.INT, null);}
<YYINITIAL> [a-zA-Z][a-zA-Z0-9_]* {return tok{sym.ID, null);}

<YYINITIAL> ","	{return tok(sym.COMMA, null);}
<YYINITIAL> ":" {return tok{sym.COLON, null);}
<YYINITIAL> "<>" {return tok{sym.NEQ, null);}
<YYINITIAL> ">" {return tok{sym.GT, null);}
<YYINITIAL> "<" {return tok{sym.LT, null);}
<YYINITIAL> ">=" {return tok{sym.GE, null);}
<YYINITIAL> "<=" {return tok{sym.LE, null);}
<YYINITIAL> "=" {return tok{sym.EQ, null);}
<YYINITIAL> ":=" {return tok{sym.ASSIGN, null);}
<YYINITIAL> "/" {return tok{sym.DIVIDE, null);}
<YYINITIAL> "-" {return tok{sym.MINUS, null);}
<YYINITIAL> "*" {return tok{sym.TIMES, null);}
<YYINITIAL> "+" {return tok{sym.PLUS, null);}
<YYINITIAL> ";" {return tok{sym.SEMICOLON, null);}
<YYINITIAL> "(" {return tok{sym.LPAREN, null);}
<YYINITIAL> ")" {return tok{sym.RPAREN, null);}
<YYINITIAL> "{" {return tok{sym.LBRACE, null);}
<YYINITIAL> "}" {return tok{sym.RBRACE, null);}
<YYINITIAL> "[" {return tok{sym.LBRACK, null);}
<YYINITIAL> "]" {return tok{sym.RBRACK, null);}
<YYINITIAL> "." {return tok{sym.DOT, null);}
<YYINITIAL> "&" {return tok{sym.AND, null);}
<YYINITIAL> "|" {return tok{sym.OR, null);}

<YYINITIAL> "\"" {yybegin(STRING);}
<STRING> [a-zA-Z0-9_\s] {string = string + yytext();}
<STRING> "\n" {}
<STRING> "\t" {}
<STRING> "\^c" {} // if (ch >= '@'' && ch <= '_') ch = ch - '@' 
<STRING> "\ddd" {}
<STRING> "\\"" {}
<STRING> "\\\" {}

<STRING> "\\f...f\\" {yybegin(IGNORE);}
<IGNORE> {}

<STRING> "\"" {return tok(sym.STRING, string);}


. { err("Illegal character: " + yytext()); }
