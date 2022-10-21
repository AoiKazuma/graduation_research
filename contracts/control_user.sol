// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

/// @dev 関数の制御に使用するmodifierを記述するコントラクト
contract ControlUser {
    modifier onlySender(address _sender) {
        /// @dev 発送者とmsg.senderが一致するかの確認
        require(msg.sender == _sender);
        _;
    }
}