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
        li sp,BOOTROM_MEM_END
        li a0, UART_BASE
        li t1, SR_TX_FIFO_FULL
1:      lw t0, 8(a0)              # status
        and t0, t0,  t1
        bnez t0, 1b

        li t2, 0x5A
        sb t2,  4(a0)


.section .text.hang, "ax", @progbits
.globl _hang
_hang:
        li sp,BOOTROM_MEM_END
        li a0, UART_BASE
        li t1, SR_TX_FIFO_FULL
1:      lw t0, 8(a0)              # status
        and t0, t0,  t1
        bnez t0, 1b

        li t2, 0x41
        sb t2,  4(a0)

        // # pmpaddr_.address[53-0] = address[55:2]
        li t0, (0x00FFFFFFFFFFFFFF >> 2)  # 4  bytes align
        csrw  pmpaddr0, t0
        li t0, 0b00001111                 # looaaxwr
        csrw  pmpcfg0, t0

        // # Set Machine Trap Vector
        la t0, _machine_trap
        csrw mtvec, t0

        // # setup Virtual memory
        li a0, UART_BASE
        li t2, 0x42
        sb t2,  4(a0)
        call _init_root_pagetable

        li a0, UART_BASE
        li t2, 0x43
        sb t2,  4(a0)
        call _init_satp

        // # Jump to supervisory mode
        li a0, UART_BASE
        li t2, 0x44
        sb t2,  4(a0)
        csrr t0 , mstatus

        // # c
        li t1, 0xFFFFFFFFFFFFEF7F  # clear bit 12 and 7
        and t1, t1, t0
        li t2, (1 << 11)
        or t1, t1, t2              # set bit 11

        csrw mstatus, t1

        la t0, _supervisory_mode_start
         // li t1, 0x3FFFFFFF     # mask PPM[2]
         // and t0, t0, t1
         csrw mepc, t0         # Supervisor Exception Program Counter

         li a0, UART_BASE
         li t2, 0x45
         sb t2,  4(a0)
         mret
         wfi                   # should get to this point

.align 4
_machine_trap:
    li a0, UART_BASE
    li t1, SR_TX_FIFO_FULL
1:  lw t0, 8(a0)              # status
    and t0, t0,  t1
    bnez t0, 1b

    li t2, 0x50
    sb t2,  4(a0)

    wfi

_supervisory_mode_start:
    li a0, UART_BASE
    li t1, SR_TX_FIFO_FULL
1:  lw t0, 8(a0)              # status
    and t0, t0,  t1
    bnez t0, 1b

    li t2, 0x60
    sb t2,  4(a0)

    wfi

