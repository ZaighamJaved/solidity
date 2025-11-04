// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// ERC20 contract interface
interface Token {
    function balanceOf(address account) external view returns (uint);
}

contract BalanceFetcher {
    /* Fallback function, don't accept any ETH */
    fallback() external payable {
        revert("BalanceFetcher does not accept payments");
    }

    receive() external payable {
        revert("BalanceFetcher does not accept payments");
    }

    /*
        Check the token balance of a wallet in a token contract

        Returns the balance of the token for user. Avoids possible errors:
        - return 0 on non-contract address 
        - returns 0 if the contract doesn't implement balanceOf
    */
    function tokenBalance(address user, address token) public view returns (uint) {
        // Check if token is actually a contract
        uint256 tokenCode;
        assembly { tokenCode := extcodesize(token) } // contract code size
        
        // Check if it is a contract and if it implements balanceOf
        if (tokenCode > 0) {
            (bool success, bytes memory data) = token.staticcall(
                abi.encodeWithSelector(Token.balanceOf.selector, user)
            );
            if (success) {
                return abi.decode(data, (uint));
            }
        }
        return 0;
    }

    /*
        Check the token balances of a wallet for multiple tokens.
        Pass address(0) as a "token" address to get ETH balance.

        Possible error throws:
        - extremely large arrays for users and/or tokens (gas cost too high)
        
        Returns a one-dimensional array that's users.length * tokens.length long. The
        array is ordered by all of the 0th users token balances, then the 1st
        user, and so on.
    */
    function balances(address[] calldata users, address[] calldata tokens) external view returns (uint[] memory) {
        uint[] memory addrBalances = new uint[](tokens.length * users.length);
        
        for (uint i = 0; i < users.length; i++) {
            for (uint j = 0; j < tokens.length; j++) {
                uint addrIdx = j + tokens.length * i;
                if (tokens[j] != address(0)) { 
                    addrBalances[addrIdx] = tokenBalance(users[i], tokens[j]);
                } else {
                    addrBalances[addrIdx] = users[i].balance; // ETH balance    
                }
            }
        }
    
        return addrBalances;
    }
}
