#
# Makefile for n64chain ROMs.
#
# n64chain: A (free) open-source N64 development toolchain.
# Copyright 2014 Tyler J. Stachecki <tstache1@binghamton.edu>
#
# This file is subject to the terms and conditions defined in
# 'LICENSE', which is part of this source code package.
#

ROM_NAME = $(notdir $(shell pwd))

AS = $(shell pwd)/../tools/bin/mips64-elf-as
AR = $(shell pwd)/../tools/bin/mips64-elf-gcc-ar
CC = $(shell pwd)/../tools/bin/mips64-elf-gcc
OBJCOPY = $(shell pwd)/../tools/bin/mips64-elf-objcopy

CHECKSUM = $(shell pwd)/../tools/bin/checksum
RSPASM = $(shell pwd)/../rspasm/rspasm

CFLAGS = -Wall -Wextra -pedantic -std=c99 \
	-I../libn64/include -I../libn64 -I.
OPTFLAGS = -Os -march=vr4300 -flto -ffat-lto-objects \
	-mgpopt -G8 -mno-extern-sdata

ASMFILES = \
	src/graphics.S

CFILES = \
	src/main.c

UCODES = \
	src/graphics.rsp

OBJFILES = \
	$(ASMFILES:.S=.o) \
	$(CFILES:.c=.o)

UCODEBINS = $(UCODES:.rsp=.bin)
DEPFILES = $(OBJFILES:.o=.d)

#
# Primary targets.
#
all: $(ROM_NAME).z64

$(ROM_NAME).z64: $(ROM_NAME).elf
	@echo "Building: $@"
	@$(OBJCOPY) -O binary $< $@
	@$(CHECKSUM) ../libn64/header.bin $@

$(ROM_NAME).elf: libn64 $(OBJFILES)
	@echo "Building: $@"
	$(CC) $(CFLAGS) $(OPTFLAGS) -Wl,-Map=$(ROM_NAME).map -nostdlib \
		-T../libn64/rom.ld -o $@ $(OBJFILES) -L../libn64 -ln64

#
# Generic compilation/assembly targets.
#

src/graphics.o: src/graphics.S src/graphics.bin
	@echo "Assembling: $<"
	@$(CC) $(CFLAGS) $(OPTFLAGS) -MMD -c $< -o $@

%.o: %.S
	@echo "Assembling: $<"
	@$(CC) $(CFLAGS) $(OPTFLAGS) -MMD -c $< -o $@

%.o: %.c
	@echo "Compiling: $<"
	$(CC) $(CFLAGS) $(OPTFLAGS) -MMD -c $< -o $@

%.bin: %.rsp
	@echo "Assembling: $<"
	@$(RSPASM) -o $@ $<

.PHONY: libn64
libn64:
	@$(MAKE) -sC ../libn64

#
# Clean project target.
#
.PHONY: clean
clean:
	@echo "Cleaning..."
	@$(RM) $(ROM_NAME).map $(ROM_NAME).elf $(ROM_NAME).z64 \
		$(DEPFILES) $(OBJFILES) $(UCODEBINS)

#
# Use computed dependencies.
#
-include $(DEPFILES)

