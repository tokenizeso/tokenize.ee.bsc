// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.2/access/AccessControl.sol";

/// @custom:security-contact saurav.raaj@gmail.com
contract TOKENIZE is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, AccessControl {
    
    struct AssetsToken {
        address Issuer;
        address User;
        string Collection;
        bool Tradable;
        bool Mendable;
        bool Burnable;
    }
    
    string[] public ContractCollections;
    mapping(uint256 => AssetsToken) TokenData;
    mapping(string => bool) public CheckCollection;
    mapping(string => uint256[]) public CollectionTokens;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC721("TOKENIZE", "ASX") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }
    function TokenMint(address Issuer, address User, 
        uint256 TokenId, string memory TokenLink, string memory CollectionId, 
        bool Tradable, bool Mendable, bool Burnable) 
        public onlyRole(MINTER_ROLE) {
        require(!_exists(TokenId), "409: Token Exists");
        _safeMint(User, TokenId);
        _setTokenURI(TokenId, TokenLink);
        TokenData[TokenId] = AssetsToken(Issuer, User, CollectionId, Tradable, Mendable, Burnable);
        _setContractCollections(CollectionId);
        _setContractCollectionTokens(CollectionId, TokenId, 1);        
    }
    function TokenTransfer(address Issuer, address User, 
        uint256 TokenId, string memory TokenLink, string memory CollectionId, 
        bool Tradable, bool Mendable, bool Burnable) 
        public onlyRole(MINTER_ROLE){
        require(_exists(TokenId), "404: Not Found");
        require(TokenData[TokenId].Tradable, "409: Attributes");
        _transfer(Issuer, User, TokenId);
        _setTokenURI(TokenId, TokenLink);
        TokenData[TokenId] = AssetsToken(Issuer, User, CollectionId, Tradable, Mendable, Burnable);
    }
    function TokenBurn(uint256 TokenId, string memory CollectionId) 
        public onlyRole(MINTER_ROLE){
        require(_exists(TokenId), "404: Not Found");
        require(TokenData[TokenId].Burnable, "409: Attributes");
        _burn(TokenId);
        _setContractCollectionTokens(CollectionId, TokenId, 0);
    }
    function SetTokenLink(uint256 TokenId, string memory TokenLink) 
        public onlyRole(MINTER_ROLE) {
        require(_exists(TokenId), "404: Not Found");
        require(TokenData[TokenId].Mendable, "409: Attributes");
        _setTokenURI(TokenId, TokenLink);
    }
    function GetTokenLink(uint256 TokenId) 
        public view onlyRole(MINTER_ROLE) returns (string memory) {
        require(_exists(TokenId), "404: Not Found");
        return super.tokenURI(TokenId);
    }
    function GetTokenData(uint256 TokenId) 
        public view onlyRole(MINTER_ROLE) returns (AssetsToken memory) {
        require(_exists(TokenId), "404: Not Found");
        return TokenData[TokenId];
    }
    function GetCollections() 
        public view onlyRole(MINTER_ROLE) returns (string[] memory) {
        return ContractCollections;
    }
    function GetCollectionTokens(string memory CollectionId) 
        public view onlyRole(MINTER_ROLE) returns (uint256[] memory) {
        return CollectionTokens[CollectionId];
    }
    function _setContractCollections(string memory CollectionId)
      private {
      CheckCollection[CollectionId] = true;
      ContractCollections.push(CollectionId);
    }
    function _setContractCollectionTokens(string memory CollectionId, uint256 TokenId, uint mode)
      private {
      if (mode == 1) {
        CollectionTokens[CollectionId].push(TokenId);
        }
      if (mode == 0) {
        uint TokenIndex = _indxCollectionToken(CollectionId, TokenId);
        CollectionTokens[CollectionId][TokenIndex] = CollectionTokens[CollectionId][CollectionTokens[CollectionId].length - 1];
        CollectionTokens[CollectionId].pop();
      }
    }
    function _indxCollectionToken(string memory CollectionId, uint256 TokenId)
      private view returns (uint) {
      bool index = false;
      uint x = 0;
      while (x < CollectionTokens[CollectionId].length && !index) {
        if(CollectionTokens[CollectionId][x] == TokenId) {
          index = true;
        }
        x++;
      }
      return x-1;
    }


    function safeMint(address to, uint256 tokenId, string memory uri)
        public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal override(ERC721, ERC721Enumerable) onlyRole(MINTER_ROLE){
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) 
        internal override(ERC721, ERC721URIStorage) onlyRole(MINTER_ROLE){
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) 
        onlyRole(MINTER_ROLE) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
