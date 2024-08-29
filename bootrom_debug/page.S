#include "mem.S"
#include "common.h"

#define PAGE_TABLE_SIZE = 1 << 12


// # Notes
// # Supervisor Address Translation and Protection (satp)

// Sv39
// LEVEL=3
// PTE_SIZE = 8
// PAGE_SIZE = 4096
// Entries =  512
// va -> pa
// i = LEVEL-1
// a = satp.ppn * PAGE_SIZE == shift left by 12 bits, took me a while to figure this one out
// = pte = a + va.vpn[i]*PTE_SIZE


_init_satp:
  li t0, (8 << 60)          # mode = 8 = 39-bit virtual addressing
  li t1, HEAP_START        # root of page table
  srli t1, t1, 12           # PNN = _data_start >> 12
  or t1, t1 , t0        # set root of page table
  csrw satp, t1
  ret

// # a0 va
// # a1 pa
// # a2 page_order
// # a3 privilege [2-0]

_map_va_pa:
  push ra

  li t0, HEAP_START      # level 2 page table
  srli t1, a0, 30         # VPN[2]
  slli t1, t1, 3          # offset into page table; mul by 8
  add t0, t0, t1          # PTE

  li t3, 30               # page order 30
  bne a2, t3, 1f

  // # LEVEL[2]  => Page Table span 1GB address range
  srli t1, a1, 12         # PPN
  slli t1, t1, 10         # new PTE data
  slli t2, a3, 1          # Shift Rights into position
  addi t2, t2, 1          # set valid bit
  add t1, t1, t2          # add privilege to PTE & valid bit
  sd t1, 0(t0)
  j 5f                    # jmp to ret

  // # LEVEL[1] Page Table span 2MB address range
  // # t0 PTE of LEVEL[2]
  1:

// debugging
push a0
push a1
push a2
push a3
push t0

li a0, HEAP_START
//call _write_hex

pop t0
pop a3
pop a2
pop a1
pop a0
// debugging


  push a0
  push a1
  push a2
  push a3
  push t0
  // >>> walk page table to see if page have already been allocated
  srli a0, a0, 12          # VPN
  srli a1, a1, 12          # PPN
  call _walk_page_table

 //>>> check PTE

  call zalloc             # allocate 4096 page
  mv t1, a0               # pa to new page table

  pop t0
  pop a3
  pop a2
  pop a1
  pop a0

// debugging
push a0
push a1
push a2
push a3
push t0
push t1

mv a0, a2
//call _write_hex

pop t1
pop t0
pop a3
pop a2
pop a1
pop a0
// debugging

// # update Level[2] PTE

  srli t2, t1, 12         # PPN of new page table
  slli t2, t2, 10         # new PTE data
  addi t2, t2, 0x01       # only set valid bit
  sd t2, 0(t0)            # update level[2] PTE

//// debugging
//push a0
//push a1
//push a2
//push a3
//push t0
//push t1
//push t2
//
//mv a0, t2                 # PTE
//call _write_hex
//
//pop t2
//pop t1
//pop t0
//pop a3
//pop a2
//pop a1
//pop a0
//// debugging

  // # get Level[1] PTE


  srli t2, a0, 21          # VPN[2]VPN[1]
  and t2, t2, (1 << 9)-1   # VPN[1]
  slli t2, t2, 3           # offset into page table; mul by 8
  add t0, t1, t2           # PTE

  li t3, 21               # page order 21
  bne a2, t3, 4f          # jump to smaller page range

  // # update Level[1] PTE

  srli t1, a1, 12         # PPN
  slli t1, t1, 10         # new PTE data

  slli t2, a3, 1          # Shift privileges into position
  addi t2, t2, 1          # set valid bit
  add t1, t1, t2          # add privilege & valid bit to PTE
  sd t1, 0(t0)

  j 5f                    # jmp to ret


  // #

  4:

  // # ret

  5:
  pop ra
  ret

_init_root_pagetable:
  push ra

  li a0, 0
  li a1, 0
  li a2, 30
  li a3, 0b0111
  call _map_va_pa

  li a0, (1 << 30)
  li a1, (1 << 30)
  li a2, 30
  li a3, 0b0111
  call _map_va_pa

  li a0, (2 << 30)
  li a1, (2 << 30)
  li a2, 21
  li a3, 0b0111
  call _map_va_pa

  li a0, (2 << 30)
  li a1, (2 << 30)
  li a2, 21
  li a3, 0b0111
  call _map_va_pa

  pop ra
  ret

//# a0 VPN (in)
//# a1 PPN (in)
//# a2 PTE (out)

_walk_page_table:
  push ra

//  li a3, 30                # PAGE_ORDER
  li t6, HEAP_START
  srli t6,t6, 12
  1:
    push a1
    mv a1, t6
    call _get_pte
    pop a1

    li t0, 0b01
    and t0, a2, t0
    beqz t0, 4f                 # Jump PTE is not valid, spec say the rest of the field can be used as pleased

    li t0, 0b01110              # mask
    and t0, a2, t0              # privileges bit [xwr][3:1]
    bnez t0, 3f                 # Jump privileges are non-zero(PTE is leaf)

  // # not leaf, continue walking table
  srli a1, a2, 10             # PNN start at bit 10 of PTE
  li t1, (1 << 44)-1          # mask PPN
  and a1, a1, t1              # PNN
  addi a3, a3, -12              # page order
  //# need add some error checking here
                               // # error checking code
  // # PNN = search the next Page table
  j 1b                          # next LEVEL

  // # PTE is leaf
  3:

    // # a2 = PPN for VNA
    j 5f

  // # Valid bit is zero
  4:
    // # noting for now, Just ret

  5:
    pop ra
    ret


//# a0 VPN (in)
//# a1 PPN(page table)
//# a2 PTE (out)
//# a3 pager_order 30, 21, 12 , level 2, level 1, level 0 (in)

_get_pte:
  add t1, a3, -12
  srl t0, a0, t1             # ?VPN[_]
  andi t0, t0, (1 << 9)-1    # clear ?, VPN[_]
  slli t0, t0, 3             # VPN offset

  slli t1, a1, 12            # pa of page table
  add t1, t1, t0             # pa page table + Offset

  ld a2, (t1)                # TE

  ret


