//
// cubedemo/src/main.c: Rotating cube demo (entry point).
//
// n64chain: A (free) open-source N64 development toolchain.
// Copyright 2014-15 Tyler J. Stachecki <tstache1@binghamton.edu>
//
// This file is subject to the terms and conditions defined in
// 'LICENSE', which is part of this source code package.
//

#include "src/graphics.h"
#include <rcp/rsp.h>
#include <rcp/vi.h>
#include <stddef.h>
#include <stdint.h>

extern volatile uint32_t __rsp;

//
// Application layout:
//
// Bank 1: 0x0000 0000 -> 0x000F FFFF ( ROM CODE/DATA )
// Bank 2: 0x0010 0000 -> 0x001F FFFF ( FRAMEBUFFER A )
// Bank 3: 0x0020 0000 -> 0x002F FFFF ( FRAMEBUFFER B )
// Bank 4: 0x0030 0000 -> 0x003F FFFF (STACK/MISC DATA)
//

//
// These pre-defined values are suitable for NTSC.
// TODO: Add support for PAL and PAL-M televisions.
//
static vi_state_t vi_state = {
	0x0000324E, // status
	0x00100000, // origin
	0x00000140, // width
	0x00000002, // intr
	0x00000000, // current
	0x03E52239, // burst
	0x0000020D, // v_sync
	0x00000C15, // h_sync
	0x0C150C15, // leap
	0x006C02EC, // h_start
	0x002501FF, // v_start
	0x000E0204, // v_burst
	0x00000200, // x_scale
	0x00000400, // y_scale
};

// Application entry point.
int main() {
  uintptr_t ucode_addr;

  // Put RSP into a known state.
  while (rsp_is_dma_pending());

  rsp_set_status(
    RSP_STATUS_SET_HALT |
    RSP_STATUS_CLEAR_BROKE |
    RSP_STATUS_CLEAR_INTR |
    RSP_STATUS_CLEAR_SSTEP |
    RSP_STATUS_SET_INTR_ON_BREAK |
    RSP_STATUS_CLEAR_SIGNAL_0 |
    RSP_STATUS_CLEAR_SIGNAL_1 |
    RSP_STATUS_CLEAR_SIGNAL_2 |
    RSP_STATUS_CLEAR_SIGNAL_3 |
    RSP_STATUS_CLEAR_SIGNAL_4 |
    RSP_STATUS_CLEAR_SIGNAL_5 |
    RSP_STATUS_CLEAR_SIGNAL_6 |
    RSP_STATUS_CLEAR_SIGNAL_7
  );

  // DMA the ucode into the RSP.
  ucode_addr = (uintptr_t) &rsp_ucode & 0x03EFFFFF;

  rsp_issue_dma_to_rsp(ucode_addr + 0x0000, 0x0000, 0x1000 - 0x1);
  while (rsp_is_dma_pending());

  rsp_issue_dma_to_rsp(ucode_addr + 0x1000, 0x1000, 0x1000 - 0x1);
  while (rsp_is_dma_pending());

  // Enable the VI.
  vi_flush_state(&vi_state);

  // Start the RSP.
  rsp_set_pc(0x0000);
  rsp_set_status(RSP_STATUS_CLEAR_HALT);

  // We'll just spin indefinitely after returning...
  return 0;
}

