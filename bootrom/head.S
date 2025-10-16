#include "common.h"

#define MIP_MSIP (1 << 3)

.section .text.start, "ax", @progbits
.globl _start
_start:
    wfi
    j _start

.section .text.hang, "ax", @progbits
.globl _hang
_hang:
  csrr a0, mhartid
  beqz a0, _start_bootrom
  wfi
  j _hang

.section .text.start_bootrom
_start_bootrom:

    

    li t1, 0x2020000
    // Set pmpcfg0 and cfg2
    li a0, 0x00003F1F
    // Store pmpcfg{0..3}
    sd a0, 0x10(t1)
    // pmpaddr0 value 0x80001000
    li a0, 0x200001FF
    sd a0, 0x18(t1)
    // pmpaddr0 value 0x80002000
    li a0, 0x200005FF
    sd a0, 0x08(t1)

    li t1, 0x2010000
    // Set pmpcfg0 and cfg2
    li a0, 0x00003F1F
    sd a0, 0x0(t1)
    // pmpaddr0 value 0x80001000
    li a0, 0x200001FF
    //#sd a0, 0x40(s1)
    sd a0, 0x80(t1) // Chance this from 0x00
    // pmpaddr0 value 0x80002000
    li a0, 0x200005FF
    sd a0, 0x88(t1) // Change this from 0x000

    li t0, 0x80001000
    sd a0, 0(t0)
    li t0, 0x80000000
    sd a0, 0(t0)
    li t0, 0x80002000
    sd a0, 0(t0)
    li t0, 0x80003000
    sd a0, 0(t0)
    li a0, 0x80004000
    sd a0, 0(t0)


    nop
    wfi
