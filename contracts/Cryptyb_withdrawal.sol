// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptypWithdrawal is Ownable {
    function sendEthTokens(address[] memory addresses, uint256[] memory amount)
        public
        payable
        returns (bool)
    {
        require(msg.value > 0, "amount should be greater than 0");
        require(addresses.length != 0, "addresses required");
        require(amount.length != 0, "amount required");
        require(
            addresses.length == amount.length,
            "amount and addresses should have same length"
        );

        for (uint256 i = 0; i < addresses.length; i++) {
            payable(addresses[i]).transfer(amount[i]);
        }
        return true;
    }

    function sendErc20Token(
        address[] memory addresses,
        uint256[] memory amount,
        address erc20Token
    ) public payable returns (bool) {
        require(erc20Token != address(0), "token address required");
        require(addresses.length != 0, "addresses required");
        require(amount.length != 0, "amount required");
        require(
            addresses.length == amount.length,
            "amount and addresses should have same length"
        );

        for (uint256 i = 0; i < addresses.length; i++) {
            IERC20(erc20Token).transferFrom(
                msg.sender,
                addresses[i],
                amount[i]
            );
        }
        return true;
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
