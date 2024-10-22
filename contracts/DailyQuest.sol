// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title DailyQuest
 * @custom:dev-run-script ./scripts/deploy_daily_quest.ts
 */
contract DailyQuest {

    address admin;
    address payable fundingAccount;
    uint256 checkinFee;

    mapping(address => uint256) lastCheckin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "permission_deny");
        _;
    }

    modifier onlyFundingAccount() {
        require(msg.sender == fundingAccount, "permission_deny");
        _;
    }

    event CheckinSuccess(address indexed user, uint256 timestamp);

    constructor(uint256 _initialFee, address payable _fundingAccount) {
        admin = msg.sender;
        fundingAccount = _fundingAccount;
        checkinFee = _initialFee;
    }

    function updateFee(uint256 _newFee) external onlyAdmin {
        checkinFee = _newFee;
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

    function checkin() external payable {
        require(msg.value >= checkinFee, "insufficient_fund");

        uint256 lastCheckinTime = lastCheckin[msg.sender];

        require(block.timestamp >= lastCheckinTime + 1 days, "already_checkin");

        lastCheckin[msg.sender] = block.timestamp;

        emit CheckinSuccess(msg.sender, block.timestamp);
    }

    function withdraw() external onlyFundingAccount {
        uint256 balance = address(this).balance;

        require(balance > 0, "no_fund_to_transfer");

        fundingAccount.transfer(address(this).balance);
    }
}