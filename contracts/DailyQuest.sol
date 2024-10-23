// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title DailyQuest
 * @custom:dev-run-script ./scripts/daily-quest-deploy.ts
 */
contract DailyQuest {
    address admin;
    address payable public fundingAccount;
    uint256 public checkinFee;

    mapping(address => uint256) private lastCheckin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "permission_deny");
        _;
    }

    modifier onlyFundingAccount() {
        require(msg.sender == fundingAccount, "permission_deny");
        _;
    }

    event CheckinSuccess(address indexed user, uint256 timestamp);

    constructor(address payable _fundingAccount, uint256 _initialFee) {
        admin = msg.sender;
        fundingAccount = _fundingAccount;
        checkinFee = _initialFee;
    }

    function updateAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "invalid_address");
        require(_newAdmin != admin, "already_admin");

        admin = _newAdmin;
    }

    function updateFundingAccount(address payable _newFundingAccount) external onlyAdmin {
        require(_newFundingAccount != address(0), "invalid_address");
        require(_newFundingAccount != admin, "already_funding_account");

        fundingAccount = _newFundingAccount;
    }

    function getLastCheckin() public view returns (uint256) {
        return lastCheckin[msg.sender];
    }

    function setFee(uint256 _newFee) external onlyAdmin {
        checkinFee = _newFee;
    }

    function checkin() external payable {
        require(msg.value >= checkinFee, "insufficient_fund");

        uint256 lastCheckinTime = lastCheckin[msg.sender];

        require(block.timestamp >= lastCheckinTime + 1 days, "already_checkin");

        lastCheckin[msg.sender] = block.timestamp;

        emit CheckinSuccess(msg.sender, block.timestamp);
    }

    function withdraw() external onlyFundingAccount payable {
        uint256 balance = address(this).balance;

        require(balance > 0, "no_fund_to_transfer");

        (bool sent, ) = fundingAccount.call{value: balance}("");

        require(sent, "withdraw_failed");
    }
}