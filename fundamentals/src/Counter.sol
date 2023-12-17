// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    // use revert Counter_Error() in an if statement to revert, instead of using require to save gas
    // start the errrr name with contract name followed by error name 
    error Counter_Error();

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
