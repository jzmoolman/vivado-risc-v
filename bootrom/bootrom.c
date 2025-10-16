int main(void) {
    // Configuration port
    asm volatile (
        "li s1, 0x2010000" : : : "s1"
    );

    // Set pmpcfg0 and cfg2
    asm volatile (
        "li a0, 0x00003F1F" : : : "a0"
    );

    // Store pmpcfg{0..3}
    asm volatile (
        "sd a0, 0x00(s1)"
    );

    // pmpaddr0 value 0x80002000
    asm volatile (
        "li a0, 0x200007FF" : : : "a0"
    );

    // Store pmpaddr0 
    asm volatile (
        "sd a0, 0x40(s1)"
    );

    // pmpaddr value ?0x80040000
    asm volatile (
        "li a0, 0x20000FFF" : : : "a0"
    );

    // Configure pmpcfg0 
    asm volatile (
        "sd a0, 0x44(s1)"
    );
    
    // asm volatile ( 
    //     "li s1, 0x80000000" : : : "s1"
    // );
    // // Read 0x80000000
    // asm volatile (
    //     "sd a0, 0(s1)" ::: "a0"
    // );
    // asm volatile ( 
    //     "li s1, 0x80002000" : : : "s1"
    // );
    // // Read 0x80002000
    // asm volatile (
    //     "sd a0, 0(s1)" ::: "a0"
    // );

   asm volatile (
    "li t0, 0x80000000;"
    "sd a0, 0(t0);"
    "li t0, 0x80002000;"
    "sd a0, 0(t0);"
    ::: "t0", "memory", "a0"
   );
}
