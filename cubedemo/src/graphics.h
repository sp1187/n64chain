//
// cubedemo/src/graphics.h: RSP microcode for cubedemo.
//
// n64chain: A (free) open-source N64 development toolchain.
// Copyright 2014-15 Tyler J. Stachecki <tstache1@binghamton.edu>
//
// This file is subject to the terms and conditions defined in
// 'LICENSE', which is part of this source code package.
//

#ifndef CUBEDEMO_GRAPHICS_H
#define CUBEDEMO_GRAPHICS_H
#include <stdint.h>

extern uint8_t *rsp_ucode;

extern void __interrupt_handler(uint32_t cause);

#endif

