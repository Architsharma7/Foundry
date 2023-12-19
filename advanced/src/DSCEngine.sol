// SPDX-LICENSE-Identifier: MIT
pragma solidity ^0.8.19;

contract DSCEngine {

    error DSCEngine_Must_Be_Greater_Than_Zero();
    error DSCEngine_Token_Address_Not_Allowed();

    mapping(address => bool) public s_AllowedTokens;
    mapping(address token => address priceFeed) public s_priceFeeds;

    modifier moreThanZero(uint256 _amount){
        if(_amount <= 0) {
            revert DSCEngine_Must_Be_Greater_Than_Zero();
        }
        _;
    }

     modifier isAllowedTokens(address _tokenAddress){
        if(!s_AllowedTokens[_tokenAddress]) {
            revert DSCEngine_Token_Address_Not_Allowed();
        }
        _;
    }

    constructor() {

    }

    function depositCollateralAndMintDSC() external {}

    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external moreThanZero(amountCollateral) {

    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function burnDSC() external {}

    function mintDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

}