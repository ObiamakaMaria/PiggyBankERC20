PiggyBank DeFi Savings Protocol
Overview
PiggyBank is a decentralized finance (DeFi) protocol designed to help users save stablecoins with a fixed time horizon. It allows users to deposit USDC, USDT, or DAI tokens and encourages long-term saving by implementing a 15% early withdrawal fee, which is redirected to the protocol developers. Each user gets their own personal PiggyBank contract instance to manage their savings.
Key Features

Personal Savings Contracts: Every user gets their own dedicated PiggyBank contract
Multi-Token Support: Accepts USDC, USDT, and DAI stablecoins
One-Year Time Horizon: Designed for long-term savings with a one-year maturity period
Early Withdrawal Disincentive: 15% fee on early withdrawals to encourage commitment
Purpose-Driven Saving: Each PiggyBank is created with a specific saving purpose
Factory Pattern: Easy deployment of new PiggyBank instances via a central factory

Smart Contracts
PiggyBank.sol
The core savings contract that allows users to:

Deposit supported stablecoins
Track balances, deposit times, and withdrawal status for each token
Withdraw funds (with or without penalty, depending on time elapsed)
Check remaining time until maturity
View current balances

PiggyBankFactory.sol
A factory contract that:

Creates new PiggyBank instances for users
Keeps track of all deployed PiggyBanks
Provides lookup functions to find PiggyBanks by owner
Uses CREATE2 for deterministic address generation
Automatically manages salt generation for contract deployment

Link to verified contract on etherScan : https://sepolia.etherscan.io/address/0xB9674f9c30ccd62E83d9477A82A92459820B094c#code