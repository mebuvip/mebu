# MemeBuddha Token Contract

![Audit Status](https://img.shields.io/badge/Audit-Passed-brightgreen)

MemeBuddha is an ERC20 token with unique features:

- **6% fee on sells**: A fee is applied to all sell transactions and is distributed as follows:
  - 2% is burnt, reducing the total supply over time.
  - 2% is transferred to a charity wallet.
  - 2% is transferred to a team wallet.
- **Liquidity Pool Specific**: The fees are only applied when tokens are transferred to specific liquidity pools. The owner of the contract can add or remove these liquidity pools.
- **Pausable**: The contract owner can pause all token transfers.
- **Burnable**: Tokens can be burnt, reducing the total supply.

## Contract Addresses

Mainnet: TBD  
Testnet: TBD

## Audit

The MemeBuddha contract has been audited by [Cyberscope](https://github.com/mebuvip/mebu/blob/main/audit.pdf). No critical issues were found.

## Built With OpenZeppelin

The MemeBuddha contract is built using the [OpenZeppelin](https://openzeppelin.com/) contracts library, a community-driven framework for secure smart contract development.

## License

This project is licensed under the MIT License.

## Disclaimer

This contract has been audited and tested thoroughly. However, use at your own risk.
