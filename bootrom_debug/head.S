#include "common.h"
#include "macro.S"
#include "page.S"

#define SR_RX_FIFO_VALID_DATA   (1 << 0) /* data in receive FIFO */
#define SR_RX_FIFO_FULL         (1 << 1) /* receive FIFO full */
#define SR_TX_FIFO_EMPTY        (1 << 2) /* transmit FIFO empty */
#define SR_TX_FIFO_FULL         (1 << 3) /* transmit FIFO full */

.section .text.start, "ax", @progbits
.globl _start
_start:
     j _hang


.section .text.hang, "ax", @progbits
.globl _hang
_hang:
      li s0, BOOTROM_MEM_ADDR
      li t0, 0xdeadbeaf
      add s0, s0, t0
      ld t1, 0x00(s0)
      sd t0, 0xff(s0)
      wfi                   # should get to this point

_hang_:
    li t0, 0x00FFFFFFFFFFFFFF > 4;
    csrw pmpaddr0, t0
    wfi
