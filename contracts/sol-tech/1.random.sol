function publicMint() public payable {
        uint256 supply = totalSupply();
        require(!pauseMint, "Pause mint");
        require(msg.value >= price, "Ether sent is not correct");
        require(supply + 1 <= maxTotal, "Exceeds maximum supply");
        _safeMint(msg.sender, 1);
        bool randLucky = _getRandom();
        uint256 tokenId = _totalMinted();
        emit NEWLucky(tokenId, randLucky);
        tokenId_luckys[tokenId] = lucky;
        if(tokenId_luckys[tokenId] == true){
        require(payable(msg.sender).send((price * 190) / 100));
        require(payable(withdrawAddress).send((price * 10) / 100));}
    }

//It is very dangerous to rely on block information to generate random numbers.

    function _getRandom() private returns(bool) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        uint256 rand = random%2;
        if(rand == 0){return lucky = false;}
        else         {return lucky = true;}
    }
