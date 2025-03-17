%{
#include "dsl_json_ast.h"
#include "dsl_json_parser.tab.h"
extern int yylineno;
%}

%option noyywrap
%option yylineno

WHITESPACE      [ \t\r\n]
STRING_LITERAL  \"([^\\\"]|\\.)*\" 
NUMBER_LITERAL  -?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?
BOOLEAN         true|false
NULL            null
TYPE            "type"
PROPERTIES      "properties"
REQUIRED        "required"

%%

{WHITESPACE}    { /* Ignore */ }
{STRING_LITERAL} {
    add_token("STRING", yytext, yylineno);
    int len = yyleng - 2;
    yylval.str = (char*)malloc(len + 1);
    strncpy(yylval.str, yytext + 1, len);
    yylval.str[len] = '\0';
    return STRING;
}
{NUMBER_LITERAL} {
    add_token("NUMBER", yytext, yylineno);
    yylval.num = atof(yytext);
    return NUMBER;
}
{BOOLEAN} {
    add_token("BOOLEAN", yytext, yylineno);
    yylval.boolean = (strcmp(yytext, "true") == 0);
    return BOOLEAN;
}
{NULL} { add_token("NULL", "null", yylineno); return NULL_LITERAL; }
{TYPE} { add_token("TYPE", "type", yylineno); return TYPE; }
{PROPERTIES} { add_token("PROPERTIES", "properties", yylineno); return PROPERTIES; }
{REQUIRED} { add_token("REQUIRED", "required", yylineno); return REQUIRED; }
"{" { return '{'; }
"}" { return '}'; }
"[" { return '['; }
"]" { return ']'; }
":" { return ':'; }
"," { return ','; }
. {
    fprintf(stderr, "Lexical error at line %d: Invalid character '%s'\n", yylineno, yytext);
    exit(1);
}
