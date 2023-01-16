// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./control_user.sol";

contract System is ControlUser {
    struct TransactionInfo { 
        /// @dev 確認用情報などを格納する構造体
        bytes32[] verificationInfo; /// @dev 確認用情報を格納する配列
        bool validated;           /// @dev 荷物情報が確認済みかどうかの確認に使用する
        uint transactionNo;       /// @dev 荷物番号
        uint shipTimes;           /// @dev 経由回数
    }

    uint transactionCount = 1; /// @dev 取引の数を格納する変数 -> 荷物番号の割り振りに使用する

    mapping (uint => TransactionInfo) identInfoToTransactionInfo; /// @dev 識別情報(荷物番号)から確認用情報の構造体を検索するマッピング
    mapping (uint => uint) transactionNoToId;                            /// @dev 荷物番号から特徴量を検索するマッピング
    mapping (uint => uint) idToTransactionNo;                            /// @dev 特徴量から荷物番号を検索するマッピング
    mapping (uint => mapping (uint => address)) transactionNoToShipper; /// @dev 荷物番号と経由回数から配送者のアドレスを検索するダブルマッピング

    function getInspectInfo(uint _transactionNo) public view returns (bytes32) {
        /// @dev マッピングから識別情報荷物番号)をもとに確認用情報を取得する関数
        return identInfoToTransactionInfo[_transactionNo].verificationInfo[0];
    }

    function getTransactionInfo(uint _transactionNo) public view returns (bytes32, bool, uint, uint) {
        /// @dev マッピングから識別情報(荷物番号)をもとにTransactionInfo構造体を取得する関数
        return (identInfoToTransactionInfo[_transactionNo].verificationInfo[0], 
                identInfoToTransactionInfo[_transactionNo].validated, 
                identInfoToTransactionInfo[_transactionNo].transactionNo,
                identInfoToTransactionInfo[_transactionNo].shipTimes);
    } 

} 