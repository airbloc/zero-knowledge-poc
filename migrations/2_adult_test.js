const AdultTest = artifacts.require("AdultTest");
const Pairing = artifacts.require("Pairing");
const BN256G2 = artifacts.require("BN256G2");
module.exports = function(deployer) {
    deployer.then(async () => {
        await deployer.link(Pairing, AdultTest);
        await deployer.link(BN256G2, AdultTest);
        await deployer.deploy(AdultTest);
    });
};
