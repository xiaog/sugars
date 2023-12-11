// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sugars is ERC721, Ownable {

    using Counters for Counters.Counter;
    using Strings for uint256;

    string public baseURI;

    Counters.Counter public tokenIds;

   constructor(address initialOwner)  ERC721("Sugars", "SG") Ownable(initialOwner){
        tokenIds.increment();
    }


    function setBaseURI(string memory _baseURIParam) public onlyOwner {
        baseURI = _baseURIParam;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function mint(address to) public returns (uint256) {
        uint256 tokenId = tokenIds.current();
        _safeMint(to, tokenId);

        tokenIds.increment();
        tokenIds.increment();

        return tokenId;
    }
    function _mintId(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId);
    }

    function _burnToken(uint256 tokenId) internal {
        _burn(tokenId);
    }
}