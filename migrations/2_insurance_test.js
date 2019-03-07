const InsuranceTest = artifacts.require("InsuranceTest");
const Pairing = artifacts.require("Pairing");
const BN256G2 = artifacts.require("BN256G2");
module.exports = function(deployer) {
    deployer.then(async () => {
        await deployer.link(Pairing, InsuranceTest);
        await deployer.link(BN256G2, InsuranceTest);
        await deployer.deploy(InsuranceTest);
    });
};