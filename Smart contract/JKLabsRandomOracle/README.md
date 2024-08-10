# JKLabsRandomOracle

Last Updated: 2024-07-18
Version 0.4


arbiscan: https://arbiscan.io/address/0x9F0315Dd78887B94199F02cBe1387f3D168F7532


## Introduction
**JKLabsRandomOracle** is a prototype developed as part of a personal research project to solve the problem of predictability of randomness within an Ethernet Virtual Machine (EVM). The project aims to develop a simplified version of the Chainlink Verifiable Random Function (VRF) using off-chain random generation and on-chain authentication using cryptographic signatures. The prototype is currently in its fourth beta version and focuses on integrating algorithms such as Mimblewimble (Elliptic Curve Cryptography) and ZK to enhance the security and unpredictability of randomness in smart contracts. Also, the backend is currently being developed in python, but since I have a vision of releasing a saas version, I won't make the backend public at this stage as I'm still developing it and doing research for Mimblewimble ( https://andrea.corbellini.name/2015/05/17/elliptic-curve-cryptography-a-gentle-introduction/ ).

### Motivation
In the context of blockchain and smart contracts, the generation of unpredictable random numbers represents a significant challenge due to the deterministic nature of the EVM. The traditional methods of generating randomness on-chain are susceptible to manipulation or prediction, which may result in potential security vulnerabilities. To mitigate these risks, the JKLabsRandomOracle project investigates the generation of randomness off-chain, with verification on-chain. This approach aims to provide a more secure and reliable method for introducing randomness into smart contracts, particularly in use cases such as gaming, lotteries, and decentralized finance (DeFi) applications.

### Implementation and Testing
This prototype has undergone several iterations, reaching its fourth testing version. It has been deployed and tested on the Arbitrum Mainnet, with the smart contract address available on Arbiscan for review: [Contract on Arbiscan](https://arbiscan.io/address/0x9f0315dd78887b94199f02cbe1387f3d168f7532#code). A transaction example demonstrating the receipt and verification of a random number can be found here: [Transaction on Arbiscan](https://arbiscan.io/tx/0x3efbea1a71a7fc949fe473ce9a6a9322a795bb989555dd6e5ec61773d556084b).


##JKLabsRandomOracle (POC)

### Overview

`JKLabsRandomOracle` is a proof of concept (POC) developed to explore generating and verifying randomness in a blockchain environment. The project focuses on producing randomness off-chain using cryptographic methods like Mimblewimble and zk-proofs and then verifying this randomness on-chain. This POC demonstrates the feasibility of securely integrating off-chain randomness into smart contracts, which can be used for various decentralized applications.

### POC Data Example

The following table shows an example of the data generated and used in the `JKLabsRandomOracle` POC. This data was part of a transaction recorded on the Arbitrum network.

#### Example Data

| #  | Name                     | Type    | Data                                                                                                                                   |
|----|--------------------------|---------|----------------------------------------------------------------------------------------------------------------------------------------|
| 0  | `_randomNumber`           | uint256 | 17618359812606458698                                                                                                                    |
| 1  | `_signature`              | bytes   | 0x955fc58288a82a724ef8d8d4bb54ac07930b2b558584a88ed675e69e9a8dbdd47a85c500debd00ecb4ddcdcdce05729a048dbe1f3e9bfcd46ac594ecda65a1831b  |
| 2  | `_publicKey`              | bytes   | 0x273949b73362c4503690ff7befc34991e995ce43e36142695b82d62a0e9f3915e782b2e13c69588e08f07622df5d4e6c14bf67e010415d128fa4fadc69afa2d3   |
| 3  | `_mimblewimbleProofValid` | bool    | true                                                                                                                                    |

**Transaction Link:** [Arbitrum Transaction on Arbiscan](https://arbiscan.io/tx/0x3efbea1a71a7fc949fe473ce9a6a9322a795bb989555dd6e5ec61773d556084b)

#### Description of Data

- **_randomNumber**: A 256-bit random number generated off-chain.
- **_signature**: The cryptographic signature proving the authenticity of the random number.
- **_publicKey**: The public key associated with the signature, used to verify the authenticity.
- **_mimblewimbleProofValid**: A boolean value indicating whether the Mimblewimble proof is valid.

This data was generated during a POC test of `JKLabsRandomOracle` and serves as a proof that the off-chain generated randomness and its associated proofs can be effectively verified on-chain.


---


## Key Sections of the Code

### 1. **Attaching Libraries**
The smart contract primarily uses built-in Solidity features and does not import external libraries. However, the contract leverages ECDSA and other cryptographic functions inherent to Solidity for signature verification.

### 2. **Declarations**
This section includes the core variables of the contract, such as the oracle's address and the latest random number received. These declarations define the fundamental state of the contract.

```solidity
address public oracle;
bytes32 public randomNumber;
```

### 3. **Events**
Events are used to emit key actions within the contract, such as the receipt of a new random number. This helps external interfaces track and react to changes within the contract.

```solidity
event RandomNumberReceived(bytes32 randomNumber);
```

### 4. **Modifiers**
Modifiers are utilized to restrict access to certain functions, ensuring that only authorized entities, like the oracle, can perform specific actions within the contract.

```solidity
modifier onlyOracle() {
    require(msg.sender == oracle, "Only the oracle can call this function");
    _;
}
```

### 5. **Admin Functions**
Admin functions are utilized to manage the contract's state, including setting the oracle address during contract deployment. These functions provide the necessary administrative control over the contract.

```solidity
constructor(address _oracle) {
    oracle = _oracle;
}
```

### 6. **Getter Functions**
Getter functions allow external entities to retrieve important data from the contract, such as the current random number. These functions provide read-only access to the contract's state.

In this prototype, there isn't an explicit getter function since the `randomNumber` is publicly accessible.

```solidity
bytes32 public randomNumber;
```

### 7. **Setter Functions**
Setter functions are used to update the contract's state. The `receiveRandomNumber` function is the core setter function in this prototype, allowing the oracle to submit a new random number, which is then verified and stored on-chain.

```solidity
function receiveRandomNumber(
    uint256 _randomNumber,
    bytes memory _signature,
    bytes memory _publicKey,
    bool _mimblewimbleProofValid
) public onlyOracle {
    require(_mimblewimbleProofValid, "Invalid Mimblewimble proof");

    bytes32 messageHash = keccak256(abi.encodePacked(_randomNumber));
    require(verifySignature(messageHash, _signature, _publicKey), "Invalid signature");

    randomNumber = bytes32(_randomNumber);
    emit RandomNumberReceived(randomNumber);
}
```

### 8. **Internal Functions**
Internal functions are used to handle the core logic of the contract, such as verifying cryptographic signatures. These functions are essential for ensuring that the data received by the contract is secure and authentic.

```solidity
function verifySignature(bytes32 _hash, bytes memory _signature, bytes memory _publicKey) public pure returns (bool) {
    address recoveredAddress = recoverSigner(_hash, _signature);
    return recoveredAddress == address(uint160(uint256(keccak256(_publicKey))));
}

function recoverSigner(bytes32 _hash, bytes memory _signature) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    (v, r, s) = splitSignature(_signature);

    return ecrecover(_hash, v, r, s);
}

function splitSignature(bytes memory _signature) internal pure returns (uint8, bytes32, bytes32) {
    require(_signature.length == 65, "Invalid signature length");

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
        r := mload(add(_signature, 32))
        s := mload(add(_signature, 64))
        v := byte(0, mload(add(_signature, 96)))
    }

    return (v, r, s);
}
```

---


## Donations

Hi everyone! I'm JackyKit, and I'm really happy to have you here. If you'd like to connect or chat, please don't hesitate to reach out to me. I'd love to hear from you! >> Find me on [X](https://x.com/kitjacky) :-P.

### Support my work and my labs

This project was created in my spare time to share something interesting and useful with the community. Although GitHub hosts this project for free, the backend is using its own server and rented data centre, so maintaining and improving this project and my own lab requires a lot of time, effort and money. If you enjoy using this project and would like to support its continued development, please consider buying me a cup of coffee! I must have two cups a day, so every cup counts!

You can donate via Ethereum to the following address:

**ETH Address:** `0x5b6DB94a3c92Cc8095CeE065265412A700a07405`

Your contributions, no matter how small, go a long way in keeping this project alive and thriving. I genuinely appreciate any support you can offer, whether it’s through a donation, spreading the word, or contributing directly to the project. Thank you so much!

### Other Ways to Support

If you re unable to donate but still want to help, there are several other ways you can contribute:

- **Star the Repository:** If you find this project helpful or interesting, please consider starring the repository. It helps increase visibility and signals to others that this is a project worth exploring.
- **Contribute:** Have an idea, a suggestion, or improvements in mind? Feel free to fork the repo and submit a pull request. Contributions are always welcome and appreciated!
- **Share:** Spread the word by sharing this project with others who might benefit from it. Every share helps grow the community.

Thank you for your support in whatever form it takes. Together, we can continue to make this project even better!

---
feel free to reach out to me on [X](https://x.com/kitjacky)
JK Labs : https://3jk.net
