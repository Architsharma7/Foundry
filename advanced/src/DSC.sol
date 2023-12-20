// SPDX-LICENSE-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DSC is ERC20Burnable, Ownable {
    error DSC_Must_Be_Greater_Than_Zero();
    error DCS_Balance_Must_Be_Greater_Than_Amount();
    error DSC_Mint_Address_Cannot_Be_Zero();

    constructor(address initialOwner) Ownable(initialOwner) ERC20("Decentralised Stable Coin", "DSC") {}

    function burn(uint256 amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (amount <= 0) {
            revert DSC_Must_Be_Greater_Than_Zero();
        }
        if (balance < amount) {
            revert DCS_Balance_Must_Be_Greater_Than_Amount();
        }
        // super stand for the parent contract, i.e burn function from ERC20Burnable
        super.burn(amount);
    }

    function mint(
        address to,
        uint256 amount
    ) external onlyOwner returns (bool) {
        if (to == address(0)) {
            revert DSC_Mint_Address_Cannot_Be_Zero();
        }
        if(amount <= 0) {
            revert DSC_Must_Be_Greater_Than_Zero();
        }
        _mint(to, amount);
        return true;
    }
}
