// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 識別装置のコントラクト
contract IdentifierUnits is HashGenerator {
    function identify(address _sender, address _receiver, uint _transactionNo) public returns (string memory) {
        /// @dev マッピングから検証用情報を検索し、ハッシュ値を生成、検証する関数

        /// @dev identify関数を使用できるのは受取人のアドレスからのみ
        require(_receiver == msg.sender); 

        /// @dev 取引が検証済みでないかどうかを確認する
        require(identInfoToTransactionInfo[_transactionNo].validated == false); 

        uint _labelId = senderToReceiverToLabelId[_sender][_receiver]; /// @dev 配送業者が読み取ったラベルIDを引き出す

        if(identInfoToInfoForVerification[_transactionNo] == generate(_labelId, _sender, _receiver, _transactionNo)){
            /// @dev 取引情報とラベルIDから得られたハッシュ値と検証用情報が一致していれば検証済情報を付与する
            identInfoToTransactionInfo[_transactionNo].validated = true;

            return "Validation succeeded!!";
        } else {
            return "Validation failed.";
        }
    }
}