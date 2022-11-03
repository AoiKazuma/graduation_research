// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 受取人の処理のコントラクト
contract IdentifierUnits is HashGenerator {
    modifier validateConfirm(uint _transactionNo) {
        /// @dev 取引が検証済みでないかどうかを確認する
        require(identInfoToTransactionInfo[_transactionNo].validated == false); 
        _;
    }

    function middleConfirm(uint id, address receiver, uint _transactionNo, uint _shipTimes, address shipper) public view onlyReceiver(receiver) validateConfirm(_transactionNo) returns (string memory, bytes32) {
        /// @dev 途中の検証用情報を確認する関数
        if(identInfoToTransactionInfo[_transactionNo].verificationInfo[_shipTimes] == keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0], shipper))){
            /// @dev 途中までの検証情報が一致するかを確認
            return ("Middle validation succeeded!!", keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0], shipper)));
        } else {
            return ("Middle validation failed.", keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0], shipper)));
        }
    }

    function identify(uint id, address sender, address receiver, uint _transactionNo) public onlyReceiver(receiver) validateConfirm(_transactionNo) returns (string memory) {
        /// @dev マッピングから検証用情報を検索し、検証する関数
        if(identInfoToTransactionInfo[_transactionNo].verificationInfo[0] == generate(id, sender, receiver, _transactionNo)){
            /// @dev 受取人が生成したハッシュ値と検証用情報が一致していれば検証済情報を付与する
            identInfoToTransactionInfo[_transactionNo].validated = true;

            return "Validation succeeded!!";
        } else {
            return "Validation failed.";
        }
    }
}