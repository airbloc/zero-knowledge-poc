# Airbloc Zero-Knowledge Proof PoC

This repository contains proof-of-concept (PoC) codes for adopting Zero-Knowledge Proofs to Airbloc Protocol.

## Benchmark
Benchmark ran on to `InsuranceTest` with witness minimumIncome: 500, income: 600.

 * Compiler version: `0.4.25+commit.59dbf8f1.Emscripten.clang`
 * Optimizations: 200

#### Results

| Backend                                     | Verify Cost |
|---------------------------------------------|-------------|
| [PGHR13](https://eprint.iacr.org/2013/279)  | 1656161     |
| [Groth17](https://eprint.iacr.org/2017/540) | 883718      |

#### Commands (Proofs) used for the benchmark

```js
// PGHR13
(await InsuranceTest.deployed()).verifyTx(
    ["0x9035d7c7ef373e3266fa2aea4da0040f679c200b08947a6e31dc669b5de29a7","0x266e5feb66af219a21fa74673d3c82a421785211004b720fb1b28976b148d077"],
    ["0x23bd58f4dadcffac62f545b9bc9e14d2a8d93116878c6585c934080565d04ef2","0x27cc0d012396e5f9b04b791e3b3354e74d03202ad5a90755b731690b4a944011"],
    [
        ["0x135c1040271ded9192bcb8a9d004bce7cb282cab13f18831ffbb091ede8b90c4", "0x27e6288b7689f17c277e34f9d83600b5fdf43634cdf8175bf15d2dedef56b903"],
        ["0x1c77fba633bb428d87600aaeff6b9fbc79f305af1d8515e3ade146297ce2bdc1","0x26a16fdab9e5fc3e26dcb274e9f3ac43dcd7b1468f2146493efe08a85786e344"]
    ],
    ["0x8565c241e878392583ae43cc19022fac7cfac153ea130b2f9193d4aba9f0125","0x1e9b1f6b0a35c16f606551d3eedcdfdb468b1e5fae57fa0f4a28b307d9e50cc3"],
    ["0x623abd6891ee836d6a0e84b5cf513205bddd597806e613bd5bd87d404407882","0x2f0c39863a76add145b5a0a07011cebe56b8c33a7bdd38f34e5f8853798bde5b"],
    ["0x561ac226ace312d9c40ec752e2cc92a4cf5a7eaad1b2334e6aa89a99d07adb9","0x12c11e18bb7313f722d1732a2afe5aea72f5d0647888116882d52090216e2c03"],
    ["0x75097ce88abc2a15d6e060ba7f53b7399a786dd73871d649620d7950ae28d1d","0x1cd84c41e87fce53164ba0941802baf723db4fd4850300b891a25b2815331c19"],
    ["0x1dfd4f6e21b29027023310498fe5395c057b8443f44f937a5d9e619669ded565","0x5b7663b6066d8ad50f619d1fd186691e13f34e3239ff49e0f208628deb040dd"],
    [500,1]
)

// Groth17
(await InsuranceTest.deployed()).verifyTx(
    ["0x1678bb2b40a75c14f5d3255a872ecf0d59c69916e38ad03f0d363170f7d79548","0x130b404ab065953fcbb0f93dd8f7a671df0d4037f23cc9d97fd4fe03c060a156"],
    [
        ["0x14a14ee43540cc27b9504ac2754b20f46800b2dd8786b595c8ad4e746f26d789","0x250afd9609978d33a0c1cc0495d3e3501a731ac1100975f8bcc78115369940e8"],
        ["0x21487eb0d3cc18efe5388a249680db685dc9348fed3216c3bb03d9d9a34506c3","0x26197c43e07084a92f4a5fe695726c3cacef4b4b082f1c23a17a17fc2be2930"]
    ],
    ["0x186c9039a8a88aa7e5c18d2b79bdabf2e881beb420f6393c114b5bfbe5d886a1","0x1ccc72935acf82b5b12a847f0c3bb71287d3041cb162a31face97a2e42cbc2cf"],
    [500,1]
)
```
