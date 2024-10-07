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
     li t0, 0x01
     sd to, 0(0x0800000000)


.section .text.hang, "ax", @progbits
.globl _hang
_hang:
         wfi                   # should get to this point

