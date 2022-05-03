// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.0;

import "../tokens/StandardToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract ExampleFactory is Ownable {
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
    uint8 decimals, 
    uint256 totalSupply
  ) external payable enoughFee returns (address) {
    refundExcessiveFee();
    StandardToken newToken = new StandardToken(
      name, symbol, decimals, totalSupply, msg.sender
    );
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}