// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 受取人の処理のコントラクト
contract IdentifierUnits is HashGenerator {
    modifier validateConfirm(uint _transactionNo) {
        /// @dev 取引が確認済みでないかどうかを確認する
        require(identInfoToTransactionInfo[_transactionNo].validated == false); 
        _;
    }

    function middleConfirm(uint id, address receiver, uint _transactionNo, uint _shipTimes) public view onlyReceiver(receiver) validateConfirm(_transactionNo) returns (string memory, bytes32) {
        /// @dev 途中の確認用情報を確認する関数
        if(identInfoToTransactionInfo[_transactionNo].verificationInfo[_shipTimes] == keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0], transactionNoToShipper[_transactionNo][_shipTimes]))){
            /// @dev 途中までの確認用情報が一致するかを確認
            return ("Middle validation succeeded!!", keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0])));
        } else {
            return ("Middle validation failed.", keccak256(abi.encodePacked(id, _shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0])));
        }
    }

    function identify(uint id, uint correctId, address sender, address receiver, uint _transactionNo) public onlyReceiver(receiver) validateConfirm(_transactionNo) returns (bytes32, bytes32, string memory, uint) {
        /// @dev マッピングから確認用情報を検索し、検証する関数
        uint point = identInfoToTransactionInfo[_transactionNo].shipTimes + 1; /// @dev どの配送ポイントで不正が行われたかを格納する変数

        if(identInfoToTransactionInfo[_transactionNo].verificationInfo[0] == generate(id, sender, receiver, _transactionNo)){
            /// @dev 受取人が生成したハッシュ値と確認用情報が一致していれば確認済情報を付与する
            identInfoToTransactionInfo[_transactionNo].validated = true;

            return (generate(id, sender, receiver, _transactionNo), identInfoToTransactionInfo[_transactionNo].verificationInfo[0], "Validation succeeded!!", 0);           
        } else {
            /// @dev 確認に失敗した場合、どこの配送地点で不正が行われていたのかを返す
            for(uint i=identInfoToTransactionInfo[_transactionNo].shipTimes;i>0;i--){
                /// @dev 配送者が登録した情報を遡って１つずつ見ていく
                if(identInfoToTransactionInfo[_transactionNo].verificationInfo[i] == keccak256(abi.encodePacked(correctId, i, identInfoToTransactionInfo[_transactionNo].verificationInfo[0], transactionNoToShipper[_transactionNo][i]))){
                    /// @dev 一致した場合にはこの後不正が行われたと判断する 
                    break;
                } else {
                    point--;
                }
            }

            return (generate(id, sender, receiver, _transactionNo), identInfoToTransactionInfo[_transactionNo].verificationInfo[0], "Validation failed.", point);
        }
    }
}