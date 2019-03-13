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
        vk.H = Pairing.G2Point([0x268f1c34f265daa404ef6167a951590c7046246076e32158d9030a373ff5a37e, 0x17e6290352224f770c05ce69cf80d05c4ecadbc0ead03a975d62cf1b7926639a], [0xdb864de6a7245e721208fabb29409647e1cbb50b808a41a5c1f49e7720c08ed, 0x149fc8b7aa22bafbc8ea693323adfb5dfe64d5bf349c1ffe1ef2f761ad607e3d]);
        vk.Galpha = Pairing.G1Point(0x24939aa0ff56ed5913a37c9f400eff9819a8c59937e8a62d67a89f12fb008dd1, 0x708836508f0ca3f1bea21f94bb4e14d971de336a1f0e60af96dbbfb5a9e6795);
        vk.Hbeta = Pairing.G2Point([0x2f9510dd0ef80fb47d9a52adadd6d78a43ed565d7f83bc840e5d9ac939acc1f8, 0x102d8092b72a7ff3226600700bbb319e5333863502b57db590b05c25d6a93854], [0x137adcac12917be3659c49fb2f66f235dc06dbec0bc45a19a3be2f87473fdbd8, 0x2b4021e1875f33459dd9ce3ea958fd67080afc53498e73eb81054e5153acbca4]);
        vk.Ggamma = Pairing.G1Point(0xaec3b728476a1b1b485c6d401622774ac9c99a462a8a711104d6dce1d15f8bd, 0x1a922ce57cc8a7975429e1e467707ffbe6f7c792cfbda2e12199e22be153a3d9);
        vk.Hgamma = Pairing.G2Point([0xe3265fdd8f235c89c42feae63bc6e7982cf6929ec0075ce2fdb2a4802a1d366, 0x1a9d517daad56956cb783f76a738ea5549f40336ea91c134a056e39e63340c50], [0x12683f04342018d5fcf9774bfa32e7f96dd47f76730d3335da8c7b37f5e62107, 0x16c71fa1bb4b0e4977a6c697f62453ede9e1c31e23112fab17b559a060ab98c0]);
        vk.query = new Pairing.G1Point[](5);
        vk.query[0] = Pairing.G1Point(0x2573e9e38f1b6bf88381617a772a41748ca608e6965c02a2bd11730877fe228b, 0x139f715aa365bde09bf03d59148d31e6d6c47fee3a52e07de4bd8b6d974be196);
        vk.query[1] = Pairing.G1Point(0x1498f50bab33166a0ae74edcaaf99a3e45da778345314c2e653836edb75fdc72, 0xe57a4e94d80f0ffb932d5c2d1b727be9eb768e8f61e3de96f48314e81073cea);
        vk.query[2] = Pairing.G1Point(0x6f6a9dca8f187267680b53f8931bda1b9d4fa292fd1f8524a6acb8e7e8d5b8b, 0x1760a2e8578cbe435b448d4efee30f62b8f0daa5462bd12f81aad352a57c6a5a);
        vk.query[3] = Pairing.G1Point(0x25db61b47cc8795993d4e8c4bf77f8bd6208bd8d0bb1a13aa536d2167e3954e6, 0x2fb4be363a10219bd6ca74b214207b373746a3e522fb5a3efc161d985c08490c);
        vk.query[4] = Pairing.G1Point(0x2c3cf0fa4babbb1ade2b0e6c7f045d518a554e0cf70859586f23d1706ff0599e, 0x154dd23b5cea2e5a0d5651ac102ab933fa40d98ddd41b9d117d1b38d98e17cf0);
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
            uint[4] input
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
