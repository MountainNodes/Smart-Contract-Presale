const PrivateSale = artifacts.require("PrivateSale");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(PrivateSale, [accounts[0], accounts[1]], [70,30]);
};
