#include "../../include/ed25519/ed25519.h"
#include "../../include/ed25519/sha3.h"
#include "../../include/ed25519/ge.h"


void ed25519_create_keypair(unsigned char *public_key, unsigned char *private_key, const unsigned char *seed) {
    ge_p3 A;

    sha3(seed, 32, private_key, 64);
    private_key[0] &= 248;
    private_key[31] &= 63;
    private_key[31] |= 64;

    ge_scalarmult_base(&A, private_key);
    ge_p3_tobytes(public_key, &A);
}
