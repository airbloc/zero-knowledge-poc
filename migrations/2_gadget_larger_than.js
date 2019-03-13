const GadgetLargerThan = artifacts.require("GadgetLargerThan");
const Pairing = artifacts.require("Pairing");
const BN256G2 = artifacts.require("BN256G2");
module.exports = function(deployer) {
    deployer.then(async () => {
        await deployer.link(Pairing, GadgetLargerThan);
        await deployer.link(BN256G2, GadgetLargerThan);
        await deployer.deploy(GadgetLargerThan);
    });
};
