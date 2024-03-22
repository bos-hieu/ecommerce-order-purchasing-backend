# Ecommerce Order Purchasing Smart Contract
- **Class**: CCMP 603 - Fundamentals of Blockchain
- **Type**: Assignment
- **Member**: Le, Trung Hieu

## Before running
#### Step 1: Install Ganache
- Download and install Ganache from [here](https://www.trufflesuite.com/ganache)
- Run Ganache and create a new workspace

#### Step 2: Install Metamask
- Install Metamask extension for your browser
- Copy the seed phrase and save it for later use
- Create a new account and import the first account from Ganache
- Switch to the local network

#### Step 1: Install truffle
```
npm install -g truffle
```
#### Step 3: Install dependencies
```
npm install
```

#### Step 4: Create .env file in the root directory
By copy .env.example and rename it to .env. Then fill in the following information:
```
MNEMONIC="your-metamask-seed-phrase"
API_URL="https://sepolia.infura.io/v3/your-infura-api-key"
```

## Compile smart contract
```
truffle compile
```

## Deploy smart contract to target network
#### Ganache (default)
```
truffle migrate --network development
```
#### Sepolia Ethereum Testnet
```
truffle migrate --network sepolia
```

## Testing
```
truffle test
```