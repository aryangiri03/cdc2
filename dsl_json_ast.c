#include "dsl_json_ast.h"

Token *token_list = NULL;

ASTNode* create_node(char *type, char *key) {
    ASTNode *node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->key = key ? strdup(key) : NULL;
    node->value.child = NULL;
    node->next = NULL;
    return node;
}

int is_duplicate(const char *value) {
    ASTNode *temp = ast_root;
    while (temp) {
        if (strcmp(temp->value.str, value) == 0) {
            return 1; // Found duplicate
        }
        temp = temp->next;
    }
    return 0;
}

void print_ast(ASTNode *node, int indent) {
    if (!node) return;

    for (int i = 0; i < indent; i++) {
        printf(i == indent - 1 ? "|-- " : "|  ");
    }

    if (node->key) printf("%s: ", node->key);
    printf("%s", node->type);

    if (strcmp(node->type, "string") == 0) printf(" (%s)", node->value.str);
    else if (strcmp(node->type, "number") == 0) printf(" (%f)", node->value.num);
    else if (strcmp(node->type, "boolean") == 0) printf(" (%s)", node->value.boolean ? "true" : "false");

    printf("\n");

    if (node->value.child) print_ast(node->value.child, indent + 1);
    if (node->next) print_ast(node->next, indent);
}

void free_ast(ASTNode *node) {
    if (!node) return;
    free_ast(node->value.child);
    free_ast(node->next);
    free(node->type);
    if (node->value.str) 
    free(node->value.str);
    if (node->key) free(node->key);
    free(node);
}

// Token Management
void add_token(const char *type, const char *value, int line_number) {
    Token *new_token = (Token*)malloc(sizeof(Token));
    new_token->type = strdup(type);
    new_token->value = strdup(value);
    new_token->line_number = line_number;
    new_token->next = NULL;

    if (!token_list) {
        token_list = new_token;
    } else {
        Token *current = token_list;
        while (current->next) current = current->next;
        current->next = new_token;
    }
}

void print_tokens() {
    printf("\n1. Tokens:\n\n");
    printf("Token Type\tToken Value\tLine Number\n");
    printf("-------------------------------------------\n");

    Token *current = token_list;
    while (current) {
        printf("%-12s %-15s %d\n", current->type, current->value, current->line_number);
        current = current->next;
    }
}

void print_symbol_table() {
    printf("\n2. Symbol Table:\n\n");
    printf("Token Type\tToken Value\tLine Number\n");
    printf("-------------------------------------------\n");

    Token *current = token_list;
    while (current) {
        printf("%-12s %-15s %d\n", current->type, current->value, current->line_number);
        current = current->next;
    }
}

void free_tokens() {
    Token *current = token_list;
    while (current) {
        Token *temp = current;
        free(temp->type);
        free(temp->value);
        current = current->next;
        free(temp);
    }
}
