// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PiggyBank {
    uint256 public constant SAVINGS_DURATION = 365 * 24 * 60 * 60;
    uint256 public constant TOKEN_DECIMAL = 6;
    
    address public immutable owner; 
    address public immutable developersAddress; 
    
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    
    
    struct TokenData {
        uint256 balance;
        uint256 depositTime;
        bool isWithdrawn;
    }
    
    
    TokenData public usdcData;
    TokenData public usdtData;
    TokenData public daiData;
    
    string public savingPurpose;
    
    
    event Deposit(address tokenAddress, uint256 amount);
    event Withdrawal(address tokenAddress, uint256 amount);
    event DevelopersInterestPaid(address developersAddress, uint256 developersPercentage);
    
    
    error ZeroAddress();
    error InsufficientBalance();
    error TokenNotAccepted();
    error AlreadyWithdrawn();
    error NotOwner();
    error TransferFailed();
    
    constructor(address _developersAddress, string memory _savingPurpose) {
        if(_developersAddress == address(0)) revert ZeroAddress();
        developersAddress = _developersAddress;
        owner = msg.sender; 
        savingPurpose = _savingPurpose;
    }
    
    
    function getTokenData(address _tokenAddress) internal view returns (TokenData storage) {
        if(_tokenAddress == USDC) return usdcData;
        if(_tokenAddress == USDT) return usdtData;
        if(_tokenAddress == DAI) return daiData;
        revert TokenNotAccepted();
    }
    
    
    function saveToken(address _tokenAddress, uint256 _amount) external {
        if(msg.sender != owner) revert NotOwner();
        if(_tokenAddress == address(0)) revert ZeroAddress();
        if(_amount <= 0) revert InsufficientBalance();
        
        
        TokenData storage tokenData = getTokenData(_tokenAddress);
        
        IERC20 token = IERC20(_tokenAddress);
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        if(!success) revert TransferFailed();
        
        
        tokenData.balance += _amount;
        
        if(tokenData.depositTime == 0) {
            tokenData.depositTime = block.timestamp;
        }
        
        emit Deposit(_tokenAddress, _amount);
    }
    
    
    function withdrawSavings(address _tokenAddress) external returns(bool) {
        if(msg.sender != owner) revert NotOwner();
        if(_tokenAddress == address(0)) revert ZeroAddress();
        
        TokenData storage tokenData = getTokenData(_tokenAddress);
        
        if(tokenData.isWithdrawn) revert AlreadyWithdrawn();
        if(tokenData.balance == 0) revert InsufficientBalance();
        
        IERC20 token = IERC20(_tokenAddress);
        uint256 totalAmount = tokenData.balance;
        uint256 timeElapsed = block.timestamp - tokenData.depositTime;
        
        tokenData.isWithdrawn = true;
        tokenData.balance = 0;
        
        if(timeElapsed >= SAVINGS_DURATION) {
            
            bool success = token.transfer(owner, totalAmount);
            if(!success) revert TransferFailed();
            
            emit Withdrawal(_tokenAddress, totalAmount);
        } else {

            uint256 developersInterest = (totalAmount * 15 * 10**TOKEN_DECIMAL) / (100 * 10**TOKEN_DECIMAL);
            uint256 userAmount = totalAmount - developersInterest;
            
            
            bool devTransferSuccess = token.transfer(developersAddress, developersInterest);
            if(!devTransferSuccess) revert TransferFailed();
            emit DevelopersInterestPaid(developersAddress, developersInterest);
            
            
            bool userTransferSuccess = token.transfer(owner, userAmount);
            if(!userTransferSuccess) revert TransferFailed();
            emit Withdrawal(_tokenAddress, userAmount);
        }
        
        return true;
    }
    
    
    function getBalance(address _tokenAddress) external view returns(uint256) {
        TokenData storage tokenData = getTokenData(_tokenAddress);
        return tokenData.balance;
    }
    
  
    function getTimeRemaining(address _tokenAddress) external view returns(uint256) {
        TokenData storage tokenData = getTokenData(_tokenAddress);
        
        if(tokenData.depositTime == 0) return 0;
        
        uint256 timeElapsed = block.timestamp - tokenData.depositTime;
        if(timeElapsed >= SAVINGS_DURATION) return 0;
        
        return SAVINGS_DURATION - timeElapsed;
    }
}