// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 配送者の処理のコントラクト
contract ShipperUnits is HashGenerator {
    function shipperProcess(uint id, address shipper, uint _transactionNo) public returns (bytes32, uint){
        /// @dev 配送者が確認用情報を登録する関数
        require(shipper == msg.sender); /// @dev 配送者のアドレスかどうかをチェックする

        identInfoToTransactionInfo[_transactionNo].shipTimes++; /// @dev 経由回数を増加させる

        /// @dev 配送者のアドレスと経由回数、発送者が登録した確認用情報から確認用情報を生成
        bytes32 newHash = keccak256(abi.encodePacked(id, identInfoToTransactionInfo[_transactionNo].shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0], shipper));

        transactionNoToShipper[_transactionNo][identInfoToTransactionInfo[_transactionNo].shipTimes] = shipper; /// @dev マッピングに配送者のアドレスを格納
        identInfoToTransactionInfo[_transactionNo].verificationInfo.push(newHash); /// @dev 途中の確認用情報の追加

        return (newHash, identInfoToTransactionInfo[_transactionNo].shipTimes);
    }
}