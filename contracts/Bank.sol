// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bank is Ownable {
    address token; // erc20 token address
    uint256 timeConstant; // time period constant in seconds set by the contract owner
    uint256 contractDeployedTime; // contract deployment time
    uint256[3] public rewardPools; // reward pools for reward distribution
    mapping(address => uint256) internal stakes; // erc20 tokens stakes by users
    address[] internal stakeholders; // participents

    constructor(address _token, uint256 _timeConstant) {
        token = _token;
        timeConstant = _timeConstant;
        contractDeployedTime = block.timestamp;
    }

    /*
        @description: add tokens in reward pool for distribution
        @params: _totalRewardAmount total reward amount for distribution 
    */
    function addTokensInRewardPool(uint256 _totalRewardAmount)
        public
        payable
        onlyOwner
    {
        bool isTransfered = IERC20(token).transferFrom(
            msg.sender,
            address(this),
            _totalRewardAmount
        );
        if (isTransfered) {
            rewardPools[0] = (_totalRewardAmount * 20) / 100;
            rewardPools[1] = (_totalRewardAmount * 30) / 100;
            rewardPools[2] = (_totalRewardAmount * 50) / 100;
        }
    }

    /*
        @description: modifier to check eligibility of deposit
    */
    modifier isDepositAllowed() {
        // deposit only between the time perio of t0 to t0+T
        require(
            (contractDeployedTime + timeConstant) >= block.timestamp,
            "Deposit not allowed now"
        );
        _;
    }

    /*
        @description: modifier to check eligibility of withdraw
    */
    modifier isWithdrawAllowed() {
        // withdraw allowed only after t0+2T time
        require(
            block.timestamp >= (contractDeployedTime + (2 * timeConstant)),
            "Withdrawal not allowed yet"
        );
        _;
    }

    /*
        @description: modifier to check eligibility of admin to withdraw
    */
    modifier isOwnerWithdrawAllowed() {
        require(
            block.timestamp >= (contractDeployedTime + (4 * timeConstant)),
            "Withdrawal not allowed for admin yet"
        ); // if time > t0+4T
        require(
            stakeholders.length == 0,
            "Withdrawal not allowed for admin yet"
        ); // if all stake holders claimed their rewards
        uint256 remainingReward = rewardPools[0] +
            rewardPools[1] +
            rewardPools[2];
        require(remainingReward > 0, "no tokens left in reward pool"); // if reward pools have balance
        _;
    }

    /*
        @description: deposit function for user to contribute in Bank for rewards
        @params: _amount deposit amount by user
    */
    function deposit(uint256 _amount) public payable isDepositAllowed {
        bool isSuccess = IERC20(token).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        if (isSuccess) {
            if (stakes[msg.sender] == 0) {
                stakeholders.push(msg.sender);
            }
            stakes[msg.sender] += _amount;
        }
    }

    /*
        @description:  function for user to claim their rewards and staken amount
    */
    function stakeOff() public payable isWithdrawAllowed {
        uint256 _eligibleRewardPools = eligibleRewardPools(); // get eligibal reward pools for user
        uint256 totalRewardForUser = stakes[msg.sender]; // total rewards for user = user staked amount + reward from pools
        uint256 userTotalStakes = stakes[msg.sender]; // total staked amount by user
        uint256 totalStakes = calculateTotalStakes(); // total staked amount by all participents
        stakes[msg.sender] = 0; // set user stakes to 0 before reward claiming to user
        removeStakeholder(msg.sender); //remove user from participents

        // calculate rewards from all eligible pools
        for (uint256 p = 0; p < _eligibleRewardPools; p += 1) {
            uint256 userRewardPool = calculatePoolRewardForuser(
                totalStakes,
                userTotalStakes,
                rewardPools[p]
            );
            totalRewardForUser += userRewardPool;
            rewardPools[p] -= userRewardPool;
        }

        IERC20(token).transfer(msg.sender, totalRewardForUser);
    }

    /*
        @description:  find eligible reward pools at the time user claimed for reward
    */
    function eligibleRewardPools() private view returns (uint256) {
        // if time > t0+4T
        if (block.timestamp >= (contractDeployedTime + (4 * timeConstant))) {
            return 3;
        }
        // if time > t0+3T
        if (block.timestamp >= (contractDeployedTime + (3 * timeConstant))) {
            return 2;
        }
        // if time > t0+2T
        if (block.timestamp >= (contractDeployedTime + (2 * timeConstant))) {
            return 1;
        }
        return 0;
    }

    /*
        @description:  find participent and its position in the participent
    */
    function isStakeholder(address _address)
        private
        view
        returns (bool, uint256)
    {
        for (uint256 s; s < stakeholders.length; s += 1) {
            if (stakeholders[s] == _address) {
                return (true, s);
            }
        }
        return (false, 0);
    }

    /*
        @description:  remove user from participents
    */
    function removeStakeholder(address _address) private {
        (bool _isStakeholder, uint256 index) = isStakeholder(_address);
        if (_isStakeholder) {
            stakeholders[index] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    /*
        @description:  calculate total staked amount
    */
    function calculateTotalStakes() private view returns (uint256) {
        uint256 _totalStakes = 0;
        for (uint256 index = 0; index < stakeholders.length; index += 1) {
            _totalStakes += stakes[stakeholders[index]];
        }
        return _totalStakes;
    }

    /*
        @description:  calculate rewards fro user from a particular pool
    */
    function calculatePoolRewardForuser(
        uint256 _totalStakes,
        uint256 _userStakes,
        uint256 _poolReward
    ) private pure returns (uint256) {
        uint256 userRewardPercentage = (_userStakes * 100) / _totalStakes;
        uint256 userReward = (_poolReward * userRewardPercentage) / 100;
        return userReward;
    }

    /*
        @description:  function to withdraw tokens from pools for admin if all users claimed their rewards before t0+T4
    */
    function ownerWithdrawal() public onlyOwner isOwnerWithdrawAllowed {
        uint256 totalAmount = 0;
        for (uint256 index = 0; index < rewardPools.length; index += 1) {
            totalAmount += rewardPools[index];
            rewardPools[index] = 0;
        }
        IERC20(token).transfer(msg.sender, totalAmount);
    }
}
