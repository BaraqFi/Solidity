// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wallet {
    struct User {
        string username;
        uint256 balance;
        bool isRegistered;
    }

    mapping(address => User) public users;
    address public owner;

    event Deposit(address indexed user, uint256 amount);
    event Send(address indexed from, address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
        users[msg.sender] = User({username: "owner", balance: 1000, isRegistered: true});//delete this line before real use
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function signUp(string memory _username) external {
        require(bytes(_username).length > 0, "Username should not be empty");
        require(!users[msg.sender].isRegistered, "User already registered");

        users[msg.sender] = User({
            username: _username,
            balance: 1000,
            isRegistered: true
        });
    }
    //the following deposit func wont work to display another user's address as it can only display the 
    //owners/callers address. use web3.js to fetch a users wallet when the smartconc has been implemented to a dApp
    //this was just to test. delete it in a real deployment
    function deposit() external view returns (address) {
        require(users[msg.sender].isRegistered, "User not registered");
        return owner;
        
    }

     function send(address to, uint256 amount) external {
        require(users[msg.sender].isRegistered, "User not registered");
        require(amount > 0, "Transfer amount must be greater than 0");
        require(users[msg.sender].balance >= amount, "Insufficient balance");

        users[msg.sender].balance -= amount;
        users[to].balance += amount;
        emit Send(msg.sender, to, amount);
    }

    function getBalance() external view returns (uint256) {
        return users[msg.sender].balance;
    }

}
