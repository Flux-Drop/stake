// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingDapp is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint lastRewardAt;
        uint256 lockUntil;
    }

    struct PoolInfo {
        IERC20 depositToken;
        IERC20 rewardToken;
        uint256 depositedAmount;
        uint256 apy;
        uint lockDays;
    }

    struct Notification {
        uint256 poolId;
        uint256 amount;
        address user;
        string typeOf;
        uint256 timestamp;
    }

    uint decimals = 10 * 18;
    uint public poolCount;
    PoolInfo[] public poolInfo;

    mapping(address => uint256) public depositedTokens;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    Notification[] public notifications;

    //functions

    function addPool(
        IERC20 _depositedToken,
        IERC20 _rewardToken,
        uint256 _apy,
        uint _lockDays
    ) public onlyOwner {
        //push the pool details to the poolInfo array
        poolInfo.push(
            PoolInfo({
                depositToken: _depositedToken,
                rewardToken: _rewardToken,
                depositedAmount: 0,
                apy: _apy,
                lockDays: _lockDays
            })
        );

        //increment the pool count
        poolCount++;
    }

    function deposit() {}

    function withdraw() {}

    function _calcPendingReward() {}

    function pendingReward() {}

    function swap() {}

    function modifyPool() {}

    function claimReward() {}

    function _createNotification() {}

    function getNotifications() {}
}
