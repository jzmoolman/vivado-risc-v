#include "include/ed25519/ed25519.h"
#include "include/ed25519/sha3.h"
#include "include/ed25519/ge.h"
#include "include/ed25519/sc.h"
#include "kprintf.h"

static int consttime_equal(const unsigned char *x, const unsigned char *y) {
    unsigned char r = 0;

    r = x[0] ^ y[0];
    #define F(i) r |= x[i] ^ y[i]
    F(1);
    F(2);
    F(3);
    F(4);
    F(5);
    F(6);
    F(7);
    F(8);
    F(9);
    F(10);
    F(11);
    F(12);
    F(13);
    F(14);
    F(15);
    F(16);
    F(17);
    F(18);
    F(19);
    F(20);
    F(21);
    F(22);
    F(23);
    F(24);
    F(25);
    F(26);
    F(27);
    F(28);
    F(29);
    F(30);
    F(31);
    #undef F

    return !r;
}

void u8toHexStr2(char *buffer, int size) {
  
  
  for ( int i = 0; i < size; i++) {
      kprintf("%hx", buffer[i]);
    if ((i+1) % 8 == 0 && i != 0) {
      kprintf("\n");
    }
  }
}


int ed25519_verify(const unsigned char *signature, const unsigned char *message, size_t message_len, const unsigned char *public_key) {
    unsigned char h[64];
    unsigned char checker[32];
    sha3_ctx_t hash;
    ge_p3 A;
    ge_p2 R;
    kprintf("ed25519_verify 1\n");

    if (signature[63] & 224) {
        return 0;
    }
    kprintf("ed25519_verify 2\n");

    if (ge_frombytes_negate_vartime(&A, public_key) != 0) {
        return 0;
    }
   kprintf("ed25519_verify 3\n");

    sha3_init(&hash, 64);
    sha3_update(&hash, signature, 32);
    sha3_update(&hash, public_key, 32);
    sha3_update(&hash, message, message_len);
    sha3_final(h, &hash);
    kprintf("ed25519_verify 4\n");
    
    sc_reduce(h);
    kprintf("ed25519_verify 5\n");
    ge_double_scalarmult_vartime(&R, h, &A, signature + 32);
    kprintf("ed25519_verify 6\n");
    ge_tobytes(checker, &R);
    kprintf("ed25519_verify 7\n");

    kprintf("checker\n");
    u8toHexStr2(checker,32);
    kprintf("\n");
    kprintf("checker\n");
    kprintf("\n");
    u8toHexStr2(signature,32);
  
  

    if (!consttime_equal(checker, signature)) {
        return 0;
    }

    return 1;
}
