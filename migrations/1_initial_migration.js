const Migrations = artifacts.require("Migrations");
const Pairing = artifacts.require("Pairing");
const BN256G2 = artifacts.require("BN256G2");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(BN256G2);
  deployer.deploy(Pairing);
};
