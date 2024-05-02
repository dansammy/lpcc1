%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>        // Include for math functions

void yyerror(const char *s);
int yylex(void);
extern int yylineno;    // External declaration if using %option yylineno in Flex

double vars[256];       // Simple variable storage based on ASCII index
%}

%union {
    double num;         // For numerical values
    char* var;          // For variable names
}

%token <var> VARIABLE
%token <num> NUMBER
%token SIN COS
%token PLUS MINUS TIMES DIVIDE
%token LPAREN RPAREN
%token EQUALS SEMICOLON

%type <num> expression term factor
%type <var> assignment

%%
input:
      | input line
      ;

line:
      assignment SEMICOLON { printf("%s = %f\n", $1, vars[$1[0]]); }
    | error SEMICOLON      { yyerror("syntax error"); }
    ;

assignment:
      VARIABLE EQUALS expression { vars[$1[0]] = $3; $$ = $1; }
    ;

expression:
      expression PLUS term   { $$ = $1 + $3; }
    | expression MINUS term  { $$ = $1 - $3; }
    | term                   { $$ = $1; }
    ;

term:
      term TIMES factor      { $$ = $1 * $3; }
    | term DIVIDE factor     { $$ = $1 / $3; }
    | factor                 { $$ = $1; }
    ;

factor:
      NUMBER                 { $$ = $1; }
    | VARIABLE               { $$ = vars[$1[0]]; }
    | LPAREN expression RPAREN { $$ = $2; }
    | SIN LPAREN expression RPAREN { $$ = sin($3); }
    | COS LPAREN expression RPAREN { $$ = cos($3); }
    ;

%%
void yyerror(const char *s) {
    fprintf(stderr, "Error near line %d: %s\n", yylineno, s);
}

int main(void) {
    printf("Enter expressions (e.g., 'u = sin(12) + cos(12);'):\n");
    yyparse();
    return 0;
}