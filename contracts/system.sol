// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./control_user.sol";

contract System is ControlUser {
    struct TransactionInfo { 
        /// @dev 検証用情報などを格納する構造体
        bytes32[] verificationInfo; /// @dev 検証用情報を格納する配列
        bool validated;           /// @dev 取引情報が検証済みかどうかの確認に使用する
        uint transactionNo;       /// @dev 取引番号
        uint shipTimes;           /// @dev 経由回数
    }

    uint transactionCount = 1; /// @dev 取引の数を格納する変数 -> 取引番号の割り振りに使用する

    mapping (uint => TransactionInfo) identInfoToTransactionInfo; /// @dev 識別情報(取引番号)から検証用情報の構造体を検索するマッピング
    mapping (uint => uint) transactionNoToId;                            /// @dev 取引番号から特徴量を検索するマッピング
    mapping (uint => uint) idToTransactionNo;                            /// @dev 特徴量から取引番号を検索するマッピング
    mapping (uint => mapping (uint => address)) transactionNoToShipper; /// @dev 取引番号と経由回数から配送者のアドレスを検索するダブルマッピング

    function getInspectInfo(uint _transactionNo) public view returns (bytes32) {
        /// @dev マッピングから識別情報(取引番号)をもとに検証用情報を取得する関数
        return identInfoToTransactionInfo[_transactionNo].verificationInfo[0];
    }

    function getTransactionInfo(uint _transactionNo) public view returns (bytes32, bool, uint, uint) {
        /// @dev マッピングから識別情報(取引番号)をもとにTransactionInfo構造体を取得する関数
        return (identInfoToTransactionInfo[_transactionNo].verificationInfo[0], 
                identInfoToTransactionInfo[_transactionNo].validated, 
                identInfoToTransactionInfo[_transactionNo].transactionNo,
                identInfoToTransactionInfo[_transactionNo].shipTimes);
    } 

} 