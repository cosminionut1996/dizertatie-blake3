const Migrations = artifacts.require("Migrations");
const Blake2 = artifacts.require("Blake2");
const Blake3 = artifacts.require("Blake3");
const F = artifacts.require("F");



module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Blake2);
  deployer.deploy(Blake3);
  deployer.deploy(F);
};
