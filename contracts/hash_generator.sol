// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./system.sol";

/// @dev ハッシュ値を生成するコントラクト
contract HashGenerator is System {
    function generate(uint id, address sender, address receiver, uint _transactionNo) internal pure returns (bytes32) {
        /// @dev ラベルIDと荷物情報からハッシュ値を生成する関数
        return keccak256(abi.encodePacked(id, sender, receiver, _transactionNo));
    }
}