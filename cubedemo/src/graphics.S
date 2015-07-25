#
# cubedemo/src/graphics.S: RSP microcode for cubedemo.
#
# n64chain: A (free) open-source N64 development toolchain.
# Copyright 2014 Tyler J. Stachecki <tstache1@binghamton.edu>
#
# This file is subject to the terms and conditions defined in
# 'LICENSE', which is part of this source code package.
#

.file "src/graphics.S"
.section .rodata
.align 3

.global rsp_ucode
.type rsp_ucode, @object

rsp_ucode:
.incbin "src/graphics.bin"
.size rsp_ucode,.-rsp_ucode

