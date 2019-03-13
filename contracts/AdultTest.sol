pragma solidity >=0.4.21 <0.6.0;
import "contracts/Pairing.sol";
contract AdultTest {
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
        vk.H = Pairing.G2Point([0x20324bea62fc3fb4d83e7751a5e04c3063d10b5241b1931983b4b63c0d1a931a, 0x12b520992451a945100b5f6689de02c316fb0a7db5690ab00fda59538bf12811], [0x283ece944596543445816eccaf8b699ebbeba7a69ab3c2342a5fdd2f89070222, 0xde193bd6a890901ededaa1a42ccee9281a515d013ab2fbc8d05a416772f7e29]);
        vk.Galpha = Pairing.G1Point(0x298948f88e0b7a4df423144fbfca7d3568f34e63e24eaf950da035ebc30e249c, 0x1ac55f9b6f17958579f91726208eb20414a129bf554b1cc3b4c62f8d7accc9d2);
        vk.Hbeta = Pairing.G2Point([0x21fd1dadede5d394173b16815ca136d660a9472e3998227f8b187ce4201c619e, 0x28f2a7ff3bb0c927a1134d8d31805d48cf957adeb19b7f0b0de42f66ab941ea3], [0x3853b4728722d6aa5e823844c7dbdeffb19ba125e3800f2b5b1d93a239c88ef, 0x2b7679b39249fd08fcafc1308fe31a7b784271de3e238c456bf55034e19cb9a7]);
        vk.Ggamma = Pairing.G1Point(0xfe3913bb2f6b57503a457723cb9bb8fe9ed564eb9e6427596352bbd2e1ffe51, 0x21b9e93fd3bd0c264a5c07c121e273721e5cf5bc0a284eba866c5e9cf8f60919);
        vk.Hgamma = Pairing.G2Point([0x21b9dd69a888ea4e397e505432714727e9fd3fc2f8678459c716330e4d54c7d4, 0xdef43ebe4c5663eacced647a3208af032743bd2819d3120285c115f6bce045a], [0xa92f985ef268fa8cc2e9b9f771b1f1f5924cb341d004e5cb80a8e6ce0b2ad89, 0xef7e80ed77c6487366e8083969b1b9cc5a852a7657e3b6ddff4a0703eb3a895]);
        vk.query = new Pairing.G1Point[](2);
        vk.query[0] = Pairing.G1Point(0x12ffe2d07f304de98b5d0e427f6c3031ccc0be2973c02e885953bfa20af019d0, 0xfd9bcf2d904ee0cfd4014226f7464afe524e343fdcbd950a997dcc747b85dc4);
        vk.query[1] = Pairing.G1Point(0x315e47ffdc75e66b2821cf741ed3f363a6bf6a78b1d35d745e52c03048e145, 0x70bbb2d701746a701d413c45c8dd023f3aeeb21d63d9932061603c676b7a1fb);
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
            uint[1] input
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
