// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./control_user.sol";

contract System is ControlUser {
    struct TransactionInfo { 
        /// @dev 取引情報を格納する構造体
        address sender;         /// @dev 発送者のアドレス
        address receiver;       /// @dev 受取人のアドレス
        uint transactionNo;     /// @dev 取引番号
        bool validated; /// @dev 取引情報が検証済みかどうかの確認に使用する
    }

    uint transactionCount = 1;          /// @dev 取引の数を格納する変数 -> 取引番号の割り振りに使用する


    mapping (uint => bytes32) public identInfoToInfoForVerification;      /// @dev 識別情報(取引番号)から検証用情報を検索するマッピング
    mapping (uint => TransactionInfo) identInfoToTransactionInfo;         /// @dev 識別情報(取引番号)から取引情報を検索するマッピング
    mapping (uint => uint) transactionNoToLabelId;                        /// @dev 取引番号からラベルIDを検索するマッピング
    mapping (uint => uint) labelIdToTransactionNo;                /// @dev ラベルIDから取引番号を検索するマッピング

     /* 
        @dev senderToReceiverToLabelId: 発送者と受取人のアドレスからラベルIDを検索するダブルマッピング
        @dev 配送業者がラベルIDを読み取った際に発送者と受取人の２つのアドレスとラベルIDを紐付ける
     */
    mapping (address => mapping (address => uint)) senderToReceiverToLabelId;

    function getInspectInfo(uint _transactionNo) public view returns (bytes32) {
        /// @dev マッピングから識別情報(取引番号)をもとに検証用情報を取得する関数
        return identInfoToInfoForVerification[_transactionNo];
    }

    function getTransactionInfo(uint _transactionNo) public view returns (address, address, uint) {
        /// @dev マッピングから識別情報(取引番号)をもとに取引情報を取得する関数
        return (identInfoToTransactionInfo[_transactionNo].sender, 
                identInfoToTransactionInfo[_transactionNo].receiver, 
                identInfoToTransactionInfo[_transactionNo].transactionNo);
    } 

} 