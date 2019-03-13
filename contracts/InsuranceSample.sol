pragma solidity >=0.4.21 <0.6.0;

import "./GadgetLargerThan.sol";
import "./EthereumClaimsRegistry.sol";

contract InsuranceSample {
    EthereumClaimsRegistry claimRegistry;
    GadgetLargerThan largerThan;

    // accepted age claim issuer.
    address constant ACCEPTED_ISSUER = address(0xf8b358b3397a8ea5464f8cc753645d42e14b79ea);

    // name of age claim (reusable)
    bytes32 constant CLAIM_AGE = keccak256(abi.encodePacked("ProofOfAge"));

    constructor(EthereumClaimsRegistry _claimRegistry, GadgetLargerThan _largerThan) public {
        claimRegistry = _claimRegistry;
        largerThan = _largerThan;
    }

    function splitByte32ToField(bytes32 _data) internal pure returns (uint128 a, uint128 b) {
        assembly {
            a := _data
            b := shl(_data, 128)
        }
    }

    /**
     * @dev Apply to insurance, only available for age above 20.
     */
    function applyInsurance(uint[2] proofA, uint[2][2] proofB, uint[2] proofC) external {
        bytes32 hashedAge = claimRegistry.getClaim(ACCEPTED_ISSUER, msg.sender, CLAIM_AGE);
        uint128 (h1, h2) = splitByte32ToField(hashedAge);

        // verify that msg.sender is age above 20, with commitment scheme
        uint[5] memory input = [uint(20), uint(h1), uint(h2), uint(1)];
        require(largerThan.verifyTx(proofA, proofB, proofC, input), "you must above age 20");
    }
}

