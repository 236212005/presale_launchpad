// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.0;

import "../../tokens/LiquidityGeneratorToken.sol";

contract LiquidityGeneratorTokenFactory is Ownable {
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
    string memory name,
    string memory symbol,
    uint256 totalSupply,
    address router,
    address charity,
    uint16 taxFeeBps, 
    uint16 liquidityFeeBps,
    uint16 charityBps
  ) external payable enoughFee returns (address) {
    refundExcessiveFee();
    LiquidityGeneratorToken newToken = new LiquidityGeneratorToken(
      name,
      symbol,
      totalSupply,
      router,
      charity,
      taxFeeBps,
      liquidityFeeBps,
      charityBps,
      msg.sender
    );
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}