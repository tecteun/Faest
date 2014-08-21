
/*
* AES Cryptographic Algorithm Header File. Include this header file in
* your source which uses these given APIs. (This source is kept under
* public domain)
* http://embeddedknowledge.blogspot.nl/2012/03/optimized-aes-source-code-for-embedded.html
*/

// AES context structure
typedef struct {
 unsigned int Ek[60];
 unsigned int Dk[60];
 unsigned int Iv[4];
 unsigned char Nr;
 unsigned char Mode;
} AesCtx;

// key length in bytes
#define KEY128 16
#define KEY192 24
#define KEY256 32
// block size in bytes
#define BLOCKSZ 16
// mode
#define EBC 0
#define CBC 1

// AES API function prototype

int AesCtxIni(AesCtx *pCtx, unsigned int ivPointer, unsigned int keyPointer, unsigned int KeyLen, unsigned char Mode);
int AesDecrypt(AesCtx *pCtx, unsigned int cipher, unsigned int data, unsigned int CipherLen);