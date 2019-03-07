pragma solidity >=0.4.21 <0.6.0;
import "contracts/Pairing.sol";contract AdultTest {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point A;
        Pairing.G1Point B;
        Pairing.G2Point C;
        Pairing.G2Point gamma;
        Pairing.G1Point gammaBeta1;
        Pairing.G2Point gammaBeta2;
        Pairing.G2Point Z;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G1Point A_p;
        Pairing.G2Point B;
        Pairing.G1Point B_p;
        Pairing.G1Point C;
        Pairing.G1Point C_p;
        Pairing.G1Point K;
        Pairing.G1Point H;
    }
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0xf41362a6baf4e23e2b1eba8abe57aeb0777152a47c017c8e73af73b8ce29d67, 0x1444d8da29f2b5786acdc00b7db836f34d77901cf1b3d67714dade0fce18a227], [0x5318dbe47bcb598934f7dee7e916dd2cd5259923e3dfcb2ce69550e0cdf991a, 0xfe6ada568d91d00d5b9ae32d888727dd104ae474ce99f07c2cfc63e7ff9aa6e]);
        vk.B = Pairing.G1Point(0xa55d7884ba892c7eb6f8c9acdb37b643254cd92d037993ec44d005cd797daaf, 0x276a9286532938ecd5a640526bd6d24bde619362a44d14e8138ab2c174bdcf2e);
        vk.C = Pairing.G2Point([0x8156e0678414edb58201b958cecfc52e5d0aad4c0fbb199434b282f46e91fca, 0x3ff29acc7d43753fd4056633bf891c16d1aa17c17349cf1e8f32c36c4db423], [0x2971ed8779d9900c8f4d15fc1e90c497a4743a1322a76b6e2076091b1ba2ed1d, 0x24a281451e88deb273c168466f4ff2ed62f57663bf8523ea368b923b7c396407]);
        vk.gamma = Pairing.G2Point([0x2f4523664e9695cf695730db4a526ce11a1ef7cbf776679df8b0b5ab76260be3, 0x10dbee2c3b3cf6c7be59de88ed912fd384a65e21222ae1b901eac59072a1df6c], [0x29f6568c46f1ad9e2aa6aa49bbff6cec4f5fdc1471654ae69b998703c7cd4946, 0x1bf6e005e33ad5e402b5194d2f05966f45fc918bb0d4fbe4c7f4473e02059a6b]);
        vk.gammaBeta1 = Pairing.G1Point(0x640c15b4ac6bebaffe8fc536e31575561b0d961e5030d1ad45d072a9289a4d9, 0x164f219b008e6f6eb0464b2942f913118adec7874de53b974577291adfe1e486);
        vk.gammaBeta2 = Pairing.G2Point([0x21136bd97eaecdfad4a9b959b7941f738246192965328e49eb599b4864fe1101, 0x14274679ad2b9e4edf95736fb6c989e8efa952633a94748d5ec96c84f5970092], [0xf0a618c25ed66727271110d4ab83993bfde27ed7b8172da968ca0537fd63c44, 0x1b8d902319cede68d0687ff3376c2565d34741aafc75501a9904d07266781e46]);
        vk.Z = Pairing.G2Point([0x1909ff6f1406fe49d52bb72d62cb9c35c3570db8dcfb577164c4f8c45fe27d2d, 0x2018c486504e178a17bf6215eab7ff46cd2c744f4db12f5e9b5d1bccfaa9b6d9], [0x25a81e8639b9761f83cc06f8cf48630e5deb1c8fb052264dcb29e83c0359457d, 0x59c3709336c00c286ff8dc2908c96812fff99df9aee9d9fe82c128a035d53d]);
        vk.IC = new Pairing.G1Point[](2);
        vk.IC[0] = Pairing.G1Point(0x8e1f911623f9df949486e5ecfabeb566fe6a7509f68345d20c29e15d297fd38, 0x11a2caa610fb13604db962c28740d97031530fcadb407e05348574995e2c02);
        vk.IC[1] = Pairing.G1Point(0x1a81e6442b38299f600826f8e6ea2913a0a46f300cc3b93135808dcab9484eb0, 0xe6b2715cb3f2e0c2d4f205d83d4f049c95f0c2e94c916417a48012bf5f30f89);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.addition(vk_x, Pairing.addition(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    event Verified(string s);
    function verifyTx(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k,
            uint[1] input
        ) public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
