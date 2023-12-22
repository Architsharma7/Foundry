// SPDX-LICENSE-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/interfaces/AggregatorV3Interface.sol";

library OracleLib {

    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLatestRoundData(
        AggregatorV3Interface _priceFeed
    ) public view returns (uint80, int256, uint256, uint256, uint80) {
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = _priceFeed.latestRoundData();
        uint256 secondsSince = block.timestamp - updatedAt;
        if(secondsSince > TIMEOUT) {
            revert("OracleLib: stale price feed");
        }
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
