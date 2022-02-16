// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./Token.sol";

contract dBank {

  Token private token; 
  //add mappings
  mapping(address => uint) public getEtherBalance;
  mapping(address => uint) public depositStart;
  mapping(address => bool) public isDeposited;

  //add events
  event Deposit(address indexed user, uint etherAmount, uint timeStart);
  event Withdraw(address indexed user, uint userBalance, uint depositTime, uint interest);

  //pass as constructor argument deployed Token contract
  constructor(Token _token) public {
    token = _token;
  }

  function deposit() payable public {
    require(isDeposited[msg.sender] == false, "Error: Deposit already active!");
    require(msg.value >= 10**16, "Error: deposit value must be >= 0.01 ETH");

    getEtherBalance[msg.sender] = getEtherBalance[msg.sender] + msg.value;
    depositStart[msg.sender] = depositStart[msg.sender] + block.timestamp;

    isDeposited[msg.sender] = true; //activate deposit status
    emit Deposit(msg.sender, msg.value, block.timestamp);
  }

  function withdraw() public {
    //check if msg.sender deposit status is true
    require(isDeposited[msg.sender] == true, 'Error: No previous deposit');
    uint userBalance = getEtherBalance[msg.sender];

    uint depositTime = block.timestamp - depositStart[msg.sender];
    //calc accrued interest
    uint interestPerSecond = 31668017 * (userBalance / 1e16); // 10% APY per year for 0.01 ETH
    uint interest = 1e16;

    token.mint(msg.sender, interest);

    msg.sender.transfer(userBalance);
    
    depositStart[msg.sender] = 0;
    getEtherBalance[msg.sender] = 0;
    isDeposited[msg.sender] = false;

    emit Withdraw(msg.sender, userBalance, depositTime, interest);

  }
}