require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({"wallet":[function(require,module,exports){
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
},{}]},{},[]);
