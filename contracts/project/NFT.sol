//没有后端辅助的情况下，在◌(1)复杂度实现了白名单功能，使用链表。
//结合后端可以使用merkle tree的形式，合约只存merkle root。

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract NFT is ERC721, Ownable(msg.sender), Pausable{
    mapping(address => address) _whiteList;
    mapping(address => bool) _whiteListerMinted;
    uint256 public listSize;
    uint256 nftValue;
    uint256 globalID;
    address constant FLAG = address(1);
    address _payee;

    constructor() ERC721("", ""){
        _whiteList[FLAG] = FLAG;
        _payee = msg.sender;
        nftValue = ...;
        _pause();
    }

    //receive() external payable {}

    function _baseURI() internal pure override returns (string memory) {
        return "...";
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);

        return _baseURI();
    }

    function isWhiteLister(address lister_) public view returns (bool) {
        return _whiteList[lister_] != address(0);
    }

    function getWhiteLister() public view returns (address[] memory) {
        address[] memory whiteListers = new address[](listSize);
        address currentAddress = _whiteList[FLAG];
        for (uint256 i = 0; currentAddress != FLAG; ++i) {
            whiteListers[i] = currentAddress;
            currentAddress = _whiteList[currentAddress];
        }

        return whiteListers;
    }

    function mint() external payable {
        if (isWhiteLister(msg.sender)) {
            require(!_whiteListerMinted[msg.sender], "already minted");
            _whiteListerMinted[msg.sender] = true;
            _mint(msg.sender, ++globalID);
        } else {
            require(msg.value >= nftValue);
            payable(_payee).transfer(msg.value);
            _mint(msg.sender, ++globalID);
        }
    }

    function burn(uint256 tokenId_) external onlyOwner {
        _burn(tokenId_);
    }

    function transferFrom(address from, address to, uint256 tokenId) override whenNotPaused() public virtual {
        super.transferFrom(from, to, tokenId);
    }

    function pause()external onlyOwner{
         _pause();
    }

    function unpause()external onlyOwner{
         _unpause();
    }

    function addWhiteLister(address lister_) external onlyOwner {
        require(!isWhiteLister(lister_));
        _whiteList[lister_] = _whiteList[FLAG];
        _whiteList[FLAG] = lister_;
        listSize++;
    }

    function addWhiteLister(address[] memory lister_) external onlyOwner {
        for (uint256 i = 0; i < lister_.length; i++) {
            require(!isWhiteLister(lister_[i]));
            _whiteList[lister_[i]] = _whiteList[FLAG];
            _whiteList[FLAG] = lister_[i];
            listSize++;
        }
    }

    function removeWhiteLister(address lister_) external onlyOwner {
        require(isWhiteLister(lister_));
        address prevWhiteList = _getPrevWhiteLister(lister_);
        _whiteList[prevWhiteList] = _whiteList[lister_];
        _whiteList[lister_] = address(0);
        listSize--;
    }

    function setPayee(address payee_) external onlyOwner {
        _payee = payee_;
    }

    function setValue(uint256 value_) external onlyOwner {
        nftValue = value_;
    }

    function getID() public view returns (uint256) {
        return globalID;
    }

    function _getPrevWhiteLister(address lister_)
        internal
        view
        returns (address)
    {
        address currentAddress = FLAG;
        while (_whiteList[FLAG] != FLAG) {
            if (_whiteList[currentAddress] == lister_) {
                return currentAddress;
            }
            currentAddress = _whiteList[currentAddress];
        }
        return address(0);
    }
}
