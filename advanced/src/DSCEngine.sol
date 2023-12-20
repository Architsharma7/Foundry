// SPDX-LICENSE-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {DSC} from "./DSC.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/interfaces/AggregatorV3Interface.sol";

contract DSCEngine is ReentrancyGuard {
    error DSCEngine_Must_Be_Greater_Than_Zero();
    error DSCEngine_Token_Address_Not_Allowed();
    error DSCEngine_Collateral_Deposit_Not_Successful();
    error DSCEngine_Health_Factor_Below_One(uint256 healthFactor);
    error DSCEngine_Mint_Failed();

    mapping(address => bool) public s_AllowedTokens;
    mapping(address token => address priceFeed) public s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount))
        public s_collateralDeposited;
    mapping(address user => uint256 amountDSCMinted) private s_DSCMinted;

    DSC private immutable i_DSC;
    address[] private s_collateralTokens;
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant LIQUIDATION_THRESHHOLD = 50; // 200% overcollateralized

    modifier moreThanZero(uint256 _amount) {
        if (_amount <= 0) {
            revert DSCEngine_Must_Be_Greater_Than_Zero();
        }
        _;
    }

    event CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    modifier isAllowedTokens(address _tokenAddress) {
        if (!s_AllowedTokens[_tokenAddress]) {
            revert DSCEngine_Token_Address_Not_Allowed();
        }
        _;
    }

    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddresses,
        address DSCAddress
    ) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine_Token_Address_Not_Allowed();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_DSC = DSC(DSCAddress);
    }

    function revertIfHealthFactorisBroken(address _user) internal view {
        uint256 userHealthFactor = healthFactor(_user);
        if (userHealthFactor < 1) {
            revert DSCEngine_Health_Factor_Below_One(userHealthFactor);
        }
    }

    function getTotalCollateralAndDSC(
        address _user
    ) private view returns (uint256 totalCollateral, uint256 totalDSC) {
        totalDSC = s_DSCMinted[_user];
        totalCollateral = getAccountCollateralValue(_user);
        return (totalCollateral, totalDSC);
    }

    function healthFactor(address _user) private view returns (uint256) {
        (uint256 totalCollateral, uint256 totalDSC) = getTotalCollateralAndDSC(
            _user
        );
        uint256 collateralAdjustedForThreshhold = (totalCollateral *
            LIQUIDATION_THRESHHOLD) / 100;
        return (collateralAdjustedForThreshhold * 100) / totalDSC;
    }

    function getAccountCollateralValue(
        address _user
    ) public view returns (uint256 totalCollateralValueInUSD) {
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[_user][token];
            totalCollateralValueInUSD += getUsdValue(token, amount);
        }
        return totalCollateralValueInUSD;
    }

    function getUsdValue(
        address _token,
        uint256 _amount
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_priceFeeds[_token]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * _amount) / 1e18;
    }

    function depositCollateralAndMintDSC() external {}

    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    ) external moreThanZero(amountCollateral) nonReentrant {
        s_collateralDeposited[msg.sender][
            tokenCollateralAddress
        ] += amountCollateral;
        emit CollateralDeposited(
            msg.sender,
            tokenCollateralAddress,
            amountCollateral
        );
        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );
        if (!success) {
            revert DSCEngine_Collateral_Deposit_Not_Successful();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function burnDSC() external {}

    function mintDSC(
        uint256 amountDSCToMint
    ) external moreThanZero(amountDSCToMint) {
        s_DSCMinted[msg.sender] += amountDSCToMint;
        revertIfHealthFactorisBroken(msg.sender);
        bool minted = i_DSC.mint(msg.sender, amountDSCToMint);
        if(!minted) {
            revert DSCEngine_Mint_Failed();
        }
    }

    function liquidate() external {}

    function getHealthFactor(address _user) internal view {}
}
