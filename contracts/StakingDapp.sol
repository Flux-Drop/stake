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

    function deposit(uint _pid, uint _amount) public nonReentrant {
        //condition
        require(amount > 0, "Amount must be greater than 0");

        //getting pool and user info
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        //checking if user has already deposited some tokens
        if (user.amount > 0) {
            uint pending = _calcPendingReward(user, _pid);
            pool.rewardToken.transfer(msg.sender, pending);

            _createNotification(_pid, pending, msg.sender, "Claim");
        }

        //transfer tokens from user to contract
        pool.depositToken.transferFrom(msg.sender, address(this), _amount);

        pool.depositedAmount += _amount;

        user.amount += _amount;
        user.lastRewardAt = block.timestamp;

        user.lockUntil = block.timestamp + (pool.lockDays * 60);
        // user.lockUntil = block.timestamp + (pool.lockDays * 86400);

        depositedTokens[address(pool.depositToken)] += _amount;

        _createNotification(_pid, _amount, msg.sender, "Deposit");
    }

    function withdraw(uint _pid, uint _amount) public nonReenrant {
        //getting pool and user info
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        //checking conditions for withdrawal
        require(
            user.amount >= _amount,
            "Withdraw amount exceeds deposited amount"
        );
        require(user.lockUntil <= block.timestamp, "Tokens are locked");

        //calculating pending rewards
        uint256 pending = _calcPendingReward(user, _pid);
        if (user.amount > 0) {
            pool.rewardToken.transfer(msg.sender, pending);
            _createNotification(_pid, pending, msg.sender, "Claim");
        }

        if (_amount > 0) {
            user.amount -= _amount;
            pool.depositedAmount -= _amount;
            depositedTokens[address(pool.depositToken)] -= _amount;

            pool.depositToken.transfer(msg.sender, _amount);
        }

        user.lastRewardAt = block.timestamp;
        _createNotification(_pid, _amount, msg.sender, "Withdraw");
    }

    function _calcPendingReward(
        UserInfo storage user,
        uint _pid
    ) internal view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];

        uint dayPassed = (block.timestamp - user.lastRewardAt) / 60;
        // uint dayPassed = (block.timestamp - user.lastRewardAt) / 86400;

        if (dayPassed > pool.lockDays) {
            dayPassed = pool.lockDays;
        }

        return ((user.amount * dayPassed) / 365 / 100) * pool.apy;
    }

    function pendingReward(
        uint _pid,
        address _user
    ) public view returns (uint) {
        UserInfo storage user = userInfo[_pid][_user];
        return _calcPendingReward(user, _pid);
    }

    function swap(address token, uint256 amount) external onlyOwner {
        //check if the contract has enough balance
        uint256 token_balance = IERC20(token).balanceOf(address(this));
        require(amount <= token_balance, "Insufficient balance");

        require(
            token_balance - amount >= depositedTokens[token],
            "Cannot withdraw deposited tokens"
        );

        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function modifyPool(uint _pid, uint _apy) public onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.apy = _apy;
    }

    function claimReward(uint _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.lockUntil <= block.timestamp, "Tokens are locked");

        uint256 pending = _calcPendingReward(user, _pid);
        require(pending > 0, "No rewards to claim");

        user.lastRewardAt = block.timestamp;

        pool.rewardToken.transfer(msg.sender, pending);

        _createNotification(_pid, pending, msg.sender, "Withdraw");
    }

    function _createNotification() {}

    function getNotifications() {}
}
