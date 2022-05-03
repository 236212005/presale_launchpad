// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.0;

import "../../tokens/BabyToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract BabyTokenFactory is Ownable {
  using Address for address payable;
  using SafeMath for uint256;

  address public feeTo;
  uint256 public flatFee;

  modifier enoughFee() {
    require(msg.value >= flatFee, "Flat fee");
    _;
  }

  constructor() {
    feeTo = msg.sender;
    flatFee = 10_000_000 gwei;
  }

  function setFeeTo(address feeReceivingAddress) external onlyOwner {
    feeTo = feeReceivingAddress;
  }

  function setFlatFee(uint256 fee) external onlyOwner {
    flatFee = fee;
  }

  function refundExcessiveFee() internal {
    uint256 refund = msg.value.sub(flatFee);
    if (refund > 0) {
      payable(msg.sender).sendValue(refund);
    }
  }

  function create(
    string memory name_,
    string memory symbol_,
    uint256 totalSupply_,
    address[4] memory addrs, // reward, router, marketing wallet, dividendTracker
    uint256[3] memory feeSettings, // rewards, liquidity, marketing
    uint256 minimumTokenBalanceForDividends_
  ) external payable enoughFee returns (address) {
    refundExcessiveFee();
    BABYTOKEN newToken = new BABYTOKEN(
      name_, symbol_, totalSupply_, 
      addrs, feeSettings,
      minimumTokenBalanceForDividends_, msg.sender
    );
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}