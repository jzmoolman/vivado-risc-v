#include <stdint.h>
#include <stdlib.h>

#include "ff.h"
#include "diskio.h"

#include "common.h"
#include "kprintf.h"

#include "include/ed25519/ed25519.h"

extern const unsigned char _fw_publickey[32];
extern const unsigned char _fw_cert[64];

/* Card type flags (card_type) */
#define CT_MMC          0x01            /* MMC ver 3 */
#define CT_SD1          0x02            /* SD ver 1 */
#define CT_SD2          0x04            /* SD ver 2 */
#define CT_SDC          (CT_SD1|CT_SD2) /* SD */
#define CT_BLOCK        0x08            /* Block addressing */

#define CMD0    (0)             /* GO_IDLE_STATE */
#define CMD1    (1)             /* SEND_OP_COND */
#define CMD2    (2)             /* SEND_CID */
#define CMD3    (3)             /* RELATIVE_ADDR */
#define CMD4    (4)
#define CMD5    (5)             /* SLEEP_WAKE (SDC) */
#define CMD6    (6)             /* SWITCH_FUNC */
#define CMD7    (7)             /* SELECT */
#define CMD8    (8)             /* SEND_IF_COND */
#define CMD9    (9)             /* SEND_CSD */
#define CMD10   (10)            /* SEND_CID */
#define CMD11   (11)
#define CMD12   (12)            /* STOP_TRANSMISSION */
#define CMD13   (13)
#define CMD15   (15)
#define CMD16   (16)            /* SET_BLOCKLEN */
#define CMD17   (17)            /* READ_SINGLE_BLOCK */
#define CMD18   (18)            /* READ_MULTIPLE_BLOCK */
#define CMD19   (19)
#define CMD20   (20)
#define CMD23   (23)
#define CMD24   (24)
#define CMD25   (25)
#define CMD27   (27)
#define CMD28   (28)
#define CMD29   (29)
#define CMD30   (30)
#define CMD32   (32)
#define CMD33   (33)
#define CMD38   (38)
#define CMD42   (42)
#define CMD55   (55)            /* APP_CMD */
#define CMD56   (56)
#define ACMD6   (0x80+6)        /* define the data bus width */
#define ACMD41  (0x80+41)       /* SEND_OP_COND (ACMD) */

// Capability bits
#define SDC_CAPABILITY_SD_4BIT  0x0001
#define SDC_CAPABILITY_SD_RESET 0x0002
#define SDC_CAPABILITY_ADDR     0xff00

// Control bits
#define SDC_CONTROL_SD_4BIT     0x0001
#define SDC_CONTROL_SD_RESET    0x0002

// Card detect bits
#define SDC_CARD_INSERT_INT_EN  0x0001
#define SDC_CARD_IfpNSERT_INT_REQ 0x0002
#define SDC_CARD_REMOVE_INT_EN  0x0004
#define SDC_CARD_REMOVE_INT_REQ 0x0008

// Command status bits
#define SDC_CMD_INT_STATUS_CC   0x0001  // Command complete
#define SDC_CMD_INT_STATUS_EI   0x0002  // Any error
#define SDC_CMD_INT_STATUS_CTE  0x0004  // Timeout
#define SDC_CMD_INT_STATUS_CCRC 0x0008  // CRC error
#define SDC_CMD_INT_STATUS_CIE  0x0010  // Command code check error

// Data status bits
#define SDC_DAT_INT_STATUS_TRS  0x0001  // Transfer complete
#define SDC_DAT_INT_STATUS_ERR  0x0002  // Any error
#define SDC_DAT_INT_STATUS_CTE  0x0004  // Timeout
#define SDC_DAT_INT_STATUS_CRC  0x0008  // CRC error
#define SDC_DAT_INT_STATUS_CFE  0x0010  // Data FIFO underrun or overrun

#define ERR_EOF             30
#define ERR_NOT_ELF         31
#define ERR_ELF_BITS        32
#define ERR_ELF_ENDIANNESS  33
#define ERR_CMD_CRC         34
#define ERR_CMD_CHECK       35
#define ERR_DATA_CRC        36
#define ERR_DATA_FIFO       37
#define ERR_BUF_ALIGNMENT   38

struct sdc_regs {
    volatile uint32_t argument;
    volatile uint32_t command;
    volatile uint32_t response1;
    volatile uint32_t response2;
    volatile uint32_t response3;
    volatile uint32_t response4;
    volatile uint32_t data_timeout;
    volatile uint32_t control;
    volatile uint32_t cmd_timeout;
    volatile uint32_t clock_divider;
    volatile uint32_t software_reset;
    volatile uint32_t power_control;
    volatile uint32_t capability;
    volatile uint32_t cmd_int_status;
    volatile uint32_t cmd_int_enable;
    volatile uint32_t dat_int_status;
    volatile uint32_t dat_int_enable;
    volatile uint32_t block_size;
    volatile uint32_t block_count;
    volatile uint32_t card_detect;
    volatile uint32_t res_50;
    volatile uint32_t res_54;
    volatile uint32_t res_58;
    volatile uint32_t res_5c;
    volatile uint64_t dma_addres;
};

#define MAX_BLOCK_CNT 0x1000

/* Note: .data section not supported in BootROM */

static struct sdc_regs * const regs __attribute__((section(".rodata"))) = (struct sdc_regs *)0x60000000;

static int errno __attribute__((section(".bss")));
static DSTATUS drv_status __attribute__((section(".bss")));
static BYTE card_type __attribute__((section(".bss")));
static uint32_t response[4] __attribute__((section(".bss")));
static FATFS fatfs __attribute__((section(".bss")));
static int alt_mem __attribute__((section(".bss")));
static FIL fd __attribute__((section(".bss")));
static FIL fd2 __attribute__((section(".bss")));

extern unsigned char _fbss[];
extern unsigned char _ebss[];

static const char * errno_to_str(void) {
    switch (errno) {
    case FR_OK: return "No error";
    case FR_DISK_ERR: return "Disk I/O error";
    case FR_INT_ERR: return "Assertion failed";
    case FR_NOT_READY: return "Disk not ready";
    case FR_NO_FILE: return "File not found";
    case FR_NO_PATH: return "Path not found";
    case FR_INVALID_NAME: return "Invalid path";
    case FR_DENIED: return "Access denied";
    case FR_EXIST: return "Already exist";
    case FR_INVALID_OBJECT: return "The FS object is invalid";
    case FR_WRITE_PROTECTED: return "The drive is write protected";
    case FR_INVALID_DRIVE: return "The drive number is invalid";
    case FR_NOT_ENABLED: return "The volume has no work area";
    case FR_NO_FILESYSTEM: return "Not a valid FAT volume";
    case FR_MKFS_ABORTED: return "The f_mkfs() aborted";
    case FR_TIMEOUT: return "Timeout";
    case FR_LOCKED: return "Locked";
    case FR_NOT_ENOUGH_CORE: return "Not enough memory";
    case FR_TOO_MANY_OPEN_FILES: return "Too many open files";
    case ERR_EOF: return "Unexpected EOF";
    case ERR_NOT_ELF: return "Not an ELF file";
    case ERR_ELF_BITS: return "Wrong ELF word size";
    case ERR_ELF_ENDIANNESS: return "Wrong ELF endianness";
    case ERR_CMD_CRC: return "Command CRC error";
    case ERR_CMD_CHECK: return "Command code check error";
    case ERR_DATA_CRC: return "Data CRC error";
    case ERR_DATA_FIFO: return "Data FIFO error";
    case ERR_BUF_ALIGNMENT: return "Bad buffer alignment";
    }
    return "Unknown error code";
}

static void usleep(unsigned us) {
    uintptr_t cycles0;
    uintptr_t cycles1;
    asm volatile ("csrr %0, 0xB00" : "=r" (cycles0));
    for (;;) {
        asm volatile ("csrr %0, 0xB00" : "=r" (cycles1));
        if (cycles1 - cycles0 >= us * 100) break;
    }
}

static int sdc_cmd_finish(unsigned cmd) {
    while (1) {
        unsigned status = regs->cmd_int_status;
        if (status) {
            // clear interrupts
            regs->cmd_int_status = 0;
            while (regs->software_reset != 0) {}
            if (status == SDC_CMD_INT_STATUS_CC) {
                // get response
                response[0] = regs->response1;
                response[1] = regs->response2;
                response[2] = regs->response3;
                response[3] = regs->response4;
                return 0;
            }
            errno = FR_DISK_ERR;
            if (status & SDC_CMD_INT_STATUS_CTE) errno = FR_TIMEOUT;
            if (status & SDC_CMD_INT_STATUS_CCRC) errno = ERR_CMD_CRC;
            if (status & SDC_CMD_INT_STATUS_CIE) errno = ERR_CMD_CHECK;
            break;
        }
    }
    return -1;
}

static int sdc_data_finish(void) {
    int status;

    while ((status = regs->dat_int_status) == 0) {}
    regs->dat_int_status = 0;
    while (regs->software_reset != 0) {}

    if (status == SDC_DAT_INT_STATUS_TRS) return 0;
    errno = FR_DISK_ERR;
    if (status & SDC_DAT_INT_STATUS_CTE) errno = FR_TIMEOUT;
    if (status & SDC_DAT_INT_STATUS_CRC) errno = ERR_DATA_CRC;
    if (status & SDC_DAT_INT_STATUS_CFE) errno = ERR_DATA_FIFO;
    return -1;
}

static int send_data_cmd(unsigned cmd, unsigned arg, void * buf, unsigned blocks) {
    unsigned command = (cmd & 0x3f) << 8;
    switch (cmd) {
    case CMD0:
    case CMD4:
    case CMD15:
        // No responce
        break;
    case CMD11:
    case CMD13:
    case CMD16:
    case CMD17:
    case CMD18:
    case CMD19:
    case CMD23:
    case CMD24:
    case CMD25:
    case CMD27:
    case CMD30:
    case CMD32:
    case CMD33:
    case CMD42:
    case CMD55:
    case CMD56:
    case ACMD6:
        // R1
        command |= 1; // 48 bits
        command |= 1 << 3; // resp CRC
        command |= 1 << 4; // resp OPCODE
        break;
    case CMD7:
    case CMD12:
    case CMD20:
    case CMD28:
    case CMD29:
    case CMD38:
        // R1b
        command |= 1; // 48 bits
        command |= 1 << 2; // busy
        command |= 1 << 3; // resp CRC
        command |= 1 << 4; // resp OPCODE
        break;
    case CMD2:
    case CMD9:
    case CMD10:
        // R2
        command |= 2; // 136 bits
        command |= 1 << 3; // resp CRC
        break;
    case ACMD41:
        // R3
        command |= 1; // 48 bits
        break;
    case CMD3:
        // R6
        command |= 1; // 48 bits
        command |= 1 << 2; // busy
        command |= 1 << 3; // resp CRC
        command |= 1 << 4; // resp OPCODE
        break;
    case CMD8:
        // R7
        command |= 1; // 48 bits
        command |= 1 << 3; // resp CRC
        command |= 1 << 4; // resp OPCODE
        break;
    }

    if (blocks) {
        command |= 1 << 5;
        if ((intptr_t)buf & 3) {
            errno = ERR_BUF_ALIGNMENT;
            return -1;
        }
        regs->dma_addres = (uint64_t)(intptr_t)buf;
        regs->block_size = 511;
        regs->block_count = blocks - 1;
        regs->data_timeout = 0xFFFFFF;
    }

    regs->command = command;
    regs->cmd_timeout = 0xFFFFF;
    regs->argument = arg;

    if (sdc_cmd_finish(cmd) < 0) return -1;
    if (blocks) return sdc_data_finish();

    return 0;
}

#define send_cmd(cmd, arg) send_data_cmd(cmd, arg, NULL, 0)

static int ini_sd(void) {
    unsigned rca;

    /* Reset controller */
    regs->software_reset = 1;
    while ((regs->software_reset & 1) == 0) {}
    regs->clock_divider = 0x7c;
    regs->software_reset = 0;
    while (regs->software_reset) {}
    usleep(5000);

    card_type = 0;
    drv_status = STA_NOINIT;

    if (regs->capability & SDC_CAPABILITY_SD_RESET) {
        /* Power cycle SD card */
        regs->control |= SDC_CONTROL_SD_RESET;
        usleep(1000000);
        regs->control &= ~SDC_CONTROL_SD_RESET;
        usleep(100000);
    }

    /* Enter Idle state */
    send_cmd(CMD0, 0);

    card_type = CT_SD1;
    if (send_cmd(CMD8, 0x1AA) == 0) {
        if ((response[0] & 0xfff) != 0x1AA) {
            errno = ERR_CMD_CHECK;
            return -1;
        }
        card_type = CT_SD2;
    }

    /* Wait for leaving idle state (ACMD41 with HCS bit) */
    while (1) {
        /* ACMD41, Set Operating Conditions: Host High Capacity & 3.3V */
        if (send_cmd(CMD55, 0) < 0 || send_cmd(ACMD41, 0x40300000) < 0) return -1;
        if (response[0] & (1 << 31)) {
            if (response[0] & (1 << 30)) card_type |= CT_BLOCK;
            break;
        }
    }

    /* Enter Identification state */
    if (send_cmd(CMD2, 0) < 0) return -1;

    /* Get RCA (Relative Card Address) */
    rca = 0x1234;
    if (send_cmd(CMD3, rca << 16) < 0) return -1;
    rca = response[0] >> 16;

    /* Select card */
    if (send_cmd(CMD7, rca << 16) < 0) return -1;

    /* Clock 25MHz */
    regs->clock_divider = 3;
    usleep(10000);

    /* Bus width 1-bit */
    regs->control = 0;
    if (send_cmd(CMD55, rca << 16) < 0 || send_cmd(ACMD6, 0) < 0) return -1;

    /* Set R/W block length to 512 */
    if (send_cmd(CMD16, 512) < 0) return -1;

    drv_status &= ~STA_NOINIT;
    return 0;
}

DSTATUS disk_status(BYTE drv) {
    return drv_status;
}

DRESULT disk_read(BYTE drv, BYTE * buf, LBA_t sector, UINT count) {

    if (!count) return RES_PARERR;
    if (drv_status & STA_NOINIT) return RES_NOTRDY;

    /* Convert LBA to byte address if needed */
    if (!(card_type & CT_BLOCK)) sector *= 512;
    while (count > 0) {
        UINT bcnt = count > MAX_BLOCK_CNT ? MAX_BLOCK_CNT : count;
        unsigned bytes = bcnt * 512;
        if (send_data_cmd(bcnt == 1 ? CMD17 : CMD18, sector, buf, bcnt) < 0) return RES_ERROR;
        if (bcnt > 1 && send_cmd(CMD12, 0) < 0) return RES_ERROR;
        sector += (card_type & CT_BLOCK) ? bcnt : bytes;
        count -= bcnt;
        buf += bytes;
    }

    return RES_OK;
}

DSTATUS disk_initialize(BYTE drv) {
    if (ini_sd() < 0) kprintf("Cannot access SD: %s\n", errno_to_str());
    return drv_status;
}

static uintptr_t read_num(FIL* fd, unsigned size) {
    uint8_t buf[0x10];
    uintptr_t v = 0;
    unsigned n = 0;
    UINT rd;
    if (errno) return 0;
    errno = f_read(fd, buf, size, &rd);
    if (errno) return 0;
    if (rd < size) {
        errno = ERR_EOF;
        return 0;
    }
    for (n = 0; n < size; n++) {
        v |= (uintptr_t)(buf[n]) << (n * 8);
    }
    return v;
}

#define read_uint16(a) (uint16_t)read_num(a,2)
#define read_uint32(a) (uint32_t)read_num(a,4)
#define read_addr(a) (uintptr_t)read_num(a,__riscv_xlen >> 3)


#define PT_LOAD 1

void u8toHexStr(char *buffer, int size) {
  
  
  for ( int i = 0; i < size; i++) {
      kprintf("%hx", buffer[i]);
    if ((i+1) % 8 == 0 && i != 0) {
      kprintf("\n");
    }
  }
}

static int verify(void) {
    const char * fnm = "BOOT.ELF";
    uint8_t buf[0x10];
    uintptr_t entry_addr = 0;
    uint64_t phoff = 0;
    uint16_t phentsize = 0;
    uint16_t phnum = 0;
    unsigned i = 0;
    int fw_valid = 0;

    errno = f_open(&fd2, fnm, FA_READ);
    if (errno) return -1;

    UINT rd = 0;
    errno = f_read(&fd2, buf, 6, &rd);
    if (errno) return -1;
    if (rd < 6) {
        errno = ERR_EOF;
        return -1;
    }
    if (buf[0] != 0x7f || buf[1] != 'E' || buf[2] != 'L' || buf[3] != 'F') {
        errno = ERR_NOT_ELF;
        return -1;
    }
    if (buf[4] != (__riscv_xlen == 32 ? 1 : 2)) {
    
        errno = ERR_ELF_BITS;
        return -1;
    }
    if (buf[5] != 1) {
        errno = ERR_ELF_ENDIANNESS;
        return -1;
    }
    errno = f_lseek(&fd2, 24);
    entry_addr = read_addr(&fd2);
    phoff = read_addr(&fd2);
    if (errno) return -1;
    errno = f_lseek(&fd2, f_tell(&fd2) + (__riscv_xlen>>3) + 6);
    
    phentsize = read_uint16(&fd2);
    phnum = read_uint16(&fd2);

    if (errno) return -1;
    
    for (i = 0; i < phnum; i++) {
        uint32_t p_type = 0;
        uint64_t p_offset = 0;
        uint64_t p_vaddr = 0;
        uint64_t p_filesz = 0;
        uint64_t p_memsz = 0;
        uintptr_t addr = 0;
        size_t pos = 0;
        errno = f_lseek(&fd2, phoff + i * phentsize);
        p_type = read_uint32(&fd2);
        if (errno) return -1;
        if (p_type != PT_LOAD) continue;
        if ( i != 1)  continue;
        
        errno = f_lseek(&fd2, f_tell(&fd2) + (__riscv_xlen == 32 ? 0 : 4));
        p_offset = read_addr(&fd2);
        p_vaddr = read_addr(&fd2);
        read_addr(&fd2); /* p_paddr */
        p_filesz = read_addr(&fd2);
        p_memsz = read_addr(&fd2);
        if (errno) return -1;
        errno = f_lseek(&fd2, p_offset);
        if (errno) return -1;

        p_vaddr = SCRATCHPAD_ADDR;
        addr = p_vaddr;
       
        while (pos < p_filesz && pos < p_memsz) {
            uint8_t * mem = (void *)addr;
            size_t size = 0x10000;
            if (size > p_filesz - pos) size = (size_t)(p_filesz - pos);
            if (size > p_memsz - pos) size = (size_t)(p_memsz - pos);
            
            errno = f_read(&fd2, mem, size, &rd);
//            for (int j = 0; j*8 < size; j++) {
//              kprintf("mem %x ", mem+j*8);
//              kprintf("-> %x\n", *(long unsigned*)(mem+8*j)); 
//            }

            if (errno) return -1;
            if (rd == 0) {
                errno = ERR_EOF;
                return -1;
            }
            if (size >(size_t)rd) size = (size_t)rd;
            addr += size;
            pos += size;
        }
        while (pos < p_memsz) {
            uint8_t * mem = (void *)addr;
            size_t size = 0x10000;
            if (size > p_memsz - pos) size = (size_t)p_memsz - pos;
            //if (addr + size > BOOTROM_MEM_ADDR && addr < BOOTROM_MEM_END) {
            //    mem = (uint8_t *)(addr - SCRATCHPAD_ADDR);
            //    if (addr + size > BOOTROM_MEM_END) size = BOOTROM_MEM_END - addr;
            //    alt_mem = 1;
            //}
            size_t s = size;
            while (s) {
                *mem++ = 0;
                s--;
            }
            addr += size;
            pos += size;
        }

        FIL fd_cert;
        char *filename_cert = "cert_1";
        char fw_signature[64];
          
        errno = f_open(&fd_cert, filename_cert, FA_READ);
        if (errno) return -1;
            UINT rd = 0;
            errno = f_read(&fd_cert, fw_signature, 64, &rd);
            if (errno) return -1;
            if (rd < 64) {
            errno = ERR_EOF;
            return -1;
            f_close(&fd_cert);
       }

//        char fw_signature[64] = {
//           0xB7 ,0x0C ,0x01 ,0x5B ,0x23 ,0xB5 ,0x79 ,0x23,0x17, 
//0x4A ,0x16 ,0x6B ,0xC4 ,0x91 ,0x7E ,0xAD ,0x62, 
//0xF9 ,0xE1 ,0x61 ,0x8A ,0x7C ,0xE2 ,0xB4 ,0xC9, 
//0x6A ,0x39 ,0xE5 ,0x7E ,0x82 ,0x09 ,0x47 ,0x16, 
//0x2D ,0x8C ,0xC6 ,0x24 ,0x5D ,0x19 ,0xC8 ,0x70, 
//0xA2 ,0xDD ,0xCD ,0x5A ,0xB8 ,0xF3 ,0x21 ,0xE9, 
//0xD4 ,0x59 ,0x32 ,0x85 ,0x26 ,0x06 ,0x3E ,0x55, 
//0x9E ,0x37 ,0x8D ,0xC7 ,0xAD ,0xCC ,0x0F 
//
//        };

        kprintf("fw_public_key\n");
        u8toHexStr(_fw_publickey, 32);
        kprintf("\n");

        kprintf("Certificate\n");
        u8toHexStr(fw_signature, 64 );
        kprintf("\n");

        kprintf("p_vaddr %x ", p_vaddr);
        kprintf("p_flesz %x ", p_filesz);
        kprintf("p_memsz %x ", p_memsz);

          
        fw_valid = ed25519_verify(fw_signature, p_vaddr, p_filesz, _fw_publickey);
        break; 
      
    }
    f_close(&fd2);
    return fw_valid;
}

static int download(void) {
    const char * fnm = "BOOT.ELF";
    uint8_t buf[0x10];
    uintptr_t entry_addr = 0;
    uint64_t phoff = 0;
    uint16_t phentsize = 0;
    uint16_t phnum = 0;
    unsigned i = 0;

    errno = f_open(&fd, fnm, FA_READ);
    if (errno) return -1;

    UINT rd = 0;
    errno = f_read(&fd, buf, 6, &rd);
    if (errno) return -1;
    if (rd < 6) {
        errno = ERR_EOF;
        return -1;
    }
    if (buf[0] != 0x7f || buf[1] != 'E' || buf[2] != 'L' || buf[3] != 'F') {
        errno = ERR_NOT_ELF;
        return -1;
    }
    if (buf[4] != (__riscv_xlen == 32 ? 1 : 2)) {
        errno = ERR_ELF_BITS;
        return -1;
    }
    if (buf[5] != 1) {
        errno = ERR_ELF_ENDIANNESS;
        return -1;
    }
    errno = f_lseek(&fd, 24);
    entry_addr = read_addr(&fd);
    phoff = read_addr(&fd);
    if (errno) return -1;
    errno = f_lseek(&fd, f_tell(&fd) + (__riscv_xlen>>3) + 6);
    phentsize = read_uint16(&fd);
    phnum = read_uint16(&fd);
    if (errno) return -1;
    for (i = 0; i < phnum; i++) {
        uint32_t p_type = 0;
        uint64_t p_offset = 0;
        uint64_t p_vaddr = 0;
        uint64_t p_filesz = 0;
        uint64_t p_memsz = 0;
        uintptr_t addr = 0;
        size_t pos = 0;
        errno = f_lseek(&fd, phoff + i * phentsize);
        p_type = read_uint32(&fd);
        if (errno) return -1;
        if (p_type != PT_LOAD) continue;
        errno = f_lseek(&fd, f_tell(&fd) + (__riscv_xlen == 32 ? 0 : 4));
        p_offset = read_addr(&fd);
        p_vaddr = read_addr(&fd);
        read_addr(&fd); /* p_paddr */
        p_filesz = read_addr(&fd);
        p_memsz = read_addr(&fd);
        if (errno) return -1;
        errno = f_lseek(&fd, p_offset);
        if (errno) return -1;
        addr = p_vaddr;
        while (pos < p_filesz && pos < p_memsz) {
            uint8_t * mem = (void *)addr;
            size_t size = 0x10000;
            if (size > p_filesz - pos) size = (size_t)(p_filesz - pos);
            if (size > p_memsz - pos) size = (size_t)(p_memsz - pos);
            if (addr + size > BOOTROM_MEM_ADDR && addr < BOOTROM_MEM_END) {
                mem = (uint8_t *)(addr - BOOTROM_MEM_ADDR + BOOTROM_MEM_ALT);
                if (addr + size > BOOTROM_MEM_END) size = BOOTROM_MEM_END - addr;
                alt_mem = 1;
            }
            errno = f_read(&fd, mem, size, &rd);
            if (errno) return -1;
            if (rd == 0) {
                errno = ERR_EOF;
                return -1;
            }
            if (size >(size_t)rd) size = (size_t)rd;
            addr += size;
            pos += size;
        }
        while (pos < p_memsz) {
            uint8_t * mem = (void *)addr;
            size_t size = 0x10000;
            if (size > p_memsz - pos) size = (size_t)p_memsz - pos;
            if (addr + size > BOOTROM_MEM_ADDR && addr < BOOTROM_MEM_END) {
                mem = (uint8_t *)(addr - BOOTROM_MEM_ADDR + BOOTROM_MEM_ALT);
                if (addr + size > BOOTROM_MEM_END) size = BOOTROM_MEM_END - addr;
                alt_mem = 1;
            }
            size_t s = size;
            while (s) {
                *mem++ = 0;
                s--;
            }
            addr += size;
            pos += size;
        }
    }
    errno = f_close(&fd);
    if (errno) return -1;

    asm volatile ("li  a0, 0"); // Hart No
    asm volatile ("li  a1, %0" :: "n" (BOOTROM_DTB_ADDR)); // Device Tree
    if (alt_mem) {
#if __riscv_xlen <= 32 || (BOOTROM_MEM_END < 0x80000000 && BOOTROM_MEM_ALT < 0x80000000)
        asm volatile ("li  t0, %0" :: "n" (BOOTROM_MEM_ADDR));
        asm volatile ("li  t1, %0" :: "n" (BOOTROM_MEM_END));
        asm volatile ("li  t2, %0" :: "n" (BOOTROM_MEM_ALT));
#elif BOOTROM_MEM_END < 0x8000000000 && BOOTROM_MEM_ALT < 0x8000000000
        /* Argument of "li" instruction is 32-bit signed integer, use shift to avoid sign extension */
        asm volatile ("li  t0, %0" :: "n" (BOOTROM_MEM_ADDR >> 8));
        asm volatile ("li  t1, %0" :: "n" (BOOTROM_MEM_END >> 8));
        asm volatile ("li  t2, %0" :: "n" (BOOTROM_MEM_ALT >> 8));
        asm volatile ("slli t0, t0, 8");
        asm volatile ("slli t1, t1, 8");
        asm volatile ("slli t2, t2, 8");
#else
#  error "Invalid Boot ROM memory address"
#endif
#if __riscv_xlen == 32
        asm volatile ("lw   a5, %0" :: "m" (entry_addr));
        asm volatile ("boot_rom_memcpy:");
        asm volatile ("lw   t3, 0(t2)");
        asm volatile ("sw   t3, 0(t0)");
        asm volatile ("lw   t3, 4(t2)");
        asm volatile ("sw   t3, 4(t0)");
#else
        asm volatile ("ld   a5, %0" :: "m" (entry_addr));
        asm volatile ("boot_rom_memcpy:");
        asm volatile ("ld   t3, 0(t2)");
        asm volatile ("sd   t3, 0(t0)");
#endif
        asm volatile ("addi t0, t0, 8");
        asm volatile ("addi t2, t2, 8");
        asm volatile ("bne  t0, t1, boot_rom_memcpy");
        asm volatile ("fence.i" ::: "memory");
        asm volatile ("jr   a5");
    }
    asm volatile ("fence.i" ::: "memory");
    asm volatile ("jr %0" :: "r" (entry_addr));

    return 0;
}



int main(void) {
    uint64_t * bss = (uint64_t *)_fbss;
    while (bss < (uint64_t *)_ebss) *bss++ = 0;
    for (;;) {
        kputs("");
        kprintf("RISC-V %d, Boot ROM V3.8 - ZZZ\n", __riscv_xlen);
        drv_status = STA_NOINIT;
        errno = f_mount(&fatfs, "", 1);
        if (verify()) {
           kprintf("Verify OK\n");
        } else {
           kprintf("Verify Bad\n");  
        }
        if (errno) {
            kprintf("Cannot mount SD: %s\n", errno_to_str());
        }
        else if (download() != 0) {
            kprintf("Cannot read BOOT.ELF: %s\n", errno_to_str());
        }
        if (fd.obj.fs) f_close(&fd);
        usleep(1000000);
    }
    return 0;
}
