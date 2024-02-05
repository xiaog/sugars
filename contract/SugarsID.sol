
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.2/contracts/access/Ownable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.2/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/Counters.sol";



contract SugarID is ERC721, Ownable {

    using Counters for Counters.Counter;
    using Strings for uint256;

    string public baseURI;

    Counters.Counter public tokenIds;

   constructor()  ERC721("SugarID", "SD") {
        tokenIds.increment();
    }

    function setBaseURI(string memory _baseURIParam) public onlyOwner {
        baseURI = _baseURIParam;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function mint(address to) public returns (uint256) {
        uint256 tokenId = tokenIds.current  ();
        _safeMint(to, tokenId);

        tokenIds.increment();

        return tokenId;
    }
    function _mintId(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId);
    }

    function burnToken(uint256 tokenId) public onlyOwner{
        _burnToken(tokenId);
    }

    function _burnToken(uint256 tokenId) internal {
        _burn(tokenId);
    }
}
