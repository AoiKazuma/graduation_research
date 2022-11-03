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

    function middleConfirm(uint id, address receiver, uint _transactionNo, uint _shipTimes) public view onlyReceiver(receiver) validateConfirm(_transactionNo) returns (string memory, bytes32) {
        /// @dev 途中の検証用情報を確認する関数
        if(identInfoToTransactionInfo[_transactionNo].verificationInfo[_shipTimes] == keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0]))){
            /// @dev 途中までの検証情報が一致するかを確認
            return ("Middle validation succeeded!!", keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0])));
        } else {
            return ("Middle validation failed.", keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0])));
        }
    }

    function identify(uint id, address sender, address receiver, uint _transactionNo) public onlyReceiver(receiver) validateConfirm(_transactionNo) returns (string memory, uint) {
        /// @dev マッピングから検証用情報を検索し、検証する関数
        uint point = 0; /// @dev どの配送ポイントで不正が行われたかを格納する変数

        for(uint i=0;i<=identInfoToTransactionInfo[_transactionNo].shipTimes;i++){
            /// @dev 配送者が検証した情報を１つずつ見ていく
            if(identInfoToTransactionInfo[_transactionNo].verificationInfo[i+1] != keccak256(abi.encodePacked(id, i+1, identInfoToTransactionInfo[_transactionNo].verificationInfo[0]))){
                /// @dev 検証用情報が一致しなかった場合
                point = i + 1; /// @dev どの配送者で検証情報が一致しなかったのかを格納
                break;
            }
        }

        if(identInfoToTransactionInfo[_transactionNo].verificationInfo[0] == generate(id, sender, receiver, _transactionNo) && point == 0){
            /// @dev 受取人が生成したハッシュ値と検証用情報が一致していれば検証済情報を付与する
            identInfoToTransactionInfo[_transactionNo].validated = true;

            return ("Validation succeeded!!", point);           
        } else {
            /// @dev 検証に失敗した場合、どこの配送地点で不正が行われていたのかを返す
            return ("Validation failed.", point);
        }
    }
}