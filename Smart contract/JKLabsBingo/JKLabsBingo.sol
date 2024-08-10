/**
 *  JK Labs bingo NFT v1.0
 *  2021-09-27
 */

/// @author JackyKit (https://3jk.net)
/// @author X : JackyKit (https://x.com/kitjacky)

//       ## ##    ##    ##          ###    ########   ######
//       ## ##   ##     ##         ## ##   ##     ## ##    ##
//       ## ##  ##      ##        ##   ##  ##     ## ##
//       ## #####       ##       ##     ## ########   ######
// ##    ## ##  ##      ##       ######### ##     ##       ##
// ##    ## ##   ##     ##       ##     ## ##     ## ##    ##
//  ######  ##    ##    ######## ##     ## ########   ######

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Attaching libraries
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// Declarations
contract Bingo is ERC721Enumerable, ReentrancyGuard, Ownable {
    // Constructor
    constructor() ERC721("Bingo game card", "Bingo") Ownable() {}

    // Internal functions
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function JK(uint256 input, uint256 tokenId) internal pure returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(input, toString(tokenId))));
        return string(abi.encodePacked(toString(rand % 100)));
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal pure returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));
        return sourceArray[rand % sourceArray.length];
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }


    // Admin Functions
    function JKClaim(uint256 tokenId) public nonReentrant onlyOwner {
        _safeMint(owner(), tokenId);
    }

    // Getter Functions
    function JKColor(uint256 tokenId) public pure returns (string memory) {
        uint256 rand = random(string(abi.encodePacked('88', toString(tokenId))));
        return string(abi.encodePacked('#', toString(rand % 7), '2', toString(rand % 9), toString(rand % 8), toString(rand % 6), '3'));
    }

    function BINGO(uint256 tokenId) public pure returns (string memory) {
        string memory JK1 = string(abi.encodePacked(JK(10, tokenId), ' ', JK(21, tokenId), ' ', JK(30, tokenId), ' ', JK(35, tokenId), ' ', JK(42, tokenId), ' ', JK(48, tokenId), ' ', JK(55, tokenId), ' ', JK(59, tokenId), ' ', JK(63, tokenId), ' ', JK(67, tokenId), ' '));
        string memory JK2 = string(abi.encodePacked(JK(69, tokenId), ' ', JK(70, tokenId), ' ', JK(95, tokenId), ' ', JK(102, tokenId), ' ', JK(111, tokenId), ' ', JK(125, tokenId), ' ', JK(134, tokenId), ' ', JK(142, tokenId), ' ', JK(156, tokenId), ' ', JK(166, tokenId), ' '));
        string memory JK3 = string(abi.encodePacked(JK(171, tokenId), ' ', JK(189, tokenId), ' ', JK(192, tokenId), ' ', JK(236, tokenId)));
        string memory output = string(abi.encodePacked(JK1, JK2, JK3));
        return output;
    }

    function tokenURI(uint256 tokenId) override public pure returns (string memory) {
        string memory jksvg1 = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 500 500"><style>.a,.c{fill:', JKColor(tokenId), ';}.b{fill:#fff;}.c{fill-rule:evenodd;}</style><defs></defs><rect class="a" width="497.5" height="497.88"/><rect class="b" x="6.8" y="6.8" width="480.5" height="484.22"/><polygon class="c" points="247.3 277.5 253.3 292.2 269.1 293.4 257 303.7 260.8 319.2 247.3 310.8 233.8 319.2 237.6 303.7 225.5 293.4 241.3 292.2 247.3 277.5"/>'));
        string memory jksvg2 = string(abi.encodePacked('<style>.JK{fill:', JKColor(tokenId), ';font-family:"Arial Black";font-weight:400;font-size:120%;}.st{font-size:100%;}.s{font-size:60%;}.tt{font-size:400%;</style>'));
        string memory jksvg3 = string(abi.encodePacked('<text x="53" y="165" class="JK t">', JK(10, tokenId), '</text><text x="53" y="235" class="JK t">', JK(21, tokenId), '</text><text x="53" y="305" class="JK t">', JK(30, tokenId), '</text><text x="53" y="378" class="JK t">', JK(35, tokenId), '</text><text x="53" y="452" class="JK t">', JK(42, tokenId)));
        string memory jksvg4 = string(abi.encodePacked('</text><text x="143" y="165" class="JK">', JK(48, tokenId), '</text><text x="143" y="235" class="JK t">', JK(55, tokenId), '</text><text x="143" y="305" class="JK t">', JK(59, tokenId), '</text><text x="143" y="378" class="JK t">', JK(63, tokenId), '</text><text x="143" y="452" class="JK t">', JK(67, tokenId)));
        string memory jksvg5 = string(abi.encodePacked('</text><text x="233" y="165" class="JK">', JK(69, tokenId), '</text><text x="233" y="235" class="JK t">', JK(70, tokenId), '</text><text x="233" y="305" class="JK t">', '', '</text><text x="233" y="378" class="JK t">', JK(95, tokenId), '</text><text x="233" y="452" class="JK t">', JK(102, tokenId)));
        string memory jksvg6 = string(abi.encodePacked('</text><text x="325" y="165" class="JK">', JK(111, tokenId), '</text><text x="325" y="235" class="JK t">', JK(125, tokenId), '</text><text x="325" y="305" class="JK t">', JK(134, tokenId), '</text><text x="325" y="378" class="JK t">', JK(142, tokenId), '</text><text x="325" y="452" class="JK t">', JK(156, tokenId)));
        string memory jksvg7 = string(abi.encodePacked('</text><text x="416" y="165" class="JK">', JK(166, tokenId), '</text><text x="416" y="235" class="JK t">', JK(171, tokenId), '</text><text x="416" y="305" class="JK t">', JK(189, tokenId), '</text><text x="416" y="378" class="JK t">', JK(192, tokenId)));
        string memory jksvg8 = string(abi.encodePacked('</text><text x="416" y="452" class="JK t">', JK(236, tokenId)));
        string memory jkEND = string(abi.encodePacked('</text><text x="86" y="90" class="JK tt">B I N G O</text><text x="330" y="105" class="JK s"> Bag #', toString(tokenId), '</text>'));

        string memory output = string(abi.encodePacked(jksvg1, jksvg2, jksvg3, jksvg4, jksvg5, jksvg6, jksvg7, jksvg8, jkEND));
        output = string(abi.encodePacked(output, '</svg>'));

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Bingo game card Bag #', toString(tokenId), '", "description": "Bingo game card is a randomized and fully stored on-chain project. is also a unique combination with random color. Please keep following all JK decentralized projects : https://jkonchain.com . This bingo card number is : ', BINGO(tokenId), ' ", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));

        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }


    // Public Functions
    function claim(uint256 tokenId) public nonReentrant {
        require(tokenId >= 999 && tokenId < (block.number / 10) + 1, "ID invalid");
        _safeMint(_msgSender(), tokenId);
    }
}

// Library: Base64
library Base64 {
    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        string memory table = TABLE;
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)
            let tablePtr := add(table, 1)
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }
}
