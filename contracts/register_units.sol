// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 登録装置のコントラクト
contract RegisterUnits is HashGenerator {
    function setTransaction(uint _labelId, address _sender, address _receiver) public onlySender(_sender) {
        /// @dev 取引情報をセットする関数 -> 登録された取引番号を返す
        identInfoToTransactionInfo[transactionCount] = TransactionInfo(_sender, _receiver, transactionCount, false); /// @dev 取引番号から取引情報を検索できるようにする

        register(_labelId, _sender, _receiver, transactionCount); /// @dev 登録部を呼び出す

        transactionCount++; /// @dev 取引番号の更新
    }

    function register(uint _labelId, address _sender, address _receiver, uint _transactionNo) internal onlySender(_sender) returns (bytes32) {
        /// @dev 識別情報、検証用情報を登録する関数
        require(labelIdToTransactionNo[_labelId] == 0); /// @dev ラベルIDが既に他の取引番号と紐づいていないかチェックする

        /// @dev 取引番号とラベルIDを紐付ける
        labelIdToTransactionNo[_labelId] = _transactionNo;
        transactionNoToLabelId[_transactionNo] = _labelId;

        identInfoToInfoForVerification[_transactionNo] = generate(_labelId, _sender, _receiver, _transactionNo); /// @dev マッピングに検証用情報となるハッシュ値を格納{識別情報(取引番号)と対応づけている}

        return identInfoToInfoForVerification[_transactionNo];
    }
}