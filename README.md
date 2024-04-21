## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy
Load environment variables
```shell
$ source .env
```

Deploy the contract
```shell
$ forge create ./src/CastClouds.sol:CastClouds --rpc-url $BASE_SEPOLIA_RPC --constructor-args 0x6bd62FeB486Bf699Ac04eD6DC09dE36D11720509 --account deployer
```

Verify the contract
```shell
forge verify-contract 0xb6BDC64F243350AD1220dfd1Ab86bcbBbC42C526 ./src/CastClouds.sol:CastClouds --constructor-args $(cast abi-encode "constructor(address)" 0x6bd62FeB486Bf699Ac04eD6DC09dE36D11720509) --chain 84532 --watch
```

Base Sepolia deployment address: 0xb6BDC64F243350AD1220dfd1Ab86bcbBbC42C526