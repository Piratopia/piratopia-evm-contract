// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title DailyQuest
 * @custom:dev-run-script ./scripts/island-deploy.ts
 */
contract Island {
    address admin;
    address payable private fundingAccount;
    mapping(uint256 => uint256) private feeConfigs;
    mapping(address => uint256) private userLevels;
    uint256 maxLevel;

    modifier onlyAdmin() {
        require(msg.sender == admin, "permission_deny");
        _;
    }

    modifier onlyFundingAccount() {
        require(msg.sender == fundingAccount, "permission_deny");
        _;
    }

    event IslandUpgrade(address indexed user, uint256 level);

    constructor(address payable _fundingAccount, uint256 _maxLevel) {
        admin = msg.sender;
        fundingAccount = _fundingAccount;
        maxLevel = _maxLevel;
    }

    function getFundingAccount() external view onlyAdmin returns (address) {
        return fundingAccount;
    }

    function updateAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "invalid_address");
        require(_newAdmin != admin, "already_admin");

        admin = _newAdmin;
    }

    function updateFundingAccount(address payable _newFundingAccount) external onlyFundingAccount {
        require(_newFundingAccount != address(0), "invalid_address");
        require(_newFundingAccount != admin, "already_funding_account");

        fundingAccount = _newFundingAccount;
    }

    function getLevelFee(uint256 _level) public view returns (uint256) {
        return feeConfigs[_level];
    }

    function getIslandLevel() public view returns (uint256) {
        return userLevels[msg.sender];
    }

    function setMaxLevel(uint256 _maxLevel) external onlyAdmin {
        maxLevel = _maxLevel;
    }

    function setLevelFee(uint256 _level, uint256 _fee) external onlyAdmin {
        require(_level <= maxLevel, 'over_maximum_level');

        feeConfigs[_level] = _fee;
    }

    function upgrade() external payable {
        uint256 currentLevel = userLevels[msg.sender];
        uint256 nextLevel = currentLevel + 1;

        require(nextLevel <= maxLevel, "exceed_maximum_level");

        uint256 requiredFee = feeConfigs[nextLevel];

        require(requiredFee > 0, "invalid_fee_level");
        require(msg.value >= requiredFee, "insufficient_fund");

        userLevels[msg.sender] = nextLevel;

        emit IslandUpgrade(msg.sender, nextLevel);
    }

    function withdraw() external onlyFundingAccount {
        uint256 balance = address(this).balance;

        require(balance > 0, "no_fund_to_transfer");

        fundingAccount.transfer(address(this).balance);
    }
}