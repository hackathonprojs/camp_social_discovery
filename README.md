# Reunion - Web3 Social Network 

Reunion is a Web3 social network Dapp built on the Camp Network. This project integrates Web2 social data into Web3, enabling seamless interactions and connections across platforms. Developed using HTML5, JavaScript, React, and Solidity, Reunion aims to provide a vibrant and engaging social experience in the decentralized world.

- The contracts current deployed on Camp Network V2:
https://explorer.camp-network-testnet.gelato.digital/address/0x28ed5445bcA9163aee1f7b7A78464CfA8f835f07?tab=contract

## Features

1. **ENS Subdomain Provisioning:**
   - Provides users with an ENS subdomain, prioritizing their existing Twitter, YouTube, and Spotify usernames.
   - Imports users' original profile pictures upon joining.

2. **Reloading Web2 Social Relationships:**
   - Re-establishes social connections from Web2 in the Web3 environment.
   - Users find their Web2 friends on the Reunion Network.

3. **Invitations and Recommendations:**
   - Allows users to invite friends who haven't joined yet.
   - Enables users to post recommendations on traditional social media platforms.

4. **Referral System:**
   - Requires new users to specify a referrer when joining the network.
   - Rewards referrers with tokens for each new user they bring in.

## Tech Stack

- **Frontend:**
  - HTML5
  - JavaScript
  - React

- **Smart Contracts:**
  - Solidity

- **Tools and Libraries:**
  - Web3.js
  - Ethers.js
  - Truffle
  - OpenZeppelin

## Getting Started

### Prerequisites

- Node.js
- npm or yarn
- Truffle
- Ganache (for local development)
- MetaMask (or any other Web3 wallet)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/reunion-web3-dapp.git
   cd reunion-web3-dapp
   ```

2. Install dependencies:
   ```bash
   npm install
   # or
   yarn install
   ```

3. Compile the smart contracts:
   ```bash
   truffle compile
   ```

4. Deploy the smart contracts:
   ```bash
   truffle migrate --network development
   ```

5. Start the React development server:
   ```bash
   npm start
   # or
   yarn start
   ```

### Configuration

1. Configure your local blockchain (e.g., Ganache) and update the `truffle-config.js` file with the correct network settings.

2. Update the `src/config.js` file with your smart contract addresses and other relevant configurations.

### Usage

1. Open the application in your browser:
   ```
   http://localhost:3000
   ```

2. Connect your Web3 wallet (e.g., MetaMask).

3. Start exploring the Reunion network:
   - Claim your ENS subdomain.
   - Reconnect with your Web2 friends.
   - Invite new users and earn rewards.

## Contributing

We welcome contributions to Reunion! To contribute, follow these steps:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes and commit them:
   ```bash
   git commit -m 'Add some feature'
   ```
4. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Thanks to the developers of the Camp Network for their support and resources.
- Special thanks to the open-source community for their valuable contributions and feedback.
