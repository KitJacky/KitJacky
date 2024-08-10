// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @author JackyKit (https://3jk.net)
/// @author X : JackyKit (https://x.com/kitjacky)

contract JKLabsRandomOracle {
    // Declarations
    address public oracle;
    bytes32 public randomNumber;

    // Events
    event RandomNumberReceived(bytes32 randomNumber);

    // Constructor
    constructor(address _oracle) {
        oracle = _oracle;
    }

    // Modifiers
    modifier onlyOracle() {
        require(msg.sender == oracle, "Only the oracle can call this function");
        _;
    }

    // Main Functions
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

    // Internal Functions
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
}
