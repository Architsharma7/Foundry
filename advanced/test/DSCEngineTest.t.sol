//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "../script/DeployDSC.s.sol";
import {DSC} from "../src/DSC.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DSC dsc;
    DSCEngine dscEngine;
    HelperConfig config;
    address ethUSDPriceFeed;
    address weth;

    address public USER = makeAddr("USER");

    function setup() external {
        deployer = new DeployDSC();
        (dsc, dscEngine, config) = deployer.run();
        (ethUSDPriceFeed, , weth, , ) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, 10 ether);
    }

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        // 1 eth = 2000 usd
        // not the right way, as the price will be dynamic on sepolia
        uint256 expectedUSD = 30000e18;
        uint256 actualUSD = dscEngine.getUsdValue(weth, ethAmount);
        assertEq(expectedUSD, actualUSD);
    }

    function testRevertsIfCollateralIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dscEngine), 10 ether);

        vm.expectRevert(DSCEngine.DSCEngine_Must_Be_Greater_Than_Zero.selector);
        dscEngine.depositCollateral(weth, 0);
        vm.stopPrank();
    }
}
