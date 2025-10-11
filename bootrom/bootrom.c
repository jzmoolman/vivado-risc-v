int main(void) {
    // Configuration port
    asm volatile (
        "li s1, 0x2010000" 
        :
        :
        : "s1"
    );
    // pmpcfg0 value
    asm volatile (
        "li a0, 0x20007FFF" 
        :
        :
        : "a0"
    );

    // Configure pmpcfg0 
    asm volatile (
        "sw a0, 0x40(s1)"
    );

    asm volatile (
        "li a0, 0x2000FFFF" 
        :
        :
        : "a0"
    );

    // Configure pmpcfg0 
    asm volatile (
        "sw a0, 0x44(s1)"
    );

}
