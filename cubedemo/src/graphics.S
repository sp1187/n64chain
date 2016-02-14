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

#
# Invoked on a VI interrupt.
#
.text
.global __interrupt_handler
.type __interrupt_handler, @function
__interrupt_handler:
  lui $k0, 0xA440

  # Clear the active VI interrupt.
  lw $k1, 0x0010($k0)
  sw $k1, 0x0010($k0)

  # Set VI origin to the next frame.
  #
  # If VI_ORIGIN_REG is 0x0010 0000, set it to 0x0020 0000.
  # If VI_ORIGIN_REG is 0x0020 0000, set it to 0x0010 0000.
  lw $k1, 0x0004($k0)
  srl $k1, $k1, 0x15

.set noreorder
  beql $k1, $0, __interrupt_handler_continue
  ori $k1, $0, 0x2
.set reorder

__interrupt_handler_continue:
  sll $k1, $k1, 0x14
  sw $k1, 0x0004($k0)

  # Tell MI to reset???
  lui $k0, 0xA430
  ori $k1, $0, 0x0595
  sw $k1, 0x000C($k0)

  # Return from exception.
  eret

.size __interrupt_handler,.-__interrupt_handler

