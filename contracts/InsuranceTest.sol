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
        vk.A = Pairing.G2Point([0x124916c2434b0b0be6e94b8a266afb73f9c94650fbdeeeac370e86fbb582daf3, 0x11213ba4ba3a15d332b0bcd537d15e2f24b7bac057a3e452cbdca3af902ea6ac], [0xa7480d58b132d5ec0d3336fa587d36e8c3bb07bf7abf21f5a5c26b90542c9b7, 0x2b46cea422c8b23cca7af66e07cbd77f3bf5bdeca7c23c0b4bba7acfb259977b]);
        vk.B = Pairing.G1Point(0x2fb2c6d8a2a674e4ce65852567d64871893abd6c08be1e310cc74559c1c5874f, 0x9a203d6177a6e2005e07fad2719215c76514137d0d888f6533a2155a97f4f52);
        vk.C = Pairing.G2Point([0x6fb7c5144a663f61976ed74a755a78a84dbae2ef72ea77f6e0d66849b943bb, 0xb00d3e61cac6aa89ac01b33318e732a48c70746b9e9d80fbe16f967f40d06bf], [0x1b75b1b5a9f7dbf0f9ed8afc42330e37e73998b1a6c28bbf5ab230f342fe7cfe, 0x1e7015cdd493f3e637b1eac32bf3a70fc83eca570657007b20f94ce292ac858b]);
        vk.gamma = Pairing.G2Point([0x234827c0e485a3fc53bca4f11652bd8751d7d755b439b057da0a17ca4cb955e2, 0x19f9dc335bc20cb74a0d8df3bd0a25ce75ca622b3644e5b49a4cac5c792446af], [0x139bc8560d254248c43a40f9d381c7121588e671b7026b35fe92631a8d4466b5, 0x10c69c6cfe6f655bfd56e2ffec289d26fbbfecace6132f37b7dc95a922981f6c]);
        vk.gammaBeta1 = Pairing.G1Point(0xae0faab404b31a8017bf9ef0df9a7d62c8a2d673abf2dc3d103058bf0e35fc6, 0x1fd6625c1d383f280ee5fe3fc77d0442a28acdd54dc01a77756e47b2e48f60f7);
        vk.gammaBeta2 = Pairing.G2Point([0x126d58d8b66de165f4ab7a1ad80b5145eae12d2f821a04e5e28cad4d737ef104, 0x1637f72048a175d3fe0b1b55930c3d95a5cd56e4ce7181e7c16a52ad3bf78536], [0x24cc5a621549b5b46840aa831e966e37931ef6950c68edd86956f95dab65c6f1, 0x100ac60dff7f7365f82d05b7808fe8e954b471a697dc4e1d6ded5cf39759f4b8]);
        vk.Z = Pairing.G2Point([0x24f3175fdb9993ceeb89422e09f6083ef0ee21a3ca379b5d688f9abe2fff661, 0xde89614976af6a2d28699e4be4f86e7ca66e624251aed27aad369dd4d060623], [0x209fee26d5c64f37ed09abcf5e7c48f86c7cfb0b21b4b994845eb546df3e871, 0x13f5cc17c71c0fea4a1cc838a5b7a534435b23d69aaa8320e8357e61b69763bd]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(0xe2420ffe307ef2051d3592ad0baea6b21ff6a8979190375fdb308059ace2891, 0x1c6f2d12119725f9430d6a195223ca70a8de5f7e26b02f4efb9236a1b4b21850);
        vk.IC[1] = Pairing.G1Point(0x2207b373a443c23d743d8a995c4cf51c5119a6bca5f7d5de467372c92e51e364, 0x7a1866ee72c6e7eec9d591baa64c9baaaff6e3e7260b8ab92932c1efb1149ee);
        vk.IC[2] = Pairing.G1Point(0x1e65e988657c6dc144394ad337a878a57d16624936040efcbdacbb4c728d1be0, 0x2522b5938f6c781723850aeb9a88d4029075973c0143e8e5f06008e325b32b06);
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
