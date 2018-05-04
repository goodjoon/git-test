function Wallet() {}

Wallet.prototype.constructor = function(_web3) {
        var web3 = _web3;
        var accounts = null;
        var defaultAccountIndex = 0;

        this.getWeb3 = function(){
            return this.getWeb3;
        };

        this._loadAccounts = function() {
            this.accounts = web3.eth.accounts;
        }


        // Initialize
        _loadAccounts();
}

Wallet.prototype.setDefaultAccount = function(accountIndex) {
    if (accountIndex >= this.accounts.length)
        throw "Account Index out of Bound";

    this.defaultAccountIndex = accountIndex;
}

Wallet.prototype.getDefaultAddress = function() {
    return this.accounts[defaultAccountIndex];
}

module.exports = Wallet;