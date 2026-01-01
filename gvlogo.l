/* Kahlan Walcott*/
%{
#include <stdio.h>
#include <stdlib.h>
#include "gvlogo.tab.h"

extern void yyerror(const char* s);
%}

%%
[0-9]+      { yylval.f = atof(yytext); return NUMBER; }
end         { return END; }
=           { return EQUALS; }
\+          { return PLUS; }
-           { return SUB; }
\*          { return MULT; }
\/          { return DIV; }

\$[A-Z]     { yylval.var = yytext[1] - 65; return VARIABLE; }
\".+\"		{ yylval.str = yytext; return QSTRING; }
[A-Za-z]+\.[a-z]{3}    { yylval.str = strdup(yytext); return STRING; }
;           { return SEP; } 

(penup|PENUP)       { return PENUP; }
(pendown|PENDOWN)   { return PENDOWN; }
(print|PRINT)       { return PRINT; }
(save|SAVE)         { yylval.str = yytext; return SAVE; }
(color|COLOR)       { return COLOR; }
(change_color|CHANGE_COLOR) { return CHANGE_COLOR; }
(clear|CLEAR)       { return CLEAR; }
(turn|TURN)         { return TURN; }
(move|MOVE)         { return MOVE; }
(goto|GOTO)         { return GOTO; }
(where|WHERE)       { return WHERE; }

[ \t\r\n]+	;
.			{ yyerror("Lexing Syntax error.\n"); } 

%%

int yywrap(void) {
    return 1;
}
