// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 受取人の処理のコントラクト
contract IdentifierUnits is HashGenerator {
    modifier receiverStarted(uint _transactionNo) {
        /// @dev 受取人が検証をスタートしているかの確認
        require(transactionNoToCheckTimes[_transactionNo].started == true, "Validation not started.");
        _;
    }

    modifier validateConfirm(uint _transactionNo) {
        /// @dev 検証に入る前の確認
        require(identInfoToTransactionInfo[_transactionNo].validated == false); /// @dev 取引が検証済みでないかどうかを確認する
        require(transactionNoToCheckTimes[_transactionNo].timesCopy == 0);      /// @dev 途中までのハッシュ値更新ができているかを確認する
        _;
    }

    function startValidate(uint id, address sender, address receiver, uint _transactionNo) public onlyReceiver(receiver) {
        /// @dev 受取人が検証を始める際に最初に実行させる関数
        require(transactionNoToCheckTimes[_transactionNo].started == false, "Validation started."); /// @dev スタートしていないかの確認

        transactionNoToCheckTimes[_transactionNo].started = true; /// @dev 検証をスタートさせる

        /// @dev 最初のハッシュ値を生成する
        transactionNoToCheckTimes[_transactionNo].hash = generate(id, sender, receiver, _transactionNo);
    }

    function getUpdateTimes(address receiver, uint _transactionNo) public onlyReceiver(receiver) receiverStarted(_transactionNo) returns (uint) {
        /// @dev 該当取引の配送者の経由回数を返す関数

        require(transactionNoToCheckTimes[_transactionNo].checked == false, "Used getUpdateTimes."); /// @dev getUpdateTimes関数を未使用かどうかの確認

        transactionNoToCheckTimes[_transactionNo].checked = true; /// @dev getUpdateTimes関数を使用済みにする
        /// @dev 前回更新からの差分を求めて.timesCopyに格納
        transactionNoToCheckTimes[_transactionNo].timesCopy += identInfoToTransactionInfo[_transactionNo].shipTimes - transactionNoToCheckTimes[_transactionNo].times; 
        transactionNoToCheckTimes[_transactionNo].times = identInfoToTransactionInfo[_transactionNo].shipTimes; /// @dev 更新

        return transactionNoToCheckTimes[_transactionNo].timesCopy;
    }

    function updateVerificationInfo(uint id, address receiver, address shipper, uint _transactionNo) public onlyReceiver(receiver) receiverStarted(_transactionNo) returns (bytes32) {
        /// @dev ハッシュ値を更新する関数
        require(transactionNoToCheckTimes[_transactionNo].timesCopy != 0); /// @dev 更新回数が残り0でないことの確認

        /// @dev ハッシュ値の更新
        transactionNoToCheckTimes[_transactionNo].hash = keccak256(abi.encodePacked(shipper, idToShipperAdrToTimes[id][shipper], transactionNoToCheckTimes[_transactionNo].hash));
        transactionNoToCheckTimes[_transactionNo].timesCopy--; /// @dev 更新残り回数を減らす

        return transactionNoToCheckTimes[_transactionNo].hash;
    }

    function clearVerification(uint id, address sender, address receiver, uint _transactionNo) public onlyReceiver(receiver) {
        /// @dev 検証中の処理を初期化する関数
        /// @dev 最初の検証用情報に戻す
        transactionNoToCheckTimes[_transactionNo].hash = generate(id, sender, receiver, _transactionNo);

        /// @dev getUpdateTimes関数を未使用に設定する
        transactionNoToCheckTimes[_transactionNo].checked = false;
        transactionNoToCheckTimes[_transactionNo].times = 0;
    }

    function middleConfirm(address receiver, uint _transactionNo) public view onlyReceiver(receiver) validateConfirm(_transactionNo) returns (string memory, bytes32) {
        /// @dev 途中の検証用情報を確認する関数
        if(transactionNoToCheckTimes[_transactionNo].hash == identInfoToTransactionInfo[_transactionNo].verificationInfo){
            /// @dev 途中までの検証情報が一致するかを確認
            return ("Middle validation succeeded!!", transactionNoToCheckTimes[_transactionNo].hash);
        } else {
            return ("Middle validation failed.", transactionNoToCheckTimes[_transactionNo].hash);
        }
    }

    function identify(address receiver, uint _transactionNo) public onlyReceiver(receiver) receiverStarted(_transactionNo) validateConfirm(_transactionNo) returns (string memory) {
        /// @dev マッピングから検証用情報を検索し、検証する関数
        if(transactionNoToCheckTimes[_transactionNo].hash == identInfoToTransactionInfo[_transactionNo].verificationInfo){
            /// @dev 受取人が生成したハッシュ値と検証用情報が一致していれば検証済情報を付与する
            identInfoToTransactionInfo[_transactionNo].validated = true;

            return "Validation succeeded!!";
        } else {
            return "Validation failed.";
        }
    }
}