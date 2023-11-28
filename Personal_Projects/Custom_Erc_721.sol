// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyToken is ERC721, ERC721Enumerable, ERC721Pausable, Ownable, ERC721Burnable {
    uint256 private _nextTokenId;
    using Counters for Counters.Counter;

    uint256 maxSupply = 555;
    uint public maxPerWallet = 3;

    bool public publicMintOpen = false;
    bool public wlMintOpen = false;

    mapping(address => bool) public allowList;
    mapping(address => uint256) purchasesPerWallet;
    mapping(address => uint256) mintedTokens;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyToken", "MTK")
        Ownable(msg.sender)
    {}

modifier canMint() {
    require(mintedTokens[msg.sender] < maxPerWallet);
    _;
}

//stop mint
    function pause() public onlyOwner {
        _pause();
    }

//resume mint
    function unpause() public onlyOwner {
        _unpause();
    }

    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i< addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

//edit mint condition

function editMintCond(
    bool _publicMintOpen,
    bool _wlMintOpen
        )external onlyOwner { 
    publicMintOpen = _publicMintOpen;
    wlMintOpen = _wlMintOpen;}

//private mint
    function wlMint(uint256 amountToMint) public payable {
        uint256 cost = amountToMint * 0.05 ether;
        require(wlMintOpen, "WhiteList Mint Closed");
        require(allowList[msg.sender]);
        require(msg.value >= amountToMint * cost, "Insufficient ether balance");
        
        mint(amountToMint);
    }

//public mint
    function publicMint(uint256 amountToMint) public payable {
    uint256 cost = amountToMint * 0.1 ether; // Calculate the total cost based on the number of tokens to mint
    require(publicMintOpen, "Public mint closed");
    require(msg.value == cost, "Incorrect ether amount");

    mint(amountToMint); // Call the mint function to mint the specified amount of tokens
}

//mint func to save gas
    function mint(uint256 amount) internal canMint{
        require(purchasesPerWallet[msg.sender] + amount <= maxPerWallet, "Wallet limit reached");
        require(totalSupply() < maxSupply, "Supply Sold OUt");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        mintedTokens[msg.sender] += amount; // Update minted tokens for the sender
    }
 
//withdraw function

    function withdraw(address _addr) external onlyOwner {
         uint256 balance = address(this).balance;
         payable(_addr).transfer(balance);
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
