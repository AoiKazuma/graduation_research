// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 発送者の処理のコントラクト
contract RegisterUnits is HashGenerator {
    function setTransaction(uint Id, address _sender, address _receiver) public onlySender(_sender) returns (uint){
        /// @dev 取引情報をセットする関数 -> 登録された取引番号を返す

        /// @dev register関数を呼び出し、検証用情報を生成しマッピングに格納する
        identInfoToTransactionInfo[transactionCount] = TransactionInfo(register(Id, _sender, _receiver, transactionCount), false, transactionCount);

        transactionCount++; /// @dev 取引番号の更新

        return transactionCount - 1;
    }

    function register(uint Id, address _sender, address _receiver, uint _transactionNo) internal onlySender(_sender) returns (bytes32) {
        /// @dev 識別情報、検証用情報を登録する関数
        require(IdToTransactionNo[Id] == 0); /// @dev 特徴量が既に他の取引番号と紐づいていないかチェックする

        /// @dev 取引番号と特徴量を紐付ける
        IdToTransactionNo[Id] = _transactionNo;
        TransactionNoToId[_transactionNo] = Id;

        return generate(Id, _sender, _receiver, _transactionNo); /// @dev 生成されたハッシュ値を返す
    }
}