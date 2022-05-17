// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IvMesh {
    function lockMESH(uint256 _amount, uint256 _period) external; // 1555200000 is Max Period (8x)
    function claimReward() external;

}

interface IPoolVoting {
    function addVoting(address _exchange, uint _amount) external;
    function removeVoting(address _exchange, uint _amount) external;
    function claimReward(address _exchange) external;
    function claimRewardAll() external;
}

