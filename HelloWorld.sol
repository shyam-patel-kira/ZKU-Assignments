// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.10 and less than 0.9.0
pragma solidity ^0.8.10;

/// @title HelloWorld contract
/// @author Shyam Patel
contract HelloWorld {
    /// @notice the value
    uint public value;

    /// @notice setValue overrides the value provided by the user
    /// @dev set to external as not consumed internally
    /// @param x The value to override
    function set(uint x) public {
        value = x;
    }
    /// @notice getValue returns the current value
    /// @dev set to external as not consumed internally, set to view as doesn't updates any state
    /// @return value The current value in state
    function get() public view returns (uint) {
        return value;
    }
}

