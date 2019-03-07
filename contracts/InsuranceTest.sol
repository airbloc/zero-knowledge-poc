pragma solidity >=0.4.21 <0.6.0;
import "contracts/Pairing.sol";contract InsuranceTest {
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
        vk.A = Pairing.G2Point([0x21edc9362312aaf349c8e8ea981f8aee3b991f49a85ec43dff431294bec26659, 0x13ec1207653712caa6f7993b507944e8a923e3587b4ceda2d839916af823d36], [0x27b51c960ac4501036f467774cfa553eaf711188242605d3b344021bb36e2e63, 0x1dc2eed1493f2f7c3f493b373f626abfc12302a17427e8df4feae7a337d9423]);
        vk.B = Pairing.G1Point(0x100b250a861783e2e49d14fbaa55e2e5f36e43672d75031ef2402bc2ee547d4a, 0x1d727ee62aa19e63f9e5cc39e4ccc21c9d9b896daf90da141909519f8cca7c18);
        vk.C = Pairing.G2Point([0x136e946b8d063e8fac56974b43ae4cc4dd4f7dd6a7da240c33189e6259d4892f, 0x1119084a0ee10d7f9f186850de5501b23f1ec7bf9549d514c2842c8e5e24a6d3], [0xb95f6b4312a1172b7cc9180b8dbf92c586727435ac33ee613d663d9850a56ad, 0x7e9653480125a5eb4641d74aa3547973e8d8bc1cd690a5237e2dd7ed332a878]);
        vk.gamma = Pairing.G2Point([0x200cde5aaf30018985f296e050bc22aa7aea76b648533ac1ebd430778ae32131, 0x1021a788ec76835f89336e13b2898da25d5dace7984029533a6c892e2ceb4a48], [0x2a4ac98967096479dc73812aa32b91fec1d57541c9dbc65c6f72dfbd33c77c1d, 0x1bc331843845e9325b2ca50c015825df3f45d2e57330a1a527418088fea46d10]);
        vk.gammaBeta1 = Pairing.G1Point(0x8bfbfdf211c7b1304271a74e7b29875f8de01d7fd06a797f016c413b0a293e7, 0xed8af5828e90bb833105b9af5deefd570c4f27259cbd1d82e3b4f38547e5505);
        vk.gammaBeta2 = Pairing.G2Point([0x5f95722d6d4d9a7ef30448c700e9c2f0701581f79be5f6ded983d87e609eb4e, 0x19ab49c4d688f4b5239d20b20941930cf5626dc0d4c1574db987dff1b62e7bc0], [0x239c3cd526a5239e8eb03a4a12ac89c232e24e7826c349defed11ebe4147cfcd, 0x8272d7c9c33f7db58a567132f6a6366646927f20a952f788e960a0c2fca6b45]);
        vk.Z = Pairing.G2Point([0x1b34f9873269caf4b37776af47e8cfaaf10c7c500017fa844e7669bd0f7d9bd0, 0x7f230e86d26ca869655831d4c029c231105b919fb977e1c52f20cc734563d4a], [0x24f186a6a25a723c2eacb56d6732590a408bc9d6ae7054c920f95e1a0840b651, 0xf726fdae3d573e8902fb7bc12e6f547c77ff3c5e6bdaaf9ccaa302fc8ba2119]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(0x43f0b73433c737e463d56c91dfc256e1fa1a93b55fba2dfea709e1d28dc85a4, 0x29593abebf44223e9e8b95e4866068a4f130ff2ea20e7a46753b4c30b2f00d38);
        vk.IC[1] = Pairing.G1Point(0x2d683f94df9b984c229d8b409749f8a5154b36d04a00b50300aec3372a36c585, 0x2b1111cd99908fbc75d2126c14a2cb392086384cc7ab7cf7371ad8a02de24d0d);
        vk.IC[2] = Pairing.G1Point(0x2855a3109ac9a8dcff8280c04736f0e9d85a1a27001f1b30cd006e968243cd6d, 0xa7a7d79fe9e340151ac022be7ecccc26c0f53bf6cb66f9d1fac76e32a6063bd);
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
            uint[2] input
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
