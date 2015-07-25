%{
//
// rspasm/parser.y: RSP assembler parser.
//
// n64chain: A (free) open-source N64 development toolchain.
// Copyright 2014-15 Tyler J. Stachecki <tstache1@binghamton.edu>
//
// This file is subject to the terms and conditions defined in
// 'LICENSE', which is part of this source code package.
//

#define YYDEBUG 0
int yydebug = 0;
%}

// Global state: be gone.
%define api.pure full
%define api.prefix {rspasm}
%lex-param { yyscan_t scanner }
%parse-param { yyscan_t scanner }
%locations

%union {
  char identifier[32];
  long int constant;
  enum rsp_opcode opcode;
  unsigned reg;
}

%code requires {
#include "opcodes.h"
#include "rspasm.h"

#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void *yyscan_t;
#endif
}

%code {
#include "emitter.h"
#include "lexer.h"
#include <stdio.h>
#include <stdlib.h>

// Raised on a parser error.
int yyerror(YYLTYPE *yylloc, yyscan_t scanner, const char *error) {
  //struct rspasm *rspasm = rspasmget_extra(scanner);

  fprintf(stderr, "line %d: Parse error.\n", yylloc->first_line);
  return 0;
}
}

%token COLON
%token COMMA
%token CONSTANT
%token DIVIDE
%token DOTALIGN
%token DOTBOUND
%token DOTBYTE
%token DOTDATA
%token DOTDMAX
%token DOTEND
%token DOTENT
%token DOTHALF
%token DOTNAME
%token DOTPRINT
%token DOTSPACE
%token DOTSYMBOL
%token DOTTEXT
%token DOTUNNAME
%token DOTWORD
%token IDENTIFIER
%token LEFT_BRACKET
%token LEFT_PAREN
%token OPCODE
%token OPCODE_JALR //
%token OPCODE_R //
%token OPCODE_RRC0
%token OPCODE_RI
%token OPCODE_RO
%token OPCODE_RR //
%token OPCODE_RRI
%token OPCODE_RRR
%token OPCODE_RRS //
%token OPCODE_RRT //
%token OPCODE_RT //
%token OPCODE_RZ2 //
%token OPCODE_RZ2E //
%token OPCODE_T //
%token OPCODE_VO_LWC2 //
%token OPCODE_VO_SWC2 //
%token OPCODE_VV //
%token OPCODE_VVV //
%token OP_AND
%token OP_BNOT
%token OP_DIVIDE
%token OP_LSHIFT
%token OP_MINUS
%token OP_MOD
%token OP_OR
%token OP_PLUS
%token OP_RSHIFT
%token OP_TIMES
%token OP_XOR
%token RIGHT_BRACKET
%token RIGHT_PAREN
%token SCALAR_REG
%token VOPCODE

%left OP_AND
%left OP_DIVIDE
%left OP_LSHIFT
%left OP_MINUS
%left OP_MOD
%left OP_OR
%left OP_PLUS
%left OP_RSHIFT
%left OP_TIMES
%left OR_XOR

%right OP_BNOT

%type <constant> constexpr CONSTANT
%type <opcode> OPCODE OPCODE_RI OPCODE_RO OPCODE_RRC0 OPCODE_RRI OPCODE_RRR
               VOPCODE
%type <reg> SCALAR_REG

%%

toplevel:
  | program;

program:
    instruction
  | program instruction
  ;

instruction:
    directive
  | scalar_instruction
  | vector_instruction
  ;

directive:
    DOTALIGN constexpr
  | DOTBOUND constexpr
  | DOTBYTE constexpr {
      if (rspasm_emit_byte(rspasmget_extra(scanner), &yyloc, $2))
        return EXIT_FAILURE;
    }

  | DOTDATA constexpr
  | DOTDMAX constexpr {
      if (rspasm_dmax_assert(rspasmget_extra(scanner), &yyloc, $2))
        return EXIT_FAILURE;
    }

  | DOTHALF constexpr {
      if (rspasm_emit_half(rspasmget_extra(scanner), &yyloc, $2))
        return EXIT_FAILURE;
    }

  | DOTWORD constexpr {
      if (rspasm_emit_word(rspasmget_extra(scanner), &yyloc, $2))
        return EXIT_FAILURE;
    }

  | DOTDATA { ((struct rspasm *) rspasmget_extra(scanner))->in_text = false; }
  | DOTTEXT { ((struct rspasm *) rspasmget_extra(scanner))->in_text = true; }
  ;

scalar_instruction:
    OPCODE {
      if (rspasm_emit_instruction(rspasmget_extra(scanner), &yyloc, $1))
        return EXIT_FAILURE;
    }

    | OPCODE_RI SCALAR_REG COMMA constexpr {
      if (rspasm_emit_instruction_ri(
        rspasmget_extra(scanner), &yyloc, $1, $2, $4))
        return EXIT_FAILURE;
    }

    | OPCODE_RO SCALAR_REG COMMA constexpr LEFT_PAREN SCALAR_REG RIGHT_PAREN {
      if (rspasm_emit_instruction_ro(
        rspasmget_extra(scanner), &yyloc, $1, $2, $4, $6))
        return EXIT_FAILURE;
    }

    | OPCODE_RRC0 SCALAR_REG COMMA SCALAR_REG {
      if (rspasm_emit_instruction_rrc0(
        rspasmget_extra(scanner), &yyloc, $1, $2, $4))
        return EXIT_FAILURE;
    }

    | OPCODE_RRI SCALAR_REG COMMA SCALAR_REG COMMA constexpr {
      if (rspasm_emit_instruction_rri(
        rspasmget_extra(scanner), &yyloc, $1, $2, $4, $6))
        return EXIT_FAILURE;
    }

    | OPCODE_RRR SCALAR_REG COMMA SCALAR_REG COMMA SCALAR_REG {
      if (rspasm_emit_instruction_rrr(
        rspasmget_extra(scanner), &yyloc, $1, $2, $4, $6))
        return EXIT_FAILURE;
    }

  ;

vector_instruction:
    VOPCODE {
      if (rspasm_emit_instruction(rspasmget_extra(scanner), &yyloc, $1))
        return EXIT_FAILURE;
    }
  ;

constexpr:
    LEFT_PAREN constexpr RIGHT_PAREN { $$ = $2; }
  | CONSTANT { $$ = $1; }

  | OP_BNOT constexpr { $$ = ~$2; }

  | constexpr OP_AND constexpr { $$ = $1 & $3; }
  | constexpr OP_OR constexpr { $$ = $1 | $3; }
  | constexpr OR_XOR constexpr { $$ = $1 ^ $3; }
  | constexpr OP_LSHIFT constexpr { $$ = $1 << $3; }
  | constexpr OP_RSHIFT constexpr { $$ = $1 >> $3; }
  | constexpr OP_TIMES constexpr { $$ = $1 * $3; }
  | constexpr OP_DIVIDE constexpr { $$ = $1 / $3; }
  | constexpr OP_MOD constexpr { $$ = $1 % $3; }
  | constexpr OP_PLUS constexpr { $$ = $1 | $3; }
  | constexpr OP_MINUS constexpr { $$ = $1 - $3; }

  | OP_MINUS constexpr %prec OP_BNOT { $$ = -$2; }
  | OP_PLUS constexpr %prec OP_BNOT { $$ = +$2; }
  ;

%%

