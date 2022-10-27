// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./control_user.sol";

contract System is ControlUser {
    struct TransactionInfo { 
        /// @dev 検証用情報などを格納する構造体
        bytes32 verificationInfo; /// @dev 検証用情報
        bool validated;           /// @dev 取引情報が検証済みかどうかの確認に使用する
        uint transactionNo;       /// @dev 取引番号
        uint shipTimes;           /// @dev 経由回数
        bool first;               /// @dev 最初の経由地を判断
    }

    struct CheckTimes {
        /// @dev 受取人が検証する際に使用する構造体
        bool started;   /// @dev 受取人が検証を始めたかの確認に使用する
        bool checked;   /// @dev 受取人がgetUpdateTimesを使用したかどうかの確認に使用する
        uint times;     /// @dev 前回の更新回数
        uint timesCopy; /// @dev ハッシュ値の残り更新回数
        bytes32 hash;   /// @dev 検証に使用するハッシュ値
    }

    uint transactionCount = 1; /// @dev 取引の数を格納する変数 -> 取引番号の割り振りに使用する

    mapping (uint => TransactionInfo) identInfoToTransactionInfo; /// @dev 識別情報(取引番号)から検証用情報の構造体を検索するマッピング
    mapping (uint => uint) transactionNoToId;                            /// @dev 取引番号から特徴量を検索するマッピング
    mapping (uint => uint) idToTransactionNo;                            /// @dev 特徴量から取引番号を検索するマッピング
    mapping (uint => CheckTimes) transactionNoToCheckTimes; /// @dev 取引の残り検証回数を格納するマッピング

    /*
        - @dev 
        - 配送者が経由回数を次の配送者に伝える際に使用する
        - 特徴量と配送者のアドレスから経由回数を検索するマッピング
    */
    mapping (uint => mapping (address => uint)) idToShipperAdrToTimes;

    function getInspectInfo(uint _transactionNo) public view returns (bytes32) {
        /// @dev マッピングから識別情報(取引番号)をもとに検証用情報を取得する関数
        return identInfoToTransactionInfo[_transactionNo].verificationInfo;
    }

    function getTransactionInfo(uint _transactionNo) public view returns (bytes32, bool, uint, uint) {
        /// @dev マッピングから識別情報(取引番号)をもとにTransactionInfo構造体を取得する関数
        return (identInfoToTransactionInfo[_transactionNo].verificationInfo, 
                identInfoToTransactionInfo[_transactionNo].validated, 
                identInfoToTransactionInfo[_transactionNo].transactionNo,
                identInfoToTransactionInfo[_transactionNo].shipTimes);
    } 

} 