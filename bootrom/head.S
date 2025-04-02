#include "common.h"

#define MIP_MSIP (1 << 3)

.section .text.start, "ax", @progbits
.globl _start
_start:
  csrr a0, mhartid
  la a1, _dtb
  la s0, _ram
  jr s0
_start_bootrom:
  # a0 - hart ID
  # a1 - Device Tree
  # s0 - start of RAM and trap vector
  li s2, 0
  sw s2, 0(s0) # clear trap vector
  li sp, BOOTROM_MEM_END
  call main
  j _hang

.section .text.hang, "ax", @progbits
.globl _hang
_hang:
  csrr a0, mhartid
  la a1, _dtb
  la s0, _ram
  beqz a0, _start_bootrom
_hartx_loop:
  # write mtvec
  csrw mtvec, s0
  # enable software interrupt
  csrwi mie, MIP_MSIP
  wfi
  # only start if interrupt request is set
  csrr a2, mip
  andi a2, a2, MIP_MSIP
  beqz a2, _hartx_loop
  # jump to code in RAM
  ecall
  j _hartx_loop

.section .text.fw_pulickey, "a", @progbits
.globl _fw_publickey
_fw_publickey:

    .byte 0x0f
    .byte 0xaa 
    .byte 0xd4 
    .byte 0xff
    .byte 0x01
    .byte 0x17
    .byte 0x85
    .byte 0x83
    .byte 0xba
    .byte 0xa5
    .byte 0x88 
    .byte 0x96
    .byte 0x6f
    .byte 0x7c
    .byte 0x1f
    .byte 0xf3
    .byte 0x25
    .byte 0x64
    .byte 0xdd
    .byte 0x17
    .byte 0xd7
    .byte 0xdc
    .byte 0x2b
    .byte 0x46
    .byte 0xcb
    .byte 0x50
    .byte 0xa8
    .byte 0x4a
    .byte 0x69
    .byte 0x27
    .byte 0x0b
    .byte 0x4c


.section .rodata.dtb, "a", @progbits
.globl _dtb
.align 5, 0
_dtb:
  .incbin DEVICE_TREE


