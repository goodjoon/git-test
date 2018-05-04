## MY Blockchain PoC-3 (Supply Chain PoC)

Proof of Concept for ethereum based smart contract application. 

## Objectives

* See effectiveness of Smart Contract based application development in productivity and architecture compared to traditional Client-Server based application development way
* See flexibilities of Contract based interface compared to traditional System Integration way

## Key Concepts

* **Organizations**
    * Supplier - Supply parts to Makers based on buy order and deliver parts through Transporter 
    * Maker - Maker buy parts from Supplier based on contract to Supplier
    * Transporter - Transporter deliver Supplier's parts to Maker based on contract to Supplier
    
* **Smart Contracts**
    * Maker make a supply contract with Supplier by `supply.sol`
    * Supplier make a transport contract with Transporter by `transport.sol`
    
* **Contract Connection**
    * Contracts `supply.sol` and `transport.sol` include terms of each other contract's partial condition

## How to make SCM work
- Compile supply.sol and transport.sol in Remix IDE
- replace abi and bytecodes in common.js file
- replace _url value in common.js file to proper JSON RPC URL
- create 3 new accounts with `geth account new` command
- adjust each party's account index in common.js file
    - manufacturer's default account index : 0
    - supplier : 1
    - transporter : 2
- transfer sufficient funds to each account
- deploy supply.sol contract by running manufacturer.html
- replace supply contract's address from `undefined` to deployed contract address in common.js
- deploy transport.sol contract by running transporter.html
- replace transport contract's address from `undefined` to deployed contract address in common.js
- run supplier.html with `?register=true` Query String to register supplier to supply.sol contract's supplier
