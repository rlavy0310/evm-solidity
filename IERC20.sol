// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

interface IERC20 {
    
  function totalSupply() external view returns (uint256);
  
  function balanceOf(address tokenOwner) external view returns (uint256 balance);
  
  function transfer(address to, uint256 tokens) external returns (bool success);
  
  function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
  
  function approve(address spender, uint256 tokens) external returns (bool success);

  function transferFrom(address from, address to, uint256 tokens) external returns (bool success);

  event Transfer(address indexed from, address indexed to, uint256 tokens);

  event Approval(address indexed owner, address indexed spender, uint256 tokens);
}
