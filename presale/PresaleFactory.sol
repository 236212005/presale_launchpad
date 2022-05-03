// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.7.6;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IPresale.sol";
import "./TokenFactoryBase.sol";

contract PresaleFactory is TokenFactoryBase {
  using Address for address payable;
  using SafeMath for uint256;

  constructor(address implementation_) TokenFactoryBase(implementation_) {
  }

  function create(
    uint256 softCap_, 
    uint256 hardCap_, 
    uint256 max_, 
    uint256 min_, 
    uint256 startTime_, 
    uint256 endTime_, 
    uint256 tokenRate_, 
    address tokenAddr_,
    bool whitelist_
  ) external payable enoughFee nonReentrant returns (address token) {
    refundExcessiveFee();
    payable(feeTo).sendValue(flatFee);
    token = Clones.clone(implementation);
    IPresale(token).initialize(
      msg.sender, softCap_, hardCap_, max_, min_, startTime_, endTime_, tokenRate_, tokenAddr_, whitelist_
    );

    emit PresaleCreated(msg.sender, token, 0);
  }

}