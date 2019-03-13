pragma solidity >=0.4.21 <0.6.0;
import "contracts/Pairing.sol";
contract GadgetLargerThan {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point H;
        Pairing.G1Point Galpha;
        Pairing.G2Point Hbeta;
        Pairing.G1Point Ggamma;
        Pairing.G2Point Hgamma;
        Pairing.G1Point[] query;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.H = Pairing.G2Point([0x1bd0651de25f9d9744b2efdb3bcccdb20019145bbbd989f290ea6f018e4e1cf9, 0x163329c2ef47d531c53c7153f8725e5b34e257dccd34fd32fd611e283f0b5a14], [0x2102d49d030daee2bb2080cbe9418e9f936ae6ce2df390676fe5256f4436bac5, 0x16e2e38d3d5d6b93749ece6ce2f0451af8e4cc940f2e4d42863c924558b215b3]);
        vk.Galpha = Pairing.G1Point(0x190de4c9e0ec8db10fe29fae99c411c8ff30745678dae3c21275ae8b81d27392, 0x1e0b796f8add68e401715cd569360d8d97345bc15291a7740e2e642228b9822f);
        vk.Hbeta = Pairing.G2Point([0x28fbf50d692c505862f21ebad7a955e15d6c86826bd6c9be57239237383e1da1, 0xc7e70c37378a239629b83c12e4aee4c0636d6cb5365bcbcc0b3152d4a33e105], [0x1e3ebc5cf179fce87c4279c9e962f31931cf9ea65176a1a437ca6c0ce0ec51b7, 0x2767d7b2d5ce6f2655494f4c120c3e8ebb5198e87494efe9bd965fc1ae4ed43f]);
        vk.Ggamma = Pairing.G1Point(0xf5a7bb4487a5dcc981232991e6ab5b619a6fd15d2d9d23fb430edbe199b2878, 0x190e895c483f9bb8ab3c01316449cd87ef4985ef2264af506d1ffa61d02ce0b4);
        vk.Hgamma = Pairing.G2Point([0x2872a3030f095b251000a1ca5d70d2e2224a1a3309302903952fde4e0acc0b41, 0x19db1632b45d967662a59ab55fd7461ab8b7a634d31e2d95cde8662d3ac0e177], [0x821e56b98589a9129294729309814029cf637b4b2dfc399f564c1cefc9c32f4, 0x1cdb060fad59f3e1188eeecdc26f64c9ecf65255c97792635decc1ee233700f5]);
        vk.query = new Pairing.G1Point[](6);
        vk.query[0] = Pairing.G1Point(0xa72646bc4f328522eede08580f50ba2c7acdf3b898e37d9133dab20e5a452a4, 0x1a9a55e4c1e7286316696228113dfbbe93b0f589506f6d90ca95ce14352cd8b5);
        vk.query[1] = Pairing.G1Point(0x2af93dd9b4926ec7c44d0d7be701cf47838c5575fd951be98a951c8a033841f, 0x15cd14c5ba31452dc6ad24078dd07fc83a09867d62944f97e09955292eee2de);
        vk.query[2] = Pairing.G1Point(0x22103ab57cdef73d5f8913c7505563c28745162442e0ec0f9cafb7005c73b242, 0xc1b06a3de426f77a3c4f7ac0776e11d61ee6733dac6aa76ff6ce59fe8f78d1d);
        vk.query[3] = Pairing.G1Point(0x1496dc2495c810f33a9deab83f209053fb092bbf3636104f0a26afa34c851fb9, 0x671dba3c2a688e388374d628df12c7a2bb3d9f2ea968962a0a8cbf9402938c4);
        vk.query[4] = Pairing.G1Point(0x9b55010194fb1588429283bab3bde4ed5fbca73d0d0b73ddd6abdf6665797be, 0x1c84ab91bec3861540db1599fc9af9471cef56d839907f243a9bef586543c958);
        vk.query[5] = Pairing.G1Point(0x2a6a13777407dac8e4d35865dde13fc7d5cb84116aa92ae005798295e6b84f59, 0x25b4d8cb0a5ef76a1c26204acc8ac8b05970dee8519ee255ce26f35a29cbd300);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.query.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.query[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.query[0]);
        /**
         * e(A*G^{alpha}, B*H^{beta}) = e(G^{alpha}, H^{beta}) * e(G^{psi}, H^{gamma})
         *                              * e(C, H)
         * where psi = \sum_{i=0}^l input_i pvk.query[i]
         */
        if (!Pairing.pairingProd4(vk.Galpha, vk.Hbeta, vk_x, vk.Hgamma, proof.C, vk.H, Pairing.negate(Pairing.addition(proof.A, vk.Galpha)), Pairing.addition(proof.B, vk.Hbeta))) return 1;
        /**
         * e(A, H^{gamma}) = e(G^{gamma}, B)
         */
        if (!Pairing.pairingProd2(proof.A, vk.Hgamma, Pairing.negate(vk.Ggamma), proof.B)) return 2;
        return 0;
    }
    event Verified(string s);
    function verifyTx(
            uint[2] a,
            uint[2][2] b,
            uint[2] c,
            uint[5] input
        ) public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
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
