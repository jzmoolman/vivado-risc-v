#ifndef __MACRO_S__
#define __MACRO_S__

.macro push reg
    addi sp,sp, -8
    sd \reg, (sp)
.endm

.macro pop reg
    ld \reg, (sp)
    addi sp,sp, 8
.endm

#endif
