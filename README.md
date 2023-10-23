# Prediction Contract

This contract facilitates a prediction bet between two parties, based on the price of WBTC (Wrapped Bitcoin) in USDC (USD Coin) after a certain time period. 

## Features

- The contract uses the ERC20 standard for token transactions.
- It is designed to facilitate a bet between two parties: a depositor of WBTC and a depositor of USDC.
- The bet is based on the price of WBTC in USDC, and is resolved after a set time period.
- The contract uses a data feed from API3's proxy contract to get the current price of WBTC in USDC.
- It has a function to close the prediction and resolve the bet, which can be called by any user.
- If the bet has not been initiated, users can return their funds.

## Setup

1. Deploy the contract with the addresses of the proxy contract and the USDC and WBTC token contracts as parameters.
2. The owner of the contract can set the proxy address using the `setProxyAddress` function.

## Usage

1. A user can deposit WBTC into the contract using the `depositWBTC` function. This will initiate the bet if USDC has already been deposited.
2. A user can deposit USDC into the contract using the `depositUSDC` function. This will initiate the bet if WBTC has already been deposited.
3. Once the bet has been initiated, it can be resolved by calling the `closePrediction` function after a set time period. The function reads the current price of WBTC in USDC from the data feed, and transfers all the deposited USDC and WBTC to the winner of the bet.
4. If the bet has not been initiated, users can return their funds using the `returnFunds` function.

## Note

- The `readDataFeed` function is a public view function that reads the WBTC/USDC price from the proxy contract and returns the current price and the timestamp of the latest price update. 
- For simplicity, this contract uses 2 USDC for every 1 WBTC.
- Be careful when interacting with this contract, as the winner of the bet will receive all the deposited USDC and WBTC.

# Create your own prediction contract

To Deploy this sample, fork this repos and type in the following commands

```shell
yarn install
npx hardhat compile
npx hardhat run scripts/deploy.ts --network mumbai
```