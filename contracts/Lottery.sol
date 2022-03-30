// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.5;

contract Lottery {
    address public manager;
    address payable[] public participants;

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Unauthorised To Perform This Operation"
        );
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function register() public payable {
        require(
            msg.value == 0.1 ether,
            "Participation amount should be 0.1 ethers"
        );
        participants.push(payable(msg.sender));
    }

    function pickWinner() public payable onlyManager {
        require(participants.length > 0, "No Participants Registered");
        uint256 index = randomNumGenerator() % participants.length;
        participants[index].transfer(address(this).balance);
        participants = new address payable[](0);
    }

    function getAllPlayers() public view returns (address payable[] memory) {
        return participants;
    }

    function randomNumGenerator() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        participants
                    )
                )
            );
    }
}
