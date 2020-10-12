var HelloWorld = artifacts.require("HelloWorld");
var Blake3 = artifacts.require("Blake3");

module.exports = function(deployer) {
    deployer.deploy(HelloWorld);
    deployer.deploy(Blake3);
}
