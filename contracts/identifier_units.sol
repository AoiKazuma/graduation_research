// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 受取人の処理のコントラクト
contract IdentifierUnits is HashGenerator {
    function identify(uint Id, address _sender, address _receiver, uint _transactionNo) public returns (string memory) {
        /// @dev マッピングから検証用情報を検索し、ハッシュ値を生成、検証する関数

        /// @dev identify関数を使用できるのは受取人のアドレスからのみ
        require(_receiver == msg.sender); 

        /// @dev 取引が検証済みでないかどうかを確認する
        require(identInfoToTransactionInfo[_transactionNo].validated == false); 

        if(identInfoToTransactionInfo[_transactionNo].verificationInfo == generate(Id, _sender, _receiver, _transactionNo)){
            /// @dev 取引情報と特徴量から得られたハッシュ値と検証用情報が一致していれば検証済情報を付与する
            identInfoToTransactionInfo[_transactionNo].validated = true;

            return "Validation succeeded!!";
        } else {
            return "Validation failed.";
        }
    }
}