// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IvMesh {
    function lockMESH(uint256 _amount, uint256 _period) external; // 1555200000 is Max Period (8x)
    function claimReward() external;
    function getCurrentBalance(address _usr) external view returns(uint);
    function totalSupply() external view returns(uint);
    function lockedKSP(address _usr) external view returns (uint);
    function userRewardSum(address _usr) external view returns (uint);
    

}

interface IPoolVoting {
    function addVoting(address _exchange, uint _amount) external;
    function removeVoting(address _exchange, uint _amount) external;
    function claimReward(address _exchange) external;
    function claimRewardAll() external;
    function removeAllVoting()external; 

}

