#ifndef DSL_JSON_AST_H
#define DSL_JSON_AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ASTNode {
    char *type;
    char *key;
    union {
        double num;
        char *str;
        int boolean;
        struct ASTNode *child;
    } value;
    struct ASTNode *next;
} ASTNode;

typedef struct Token {
    char *type;
    char *value;
    int line_number;
    struct Token *next;
} Token;

extern Token *token_list;
extern ASTNode *ast_root;

ASTNode* create_node(char *type, char *key);
void print_ast(ASTNode *node, int indent);
void free_ast(ASTNode *node);

void add_token(const char *type, const char *value, int line_number);
void print_tokens();
void print_symbol_table();
void free_tokens();

int is_duplicate(const char *value);

#endif
