OUTPUT_ARCH("riscv")
ENTRY(_hang)

MEMORY {
  memory_mem (rwx) : ORIGIN = 0x80000000, LENGTH = 0x00002000
}

PHDRS {
  text PT_LOAD;
}

SECTIONS {
  PROVIDE(_ram = ORIGIN(memory_mem));

  .text 0x00010000 : {
    *(.text.start)
    . = 0x0040;
    *(.text.hang)
    . = 0x0080;
    *(.text.startbootrom)
  } >maskrom_mem  :text
  ASSERT(SIZEOF(.text) <= 0x10000, "BootROM .text section must be less than 0x10000 bytes")
}
