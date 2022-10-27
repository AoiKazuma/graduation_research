// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 発送者の処理のコントラクト
contract RegisterUnits is HashGenerator {
    function setTransaction(uint id, address sender, address receiver) public onlySender(sender) returns (uint){
        /// @dev 取引情報をセットする関数 -> 登録された取引番号を返す

        /// @dev register関数を呼び出し、検証用情報を生成しマッピングに格納する
        identInfoToTransactionInfo[transactionCount] = TransactionInfo(register(id, sender, receiver, transactionCount), false, transactionCount, 0, true);

        transactionNoToCheckTimes[transactionCount] = CheckTimes(false, false, 0, 0, 0); /// @dev CheckTimes構造体の初期化

        transactionCount++; /// @dev 取引番号の更新

        return transactionCount - 1;
    }

    function register(uint id, address sender, address receiver, uint _transactionNo) internal onlySender(sender) returns (bytes32) {
        /// @dev 識別情報、検証用情報を登録する関数
        require(idToTransactionNo[id] == 0); /// @dev 特徴量が既に他の取引番号と紐づいていないかチェックする

        /// @dev 取引番号と特徴量を紐付ける
        idToTransactionNo[id] = _transactionNo;
        transactionNoToId[_transactionNo] = id;

        return generate(id, sender, receiver, _transactionNo); /// @dev 生成されたハッシュ値を返す
    }
}