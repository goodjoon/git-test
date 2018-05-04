// Factory "morphs" into a Pudding class.
// The reasoning is that calling load in each context
// is cumbersome.

(function() {

  var contract_data = {
    abi: [{"constant":false,"inputs":[{"name":"_id","type":"uint256"}],"name":"addSome","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_id","type":"uint256"}],"name":"getSome","outputs":[{"name":"id","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"_id","type":"uint256"}],"name":"isExist","outputs":[{"name":"","type":"bool"}],"type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"condition","type":"bytes32"}],"name":"Message","type":"event"}],
    binary: "606060405261024b806100126000396000f3606060405260e060020a60003504630e25012b81146100315780632e7f464914610093578063ca8f8ff3146100b0575b005b61002f600435600081815260208190526040902081815560018101805473ffffffffffffffffffffffffffffffffffffffff1916331790557f737472696e67206461746100000000000000000000000000000000000000000060029091015550565b6004356000908152602081905260409020545b6060908152602090f35b6100a660043560008181526020819052604081205460019082141561011f57507f69642875696e7429203d3d203000000000000000000000000000000000000000606090815281907f0e0baaba014023df9b5d9440d5ceb3bb339a70cf93635321b1e4e2e03832a71990602090a15b6000600050600084815260200190815260200160002060005060010160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16600014156101ca57507f61646472286164647265737329203d3d20300000000000000000000000000000606090815281907f0e0baaba014023df9b5d9440d5ceb3bb339a70cf93635321b1e4e2e03832a71990602090a15b60006000506000848152602001908152602001600020600050600201600050546000600102141561024557507f64617461286279746573333229203d3d20300000000000000000000000000000606090815281907f0e0baaba014023df9b5d9440d5ceb3bb339a70cf93635321b1e4e2e03832a71990602090a15b9291505056",
    unlinked_binary: "606060405261024b806100126000396000f3606060405260e060020a60003504630e25012b81146100315780632e7f464914610093578063ca8f8ff3146100b0575b005b61002f600435600081815260208190526040902081815560018101805473ffffffffffffffffffffffffffffffffffffffff1916331790557f737472696e67206461746100000000000000000000000000000000000000000060029091015550565b6004356000908152602081905260409020545b6060908152602090f35b6100a660043560008181526020819052604081205460019082141561011f57507f69642875696e7429203d3d203000000000000000000000000000000000000000606090815281907f0e0baaba014023df9b5d9440d5ceb3bb339a70cf93635321b1e4e2e03832a71990602090a15b6000600050600084815260200190815260200160002060005060010160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16600014156101ca57507f61646472286164647265737329203d3d20300000000000000000000000000000606090815281907f0e0baaba014023df9b5d9440d5ceb3bb339a70cf93635321b1e4e2e03832a71990602090a15b60006000506000848152602001908152602001600020600050600201600050546000600102141561024557507f64617461286279746573333229203d3d20300000000000000000000000000000606090815281907f0e0baaba014023df9b5d9440d5ceb3bb339a70cf93635321b1e4e2e03832a71990602090a15b9291505056",
    address: "",
    generated_with: "2.0.8",
    contract_name: "ConditionTest"
  };

  function Contract() {
    if (Contract.Pudding == null) {
      throw new Error("ConditionTest error: Please call load() first before creating new instance of this contract.");
    }

    Contract.Pudding.apply(this, arguments);
  };

  Contract.load = function(Pudding) {
    Contract.Pudding = Pudding;

    Pudding.whisk(contract_data, Contract);

    // Return itself for backwards compatibility.
    return Contract;
  }

  Contract.new = function() {
    if (Contract.Pudding == null) {
      throw new Error("ConditionTest error: Please call load() first before calling new().");
    }

    return Contract.Pudding.new.apply(Contract, arguments);
  };

  Contract.at = function() {
    if (Contract.Pudding == null) {
      throw new Error("ConditionTest error: Please call load() first before calling at().");
    }

    return Contract.Pudding.at.apply(Contract, arguments);
  };

  Contract.deployed = function() {
    if (Contract.Pudding == null) {
      throw new Error("ConditionTest error: Please call load() first before calling deployed().");
    }

    return Contract.Pudding.deployed.apply(Contract, arguments);
  };

  if (typeof module != "undefined" && typeof module.exports != "undefined") {
    module.exports = Contract;
  } else {
    // There will only be one version of Pudding in the browser,
    // and we can use that.
    window.ConditionTest = Contract;
  }

})();
