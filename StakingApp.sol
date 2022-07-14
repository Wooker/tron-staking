// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.16 <0.9.0;

contract StakingApp {
    address public owner;
    
    struct Staking {
        uint id;
        address walletAddress;
        uint creationDate;
        uint releaseDate;
        uint interestRate;
        uint amountStaked;
        uint amountInterest;
        bool open;
    }
    
    Staking staking;
    
    uint public currentStakingId;
    mapping(uint => Staking) public stakes;
    mapping(address => uint[]) public stakingIdsByAddress;
    mapping(uint => uint) interestRates;
    uint[] lockPeriods;
    
    constructor() payable {
        owner = msg.sender;
        currentStakingId = 0;
        
        interestRates[3] = 200;
        interestRates[5] = 400;
        interestRates[10] = 700;
        
        lockPeriods.push(3);
        lockPeriods.push(5);
        lockPeriods.push(10);
    }
    
    function makeStake(uint amount, uint mins) public payable returns(uint id) {
        require(interestRates[mins] > 0, "No such mapping");
        id = currentStakingId;
        
        stakes[id] = Staking(
            currentStakingId,
            msg.sender,
            block.timestamp,
            block.timestamp + (mins * 1 minutes),
            interestRates[mins],
            amount * 1 trx,
            calculateInterest(interestRates[mins], amount),
            true
        );
        
        stakingIdsByAddress[msg.sender].push(currentStakingId);
        currentStakingId += 1;
        
        return id;
    }
    
    function calculateInterest(uint rate, uint amount) private pure returns(uint) {
        return rate * amount / 10000 * 1 trx;
    }
    
    function getStakeById(uint id) public payable returns(Staking memory) {
        return stakes[id];
    }
    
    function getStakesForAddress(address wallet) public payable returns(uint[] memory) {
        return stakingIdsByAddress[wallet];
    }
    
    function closeStaking(uint id) public payable {
        require(stakes[id].walletAddress == msg.sender, "You are not allowed to modify this stake");
        require(stakes[id].open == true, "Stake is already closed");
        
        stakes[id].open = false;
        
        if(block.timestamp > stakes[id].releaseDate) {
            uint amount = stakes[id].amountStaked + stakes[id].amountInterest;
            payable(msg.sender).call{value: amount * 1 trx}("");
        } else {
            payable(msg.sender).call{value: stakes[id].amountStaked * 1 trx}("");
        }
    }
}
