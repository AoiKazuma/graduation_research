// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 検証装置のコントラクト
contract ValidatorUnits is HashGenerator {
    function labelValidate(uint _labelId, address _sender, address _receiver) public {
        /// @dev 検証フェーズで配送業者がラベルIDを読み取り、senderToReceiverToLabelIdに格納する関数
        senderToReceiverToLabelId[_sender][_receiver] = _labelId;
    }
}