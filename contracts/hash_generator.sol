// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./system.sol";

/// @dev ハッシュ値を生成するコントラクト
contract HashGenerator is System {
    function generate(uint _labelId, address _sender, address _receiver, uint _transactionNo) internal pure returns (bytes32) {
        /// @dev ラベルIDと取引情報からハッシュ値を生成する関数
        return keccak256(abi.encodePacked(_labelId, _sender, _receiver, _transactionNo));
    }
}