// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract System {
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
    mapping (uint => uint) private labelIdToTransactionNo;                /// @dev ラベルIDから取引番号を検索するマッピング

     /* 
        @dev senderToReceiverToLabelId: 発送者と受取人のアドレスからラベルIDを検索するダブルマッピング
        @dev 配送業者がラベルIDを読み取った際に発送者と受取人の２つのアドレスとラベルIDを紐付ける
     */
    mapping (address => mapping (address => uint)) senderToReceiverToLabelId;

    function generate(uint _labelId, address _sender, address _receiver, uint _transactionNo) public pure returns (bytes32) {
        /// @dev ラベルIDと取引情報からハッシュ値を生成する関数
        return keccak256(abi.encodePacked(_labelId, _sender, _receiver, _transactionNo));
    }

    function setTransaction(address _sender, address _receiver) public returns (uint) {
        /// @dev 取引情報をセットする関数 -> 登録された取引番号を返す
        identInfoToTransactionInfo[transactionCount] = TransactionInfo(_sender, _receiver, transactionCount, false); /// @dev 取引番号から取引情報を検索できるようにする
        transactionCount++;                                                                                   /// @dev 取引番号の更新

        return transactionCount - 1;
    }

    function register(uint _labelId, address _sender, address _receiver, uint _transactionNo) public returns (bytes32) {
        /// @dev 登録部 -> 識別情報、検証用情報を登録する関数
        require(_sender == msg.sender); /// @dev 該当するトランザクションの発送者と関数の使用者が一致するかの確認
        require(labelIdToTransactionNo[_labelId] == 0);                           /// @dev ラベルIDが既に他の取引番号と紐づいていないかチェックする

        /// @dev 取引番号とラベルIDを紐付ける
        labelIdToTransactionNo[_labelId] = _transactionNo;
        transactionNoToLabelId[_transactionNo] = _labelId;                           

        identInfoToInfoForVerification[_transactionNo] = generate(_labelId, _sender, _receiver, _transactionNo); /// @dev マッピングに検証用情報となるハッシュ値を格納{識別情報(取引番号)と対応づけている}

        return identInfoToInfoForVerification[_transactionNo];
    }

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

    function labelValidate(uint _labelId, address _sender, address _receiver) public {
        /// @dev 検証フェーズで配送業者がラベルIDを読み取り、senderToReceiverToLabelIdに格納する関数
        senderToReceiverToLabelId[_sender][_receiver] = _labelId;
    }

    function identify(address _sender, address _receiver, uint _transactionNo) public returns (string memory) {
        /// @dev マッピングから検証用情報を検索し、ハッシュ値を生成、検証する関数

        /// @dev identify関数を使用できるのは受取人のアドレスからのみ
        require(_receiver == msg.sender); 

        /// @dev 取引が検証済みでないかどうかを確認する
        require(identInfoToTransactionInfo[_transactionNo].validated == false); 

        uint _labelId = senderToReceiverToLabelId[_sender][_receiver]; /// @dev 配送業者が読み取ったラベルIDを引き出す

        if(identInfoToInfoForVerification[_transactionNo] == generate(_labelId, _sender, _receiver, _transactionNo)){
            /// @dev 取引情報とラベルIDから得られたハッシュ値と検証用情報が一致していれば検証済情報を付与する
            identInfoToTransactionInfo[_transactionNo].validated = true;

            return "Validation succeeded!!";
        } else {
            return "Validation failed.";
        }
    }

} 