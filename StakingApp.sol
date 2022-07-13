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
    
    function makeStake(uint mins) external payable {
        require(interestRates[mins] > 0, "No such mapping");
        
        stakes[currentStakingId] = Staking(
            currentStakingId,
            msg.sender,
            block.timestamp,
            block.timestamp + (mins * 1 minutes),
            interestRates[mins],
            msg.value,
            calculateInterest(interestRates[mins], mins, msg.value),
            true
        );
        
        stakingIdsByAddress[msg.sender].push(currentStakingId);
        currentStakingId += 1;
    }
    
    function calculateInterest(uint rate, uint mins, uint amount) private pure returns(uint) {
        return rate * amount / 10000;
    }
    
    function getLockPeriods() external view returns(uint[] memory) {
        return lockPeriods;
    }
    
    function getInterestRate(uint mins) external  view returns(uint) {
        return interestRates[mins];
    }
    
    function getPositionById(uint id) external view returns(Staking memory) {
        return stakes[id];
    }
    
    function getStakesForAddress(address wallet) external view returns(uint[] memory) {
        return stakingIdsByAddress[wallet];
    }
    
    function closeStaking(uint id) external {
        require(stakes[id].walletAddress == msg.sender, "You are not allowed to modify this stake");
        require(stakes[id].open == true, "Stake is already closed");
        
        stakes[id].open = false;
        
        if(block.timestamp > stakes[id].releaseDate) {
            uint amount = stakes[id].amountStaked + stakes[id].amountInterest;
            payable(msg.sender).call{value: amount}("");
        } else {
            payable(msg.sender).call{value: stakes[id].amountStaked}("");
        }
    }
}
