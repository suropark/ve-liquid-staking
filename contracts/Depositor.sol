// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Interfaces.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

contract Depositor {

    address public constant baseToken;
    address public constant vToken;

    uint256 private constant MAXTIME = 1555200000;

    address private feeManager;
    address private immutable staker;
    address private immutable minter;


       constructor(address _staker, address _minter) public {
        staker = _staker;
        minter = _minter;
        feeManager = msg.sender;
    }
 function _lockCurve() internal {
        uint256 crvBalance = IERC20(baseToken).balanceOf(address(this));
        if(crvBalance > 0){
            IERC20(baseToken).safeTransfer(staker, crvBalance);
        }
        
        //increase ammount
        uint256 crvBalanceStaker = IERC20(crv).balanceOf(staker);
        if(crvBalanceStaker == 0){
            return;
        }
        
        //increase amount
        IStaker(staker).increaseAmount(crvBalanceStaker);
        
 
    }
     function deposit(uint256 _amount, bool _lock, address _stakeAddress) public {
        require(_amount > 0,"!>0");
        
        if(_lock){
            //lock immediately, transfer directly to staker to skip an erc20 transfer
            IERC20(baseToken).safeTransferFrom(msg.sender, staker, _amount);
            _lockCurve();
            if(incentiveCrv > 0){
                //add the incentive tokens here so they can be staked together
                _amount = _amount.add(incentiveCrv);
                incentiveCrv = 0;
            }
        }else{
            //move tokens here
            IERC20(crv).safeTransferFrom(msg.sender, address(this), _amount);
            //defer lock cost to another user
            uint256 callIncentive = _amount.mul(lockIncentive).div(FEE_DENOMINATOR);
            _amount = _amount.sub(callIncentive);

            //add to a pool for lock caller
            incentiveCrv = incentiveCrv.add(callIncentive);
        }

        bool depositOnly = _stakeAddress == address(0);
        if(depositOnly){
            //mint for msg.sender
            ITokenMinter(minter).mint(msg.sender,_amount);
        }else{
            //mint here 
            ITokenMinter(minter).mint(address(this),_amount);
            //stake for msg.sender
            IERC20(minter).safeApprove(_stakeAddress,0);
            IERC20(minter).safeApprove(_stakeAddress,_amount);
            IRewards(_stakeAddress).stakeFor(msg.sender,_amount);
        }
    }

    function deposit(uint256 _amount, bool _lock) external {
        deposit(_amount,_lock,address(0));
    }

    function depositAll(bool _lock, address _stakeAddress) external{
        uint256 crvBal = IERC20(crv).balanceOf(msg.sender);
        deposit(crvBal,_lock,_stakeAddress);
    }
}