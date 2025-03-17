**Commands to Run:**
  1. flex lexer.l
  2. bison -t -d -o dsl_json_parser.tab.c parser.y
  3. gcc lex.yy.c dsl_json_parser.tab.c dsl_json_ast.c -o json_parser
  4. Get-Content test.json | ./json_parser.exe
