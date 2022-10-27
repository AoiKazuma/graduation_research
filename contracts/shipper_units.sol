// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 配送者の処理のコントラクト
contract ShipperUnits is HashGenerator {
    function shipperProcess(uint id, address shipper, address nextShipper, uint _transactionNo) public returns (bytes32, uint){
        /// @dev 配送者が検証用情報を上書きする関数
        require(shipper == msg.sender); /// @dev 配送者のアドレスかどうかをチェックする

        if(identInfoToTransactionInfo[_transactionNo].first == true){
            /// @dev 最初の経由地の際に経由回数を1に更新する
            identInfoToTransactionInfo[_transactionNo].first = false;
            idToShipperAdrToTimes[id][shipper] = 1;
        }

        identInfoToTransactionInfo[_transactionNo].shipTimes = idToShipperAdrToTimes[id][shipper]; /// @dev 経由回数を更新する

        transactionNoToCheckTimes[_transactionNo].checked = false; /// @dev 配送者を経由したので受取人にもう一度チェックさせる

        /// @dev 配送者のアドレスと経由回数、前の検証用情報から上書き用の検証用情報を生成
        bytes32 newHash = keccak256(abi.encodePacked(shipper, idToShipperAdrToTimes[id][shipper], identInfoToTransactionInfo[_transactionNo].verificationInfo));

        if(nextShipper != shipper){
            /// @dev 現在の配送者で経由が最後の場合には受取人に届けると判断するため次の処理は飛ばす
            idToShipperAdrToTimes[id][nextShipper] = idToShipperAdrToTimes[id][shipper] + 1; /// @dev 次の配送者の経由回数を１回増やす
        }

        identInfoToTransactionInfo[_transactionNo].verificationInfo = newHash;              /// @dev 検証用情報の更新

        return (newHash, identInfoToTransactionInfo[_transactionNo].shipTimes);
    }
}