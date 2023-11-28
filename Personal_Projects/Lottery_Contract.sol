// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Lottery {
    address public manager;
    address[] public players;

    constructor() payable {
        manager = msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    function enter() public payable {
        uint256 cost = 0.01 ether;
        require(msg.value == cost, "Minimum entry is 0.01 ether");
       
        players.push(msg.sender);
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    function random() private view returns (uint256) {
    // Use the blockhash of the previous block as a source of randomness
    bytes32 rand = blockhash(block.number - 1);
    if (rand == 0) {
        // Fallback mechanism if blockhash is not available (e.g., within the same block)
        rand = keccak256(abi.encodePacked(block.timestamp, players));
    }
    return uint256(rand);
}


    function pickWinner() public onlyManager returns (address) {
        require(players.length > 0, "No players in the lottery");

        uint256 index = random() % players.length;
        address winner = players[index];
        address contractAddress = address(this);

        // Transfer the contract balance to the winner
        payable(winner).transfer(contractAddress.balance);

        // Reset the players array for the next lottery
        players = new address[](0);

        return winner;
    }
}
