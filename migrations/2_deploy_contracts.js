const MarxCoin = artifacts.require("./contracts/MarxCoin.sol")

module.exports = function(deployer) {
	deployer.deploy(MarxCoin);
};