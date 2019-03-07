pragma solidity >=0.4.21 <0.6.0;
import "contracts/Pairing.sol";contract InsuranceTest {
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
        vk.H = Pairing.G2Point([0x1657147a08efc389474d09be6e32476e4125dd28c6d38fc1c92ffddaa9410aff, 0x88d055d843dad253f3189f2914be92d4e6f836e39122d8032448001af8a8658], [0x24fc228c498b6c65d7a2a90de6b9213df2cedcb71d7002bd24d69049121fb359, 0xa322abbf16082fc36ac09d58fb8a139d119b5a721fe83800319b66308c47b26]);
        vk.Galpha = Pairing.G1Point(0x2657a8ef968de1745b31651cfd55763c9c4b43720d4d6304a54e3b5484d29f7f, 0x2ebd0467ef5f3beab69554fc44417422a4b8738816d83a4e09a45aff3344f3bc);
        vk.Hbeta = Pairing.G2Point([0x12aabfa1416fedbc17641fed4da356f9f5e87e5c8d33d0eb044d1c66723a4b32, 0xd3a3d15ed1393559a099e7dd40f47e8df8129419e7be4d908f354483adc5da8], [0x6d958aab778bf9eb3726f70de3a9c7f875378e4467f25f221b2a3a68f1be1a7, 0x218977b695275506dd48e4f3b6d3009bc71248d6fb07f7dacb570a74abaaa99c]);
        vk.Ggamma = Pairing.G1Point(0x238dc970d3309a2a9feaa9c90cde08fd5c1369b52621e37186b6313d17f7549a, 0x15deced2a63b20bf274543009656d5f18ddabff8ba50a162d7ff2c3cfa41c235);
        vk.Hgamma = Pairing.G2Point([0x21af194cc92b2df906d7bd92d5f1d3a489584f4a0b76546055ac3f1d07d15883, 0x266f69c0706bec171b378bba16f7c25a4cc475c366c5b525f8bb8167262bd0b8], [0x172820d04a27ce42953ae4cf23b293f294021b1611fa09b92e697c410b8ec4a4, 0xb9470eecc8e29f0b353cba3ca8e244511645dee81f4cc87bef16d690d736ec9]);
        vk.query = new Pairing.G1Point[](3);
        vk.query[0] = Pairing.G1Point(0x208e730293c59b889f0c327d0f49c9f72b5a6021b378328d442729465b250673, 0x1d601a93e5a117a783c09ec2840eec345ed7c073d90d29237f2fbea1f904a71e);
        vk.query[1] = Pairing.G1Point(0x1249aaaf82c6aa7067f28cdd3d04b91579503a86e3cc8930eaeb9e2ae4601f0e, 0xc2740e82888ec3890c5dab5d4300f294965dcc3c169b3421bd6265092a10c44);
        vk.query[2] = Pairing.G1Point(0x15057c6230749d73d940edc6211f9f949b71ef305f97d47ee5874033e91055cf, 0x1b298ee5a497293ca61e3853de09ef58710ed2de75ac337c89216829def299c4);
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
            uint[2] input
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
