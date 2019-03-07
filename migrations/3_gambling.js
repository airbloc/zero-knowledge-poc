const AdultTest = artifacts.require("AdultTest");
const Gambling = artifacts.require("Gambling");

module.exports = function(deployer) {
    deployer.then(async () => {
        const adultTest = await AdultTest.deployed();
        await deployer.deploy(Gambling, adultTest.address);        
    });
};
