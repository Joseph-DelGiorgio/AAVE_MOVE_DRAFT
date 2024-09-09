# Aptos Move Lending Protocol

This project implements a basic lending protocol similar to Aave on the Aptos blockchain using the Move language. It provides fundamental functionality for decentralized lending and borrowing of crypto assets.

## Features

- Deposit assets into the lending pool
- Borrow assets from the lending pool
- Repay borrowed assets
- Withdraw deposited assets
- Simple interest rate model
- Basic collateralization system

## Contract Structure

The main contract `aave_like` contains the following key components:

- `LendingPool`: Manages the total deposits, borrows, and interest rate for each asset type.
- `UserAccount`: Tracks individual user deposits, borrows, and last update timestamp.
- `initialize_pool`: Sets up the lending pool for a specific coin type.
- `deposit`: Allows users to deposit assets into the lending pool.
- `borrow`: Enables users to borrow assets if they have sufficient collateral.
- `repay`: Allows users to repay their borrowed assets.
- `withdraw`: Enables users to withdraw their deposited assets.

## Getting Started

### Prerequisites

- Aptos CLI
- Move compiler

### Compilation

To compile the contract, run the following command in the project root:

```bash
aptos move compile --named-addresses deployer_addr=0x1
