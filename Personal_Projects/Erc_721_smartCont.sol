// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract INSENTIENTS is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 wlSupply = 222;
    uint256 maxSupply = 555;
    bool publicMintOpen = false;
    bool wlMintOpen = false;

    constructor(address initialOwner)
        ERC721("Insentients", "INST")
        Ownable(initialOwner)
    {}

    mapping (address => bool) public whiteList;

    function _baseURI() internal pure override returns (string memory) {
        return "input ipfs url here";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintStatus(
        bool _wlMintOpen,
        bool _publicMintOpen ) external onlyOwner {
            wlMintOpen = _wlMintOpen;
            publicMintOpen = _publicMintOpen;
        }

    function setWl(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whiteList[addresses[i]] = true;
        }
    }   
    
    function whiteListMint() public payable {
        require(whiteList[msg.sender], "You Are Not WhiteListed");
        require(wlMintOpen, "WhiteList Mint Closed");
        require(msg.value == 0.01 ether, "Insufficient Funds");
        require(totalSupply() < wlSupply, "WhiteList Mint SoldOut");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function publicMint() public payable {
        require(publicMintOpen, "Mint Closed");
        require(msg.value == 0.02 ether, "Insufficient Funds");
        require(totalSupply() < maxSupply, "Supply Finished");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance;
        payable (_addr).transfer(balance);
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
