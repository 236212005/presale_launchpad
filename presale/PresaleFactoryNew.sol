// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.0;

import "./PresaleNew.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract PresaleFactoryNew {
  using Address for address payable;
  using SafeMath for uint256;

  address public feeTo;
  address _owner;
  uint256 public flatFee;

  modifier enoughFee() {
    require(msg.value >= flatFee, "Flat fee");
    _;
  }

  modifier onlyOwner {
    require(msg.sender == _owner, "You are not owner");
    _;
  }

  constructor() {
    feeTo = msg.sender;
    flatFee = 10_000_000 gwei;
    _owner = msg.sender;
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
    address _sale_token,
    uint256 _token_rate,
    uint256 _raise_min, 
    uint256 _raise_max, 
    uint256 _softcap, 
    uint256 _hardcap,
    bool _whitelist,
    uint256 _presale_start,
    uint256 _presale_end
  ) external payable enoughFee returns (address) {
    refundExcessiveFee();
    PresaleNew newToken = new PresaleNew(
      msg.sender, _sale_token, _token_rate, _raise_min, _raise_max,
      _softcap, _hardcap, _whitelist, 
      _presale_start, _presale_end
    );
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}