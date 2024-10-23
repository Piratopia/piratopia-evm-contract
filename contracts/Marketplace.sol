// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title DailyQuest
 * @custom:dev-run-script ./scripts/marketplace-deploy.ts
 */
contract Marketplace {
    struct ItemDetail {
        address payable owner;
        uint256 price;
    }

    address admin;
    address payable public fundingAccount;
    uint256 public feeRate;
    mapping (uint256 => ItemDetail) private marketplace;

    modifier onlyAdmin() {
        require(msg.sender == admin, "permission_deny");
        _;
    }

    modifier onlyFundingAccount() {
        require(msg.sender == fundingAccount, "permission_deny");
        _;
    }

    event ItemListing(uint256 itemId, address indexed owner, uint256 price);
    event ItemDelisting(uint256 itemId);
    event ItemPurchased(uint256 itemId, address indexed buyer, address indexed owner, uint256 price, uint256 fee);

    constructor(address payable _fundingAccount, uint256 _feeRate) {
        require(_feeRate <= 10000, 'exceed_maximum_fee_rate');

        admin = msg.sender;
        feeRate = _feeRate;
        fundingAccount = _fundingAccount;
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

    function getItem(uint256 _itemId) public view returns (uint256, address, uint256) {
        require(marketplace[_itemId].owner != address(0), "item_not_existed");

        ItemDetail storage item = marketplace[_itemId];

        return (_itemId, item.owner, item.price);
    }

    function setFeeRate(uint256 _feeRate) external onlyAdmin {
        require(_feeRate <= 10000, 'exceed_maximum_fee_rate');

        feeRate = _feeRate;
    }

    function listingItem(uint256 _itemId, address payable _owner, uint256 _price) external onlyAdmin {
        require(marketplace[_itemId].owner == address(0), "item_existed");

        marketplace[_itemId] = ItemDetail({
            owner: _owner,
            price: _price
        });

        emit ItemListing(_itemId, _owner, _price);
    }

    function delistingItem(uint256 _itemId) external onlyAdmin {
        require(marketplace[_itemId].owner != address(0), "item_not_existed");

        delete marketplace[_itemId];

        emit ItemDelisting(_itemId);
    }

    function buyItem(uint256 _itemId) external payable {
        ItemDetail storage item = marketplace[_itemId];

        require(marketplace[_itemId].owner != address(0), "item_not_existed");
        require(item.owner != msg.sender, 'same_owner');
        require(msg.value >= item.price, 'insufficient_fund');

        uint256 fee = (item.price * feeRate) / 10000;
        uint256 ownerAmount = item.price - fee;

        item.owner.transfer(ownerAmount);

        delete marketplace[_itemId];

        emit ItemPurchased(_itemId, msg.sender, item.owner, item.price, fee);
    }

    function withdraw() external onlyFundingAccount payable {
        uint256 balance = address(this).balance;

        require(balance > 0, "no_fund_to_transfer");

        (bool sent, ) = fundingAccount.call{value: balance}("");

        require(sent, "withdraw_failed");
    }
}