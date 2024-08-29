#ifndef __MEM_S__
#define __MEM_S__

#include "common.h"



#define PAGE_SIZE

// # very crude zalloc
// # a0 return address of new page
// # page size 4096
zalloc:

  li t0, HEAP_NEXT
  ld a0, (t0)           # new heap page start

  li t1, (1<<12)         # next heap page (add 4096 to new heap page start)
  add t2, a0, t1
  sd t2, (t0)            # store next heap start

  ret


#endif