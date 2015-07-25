#
# libn64/Makefile: Makefile for libn64.
#
# n64chain: A (free) open-source N64 development toolchain.
# Copyright 2014-15 Tyler J. Stachecki <tstache1@binghamton.edu>
#
# This file is subject to the terms and conditions defined in
# 'LICENSE', which is part of this source code package.
#

AS = $(shell pwd)/../tools/bin/mips64-elf-as
AR = $(shell pwd)/../tools/bin/mips64-elf-gcc-ar
CC = $(shell pwd)/../tools/bin/mips64-elf-gcc

CFLAGS = -Wall -Wextra -pedantic -std=c99 -I. -Iinclude
OPTFLAGS = -Os -march=vr4300 -flto -ffat-lto-objects \
	-mgpopt -G8 -mno-extern-sdata

ASMFILES = \
	libc/crt0.S

CFILES =

OBJFILES = \
	$(ASMFILES:.S=.o) \
	$(CFILES:.c=.o)

DEPFILES = $(OBJFILES:.o=.d)

#
# Primary targets.
#
libn64.a: $(OBJFILES)
	@echo "Building: libn64/$@"
	@$(AR) rcs $@ $^

#
# Generic compilation/assembly targets.
#
%.o: %.S
	@echo "Assembling: libn64/$<"
	@$(CC) $(CFLAGS) $(OPTFLAGS) -MMD -c $< -o $@

%.o: %.c
	@echo "Compiling: libn64/$<"
	@$(CC) $(CFLAGS) $(OPTFLAGS) -MMD -c $< -o $@

#
# Clean project target.
#
.PHONY: clean
clean:
	@echo "Cleaning libn64..."
	@$(RM) libn64.a $(DEPFILES) $(OBJFILES)

