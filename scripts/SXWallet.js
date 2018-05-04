function Wallet(_web3) {

    var web3 = _web3;
    var defaultAccountIndex = 0;

    this.getWeb3 = function(){
        return this.getWeb3;
    };

    this._loadAccounts = function() {
        this.accounts = web3.eth.accounts;
    }

    this.getDefaultAccountIndex = function() {
        return defaultAccountIndex;
    }

    this.setDefaultAccountIndex = function(accountIndex) {
        if (accountIndex >= this.accounts.length)
            throw "Account Index out of Bound";

        defaultAccountIndex = accountIndex;
    }

    this.getAccounts = function() {
        var accounts = {};
        console.log("index : " + defaultAccountIndex);
        for (var i = 0 ; i < this.accounts.length ; i++) {
            accounts[i] = {
                "address" : this.accounts[i],
                "default" : i == defaultAccountIndex
            };
        }

        return accounts;
    }

    this.getDefaultAddress = function() {
        return this.accounts[this.getDefaultAccountIndex()];
    }


    // Initialize
        this._loadAccounts();
}

Wallet.prototype.test = function() {
    console.log("TEST");
}

module.exports = Wallet;