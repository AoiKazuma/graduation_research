// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./hash_generator.sol";

/// @dev 配送者の処理のコントラクト
contract ShipperUnits is HashGenerator {
    function shipperProcess(uint id, address shipper, uint _transactionNo) public returns (bytes32, uint){
        /// @dev 配送者が検証用情報を上書きする関数
        require(shipper == msg.sender); /// @dev 配送者のアドレスかどうかをチェックする

        identInfoToTransactionInfo[_transactionNo].shipTimes++; /// @dev 経由回数を増加させる

        /// @dev 配送者のアドレスと経由回数、前の検証用情報から上書き用の検証用情報を生成
        bytes32 newHash = keccak256(abi.encodePacked(id, identInfoToTransactionInfo[_transactionNo].shipTimes, identInfoToTransactionInfo[_transactionNo].verificationInfo[0]));

        identInfoToTransactionInfo[_transactionNo].verificationInfo.push(newHash); /// @dev 途中の検証用情報の追加

        return (newHash, identInfoToTransactionInfo[_transactionNo].shipTimes);
    }
}