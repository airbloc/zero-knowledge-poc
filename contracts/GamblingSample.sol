pragma solidity >=0.4.21 <0.6.0;
import "./AdultTest.sol";

contract Gambling {
    AdultTest verifier;

    constructor(AdultTest verifierAddr) public {
        verifier = verifierAddr;
    }

    function gamble(uint[2] a, uint[2][2] b, uint[2] c) public {
        uint[1] memory expectedOutput = [uint(1)]; // of course it must be true.
        bool isAdult = verifier.verifyTx(a, b, c, expectedOutput);
        if (!isAdult) {
            revert("Age under 19 is prohibited by the law 😉");
        }
        // do something
    }
}
