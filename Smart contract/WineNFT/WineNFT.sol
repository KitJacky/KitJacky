// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// @author 3jk.net

//       ## ##    ##    ##          ###    ########   ######
//       ## ##   ##     ##         ## ##   ##     ## ##    ##
//       ## ##  ##      ##        ##   ##  ##     ## ##
//       ## #####       ##       ##     ## ########   ######
// ##    ## ##  ##      ##       ######### ##     ##       ##
// ##    ## ##   ##     ##       ##     ## ##     ## ##    ##
//  ######  ##    ##    ######## ##     ## ########   ######

// Attaching libraries
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Declarations
contract WineNFT is ERC721, Pausable, ERC2981, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 constant MAX_TOKENS = 10000;
    uint256 constant MINT_PRICE = 0.028 ether;
    string baseTokenURI;

    mapping(address => bool) whiteList;

    // Constructor
    constructor(
        string memory _URI,
        address _defaultAdmin,
        address _receiver,
        uint96 _feeNumerator
    ) ERC721("WineNFT", "WINE") {
        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _setupRole(ADMIN_ROLE, _defaultAdmin);
        _setDefaultRoyalty(_receiver, _feeNumerator);
        setBaseURI(_URI);
    }

    // Modifiers
    modifier collectionEnded(uint256 _count) {
        uint256 total = totalMinted();
        require(total + _count <= MAX_TOKENS, "Max limit");
        _;
    }

    // Admin Functions
    function freeMintForAdmin(
        uint256 _count
    ) external onlyRole(ADMIN_ROLE) whenNotPaused collectionEnded(_count) {
        for (uint256 i = 0; i < _count; i++) {
            _mintAnElement(msg.sender);
        }
    }

    function addUserToWhiteList(address _user) external onlyRole(ADMIN_ROLE) {
        require(!whiteList[_user], "Already in WL");
        whiteList[_user] = true;
    }

    function saleOff() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function saleOn() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    function widthdraw(address _address) external onlyRole(ADMIN_ROLE) {
        uint256 amount = address(this).balance;
        (bool success, ) = _address.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    // Getter Functions
    function mintPrice() public pure returns (uint256) {
        return MINT_PRICE;
    }

    function totalCollectionAmount() public pure returns (uint256) {
        return MAX_TOKENS;
    }

    function checkWhiteList(address _user) external view returns (bool) {
        return whiteList[_user];
    }

    function adminRole() public pure returns (bytes32) {
        return ADMIN_ROLE;
    }

    function totalMinted() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function checkCollectionURI() external view returns (string memory) {
        return _baseURI();
    }

    // Setter Functions
    function setBaseURI(string memory baseURI) public {
        baseTokenURI = baseURI;
    }

    // Main Functions
    function mint(
        uint256 _count
    ) external payable whenNotPaused collectionEnded(_count) {
        require(
            msg.value >= (MINT_PRICE * _count),
            "Not enough Ether for mint"
        );
        for (uint256 i = 0; i < _count; i++) {
            _mintAnElement(msg.sender);
        }
    }

    function freeMintForUser(
        uint256 _count
    ) external whenNotPaused collectionEnded(_count) {
        require(whiteList[msg.sender], "You are not in WL");
        for (uint256 i = 0; i < _count; i++) {
            _mintAnElement(msg.sender);
        }
    }

    // Internal Functions
    function _mintAnElement(address _to) private {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(hasRole(ADMIN_ROLE, from), "Only admin can transfer NFTs");
        super._transfer(from, to, tokenId);
    }

    // Overrides
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC2981, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
