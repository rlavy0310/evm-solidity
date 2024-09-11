// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/ERC721Royalty.sol)

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";

contract Royalty is ERC721Royalty{

    constructor(address _receiver, uint96 feeNumerator)ERC721("test","test"){
        //为每个 NFT 所做的特许权使用费接收者和费用分子。
        _setDefaultRoyalty(_receiver, feeNumerator);
    }

    function safeMint(
        address to, 
        uint256 tokenId, 
        address receiver, 
        uint96 feeNumerator
    ) public {
        _safeMint(to, tokenId);

        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }
}
