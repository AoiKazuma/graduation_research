// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract System {
    struct TransactionInfo { 
        /// @dev 取引情報を格納する構造体
        address sender;      /// @dev 発送者の名前
        address receiver;    /// @dev 受取人の名前
        uint transactionNo; /// @dev 取引番号
    }

    uint transactionCount = 1;          /// @dev 取引の数を格納する変数 -> 取引番号の割り振りに使用する

    mapping (uint => bytes32) public identInfoToInspectInfo;      /// @dev 識別情報(取引番号)から検証用情報を検索するマッピング
    mapping (uint => TransactionInfo) identInfoToTransactionInfo; /// @dev 識別情報(取引番号)から取引情報を検索するマッピング
    mapping (uint => uint) transactionNoToLabelId;                /// @dev 取引番号からラベルIDを検索するマッピング
    mapping (uint => uint) private labelIdToTransactionNo;        /// @dev ラベルIDから取引番号を検索するマッピング

    function generate(uint _labelId, uint _transactionNo) public view returns (bytes32) {
        /// @dev ラベルIDと取引情報からハッシュ値を生成する関数
        TransactionInfo memory _transactionInfo = identInfoToTransactionInfo[_transactionNo]; /// @dev 取引番号から取引情報を検索して格納

        return keccak256(abi.encodePacked(_labelId, _transactionInfo.sender, _transactionInfo.receiver, _transactionInfo.transactionNo));
    }

    function setTransaction(address _sender, address _receiver) public returns (uint) {
        /// @dev 取引情報をセットする関数 -> 登録された取引番号を返す
        identInfoToTransactionInfo[transactionCount] = TransactionInfo(_sender, _receiver, transactionCount); /// @dev 取引番号から取引情報を検索できるようにする
        transactionCount++;                                                                                   /// @dev 取引番号の更新

        return transactionCount - 1;
    }

    function register(uint _labelId, uint _transactionNo) public returns (bytes32) {
        /// @dev 登録部 -> 識別情報、検証用情報を登録する関数
        require(labelIdToTransactionNo[_labelId] == 0); /// @dev ラベルIDが既に他の取引番号と紐づいていないかチェックする

        /// @dev 取引番号とラベルIDを紐付ける
        labelIdToTransactionNo[_labelId] = _transactionNo;
        transactionNoToLabelId[_transactionNo] = _labelId;                           

        identInfoToInspectInfo[_transactionNo] = generate(_labelId, _transactionNo); /// @dev マッピングに検証用情報となるハッシュ値を格納{識別情報(取引番号)と対応づけている}

        return identInfoToInspectInfo[_transactionNo];
    }

    function getInspectInfo(uint _transactionNo) public view returns (bytes32) {
        /// @dev マッピングから識別情報(取引番号)をもとに検証用情報を取得する関数
        return identInfoToInspectInfo[_transactionNo];
    }

    function getTransactionInfo(uint _transactionNo) public view returns (address, address, uint) {
        /// @dev マッピングから識別情報(取引番号)をもとに取引情報を取得する関数
        return (identInfoToTransactionInfo[_transactionNo].sender, 
                identInfoToTransactionInfo[_transactionNo].receiver, 
                identInfoToTransactionInfo[_transactionNo].transactionNo);
    } 

} 