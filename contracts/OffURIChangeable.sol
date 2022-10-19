// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";

pragma solidity ^0.8.14;

contract OZOnlyOwnerMint is ERC721, Ownable {
    constructor() ERC721("OZOnlyOwnerMint", "OZNER") {}

    /**
     * @dev
     * - このコントラクトをデプロイしたアドレスだけがmint可能 onlyOwner
     * - nftmint関数の実行アドレスにtokenIdを紐付け
     */
    function nftMint(uint256 tokenId) public onlyOwner{
        _mint(_msgSender(), tokenId);

    }
}
