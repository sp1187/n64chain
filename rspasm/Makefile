#
# rspasm/Makefile: RSP assembler Makefile.
#
# n64chain: A (free) open-source N64 development toolchain.
# Copyright 2014-15 Tyler J. Stachecki <tstache1@binghamton.edu>
#
# This file is subject to the terms and conditions defined in
# 'LICENSE', which is part of this source code package.
#

BISON = bison
FLEX = flex

CFLAGS = -Wall -Wextra -Wno-unused-parameter -pedantic -std=c99 -I. -D_POSIX_C_SOURCE
OPTFLAGS = -ggdb3 -g3

CFILES = \
	emitter.c \
	lexer.c \
	main.c \
	parser.c \
	symbols.c

OBJFILES = \
	$(CFILES:.c=.o)

DEPFILES = $(OBJFILES:.o=.d)

all: rspasm

rspasm: $(OBJFILES)
	@echo "Linking: $@"
	@$(CC) $(CFLAGS) $(OPTFLAGS) $^ -o $@

parser.c: parser.y
	@echo "Generating: rspasm/$@"
	@$(BISON) -d -o $@ $<

lexer.c: lexer.l parser.c
	@echo "Generating: rspasm/$@"
	@$(FLEX) --bison-bridge --yylineno --header-file=lexer.h -o $@ $<

#
# Generic compilation/assembly targets.
#
%.o: %.c parser.c lexer.c
	@echo "Compiling: rspasm/$<"
	@$(CC) $(CFLAGS) $(OPTFLAGS) -MMD -c $< -o $@

#
# Clean project target.
#
.PHONY: clean
clean:
	@echo "Cleaning rspasm..."
	@$(RM) $(DEPFILES) $(OBJFILES) lexer.c lexer.h parser.c parser.h

