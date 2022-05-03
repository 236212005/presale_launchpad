// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPresale {
    function initialize(
        address owner_, uint256 softCap_, uint256 hardCap_, uint256 max_, uint256 min_, uint256 startTime_, uint256 endTime_, uint256 tokenRate_, address tokenAddr_, bool whitelist_
    ) external;
}