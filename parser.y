%left ',' 
%left ':' 

%{
#include "dsl_json_ast.h"
extern int yylex();
extern int yylineno;
void yyerror(const char *s);
ASTNode *ast_root = NULL;
%}

%union {
    char *str;
    double num;
    int boolean;
    ASTNode *node;
}

%token <str> STRING
%token <num> NUMBER
%token <boolean> BOOLEAN
%token NULL_LITERAL
%token TYPE PROPERTIES REQUIRED
%token '{' '}' '[' ']' ':' ','

%type <node> schema object array value property properties_list required_list

%start schema

%%

schema:
    '{' properties_list '}' { ast_root = $2; }
    ;

properties_list:
    /* Empty */ { $$ = create_node("empty", NULL); }
    | property { $$ = $1; }
    | property ',' properties_list {
        ASTNode *node = $1;
        ASTNode *temp = node;
        while (temp->next) temp = temp->next;
        temp->next = $3;
        $$ = node;
    }
    ;

property:
    STRING ':' value { 
        ASTNode *node = create_node("property", $1);
        node->value.child = $3;
        $$ = node;
    }
    ;

value:
    STRING { $$ = create_node("string", $1); }
    | NUMBER { $$ = create_node("number", NULL); $$->value.num = $1; }
    | BOOLEAN { $$ = create_node("boolean", NULL); $$->value.boolean = $1; }
    | NULL_LITERAL { $$ = create_node("null", NULL); }
    | object { $$ = $1; }
    | array { $$ = $1; }
    ;

object:
    '{' properties_list '}' {
        ASTNode *node = create_node("object", NULL);
        node->value.child = $2;
        $$ = node;
    }
    ;

array:
    '[' required_list ']' {
        ASTNode *node = create_node("array", NULL);
        node->value.child = $2;
        $$ = node;
    }
    ;

required_list:
    /* Empty */ { $$ = NULL; }
    | STRING {
        if (!is_duplicate($1)) {
            $$ = create_node("required", $1);
        } else {
            $$ = NULL;
        }
    }
    | STRING ',' required_list {
        if (!is_duplicate($1)) {
            ASTNode *node = create_node("required", $1);
            node->next = $3;
            $$ = node;
        } else {
            $$ = $3;
        }
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
    exit(1);
}

int main() {
    extern int yydebug;
    yydebug = 1;
    yyparse();
    print_tokens();
    print_symbol_table();
    printf("\nIntermediate Representation (AST):\n");
    print_ast(ast_root, 0);
    free_ast(ast_root);
    free_tokens();
    return 0;
}
    