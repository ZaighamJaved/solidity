// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract SahalReferrals {

    function getEthBalances(address[] memory addresses) public view returns(uint256[] memory) {
       uint256[] memory ethBalances = new uint256[](addresses.length);
        for(uint256 index=0; index < addresses.length; index+=1){
            ethBalances[index] = addresses[index].balance;
        }
        return ethBalances;
    }

    function getErc20Balances(address[] memory addresses, address[] memory tokens) public view returns(uint256[] memory) {
       uint256[] memory erc20Balances = new uint256[](addresses.length * tokens.length);
        for(uint256 i=0; i < addresses.length; i+=1){
            for(uint256 j=0; j<tokens.length; j++){
                uint256 index = j + tokens.length * i;
                erc20Balances[index] = IERC20(tokens[j]).balanceOf(address(addresses[i]));
            }
        }
        return erc20Balances;
    }

    function rewardDistribution(address[] memory referred, uint256 referredReward, address[] memory referree, uint256 referreeReward, address erc20Token) public payable returns(bool){
        require(referred.length !=0,"referred addresses required");
        require(referree.length !=0,"referree addresses required");
        require(referred.length==referree.length,"referree and referred address should have same length");
        
        for(uint256 i=0; i<referred.length; i++){
            IERC20(erc20Token).transferFrom(msg.sender, referred[i],referredReward);
            IERC20(erc20Token).transferFrom(msg.sender, referree[i],referreeReward);
        }
        return true;
    }
}
