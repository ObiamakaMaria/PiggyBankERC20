// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;
import "./PiggyBank.sol";

contract PiggyBankFactory {
    
    uint256 private piggyBankCounter;
    
    
    address public immutable developersAddress;
    
    address[] public deployedPiggyBanks;
    
    mapping(address => address) public ownerToPiggyBank;
    
    
    event PiggyBankCreated(address indexed owner, address piggyBankAddress, bytes32 salt);
    

    error ZeroAddress();
    error CreationFailed();
    error PiggyBankAlreadyExists();
    error InvalidIndex();
    error EmptyBatch();
    error ContractCreationFailed();
    
    constructor(address _developersAddress) {
        if(_developersAddress == address(0)) revert ZeroAddress();
        developersAddress = _developersAddress;
        piggyBankCounter = 0;
    }
    
    function createPiggyBank(string memory purpose) external returns (address) {
        if(msg.sender == address(0)) revert ZeroAddress();
        if(ownerToPiggyBank[msg.sender] != address(0)) revert PiggyBankAlreadyExists();
        
        
        piggyBankCounter++;
        
        
        bytes32 salt = bytes32(piggyBankCounter);
        
        
        bytes memory bytecode = abi.encodePacked(
            type(PiggyBank).creationCode,
            abi.encode(developersAddress, purpose)
        );
        
        address piggyBankAddress;
        assembly {
            piggyBankAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
            if iszero(extcodesize(piggyBankAddress)) {
                revert(0, 0)
            }
        }
        
        if(piggyBankAddress == address(0)) revert ContractCreationFailed();
        
       
        deployedPiggyBanks.push(piggyBankAddress);
        ownerToPiggyBank[msg.sender] = piggyBankAddress;
        
        emit PiggyBankCreated(msg.sender, piggyBankAddress, salt);
        return piggyBankAddress;
    }
    
    
    function createPiggyBankWithSalt(string memory purpose, bytes32 salt) external returns (address) {
        if(msg.sender == address(0)) revert ZeroAddress();
        if(ownerToPiggyBank[msg.sender] != address(0)) revert PiggyBankAlreadyExists();
        
     
        bytes memory bytecode = abi.encodePacked(
            type(PiggyBank).creationCode,
            abi.encode(developersAddress, purpose)
        );
        
        address piggyBankAddress;
        assembly {
            piggyBankAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
            if iszero(extcodesize(piggyBankAddress)) {
                revert(0, 0)
            }
        }
        
        if(piggyBankAddress == address(0)) revert ContractCreationFailed();
        
        
        deployedPiggyBanks.push(piggyBankAddress);
        ownerToPiggyBank[msg.sender] = piggyBankAddress;
        
        emit PiggyBankCreated(msg.sender, piggyBankAddress, salt);
        return piggyBankAddress;
    }
    
   
    function calculatePiggyBankAddress(string memory purpose, bytes32 salt) external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(PiggyBank).creationCode,
            abi.encode(developersAddress, purpose)
        );
        
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );
        
        return address(uint160(uint256(hash)));
    }
    
    
    function getCurrentCounter() external view returns (uint256) {
        return piggyBankCounter;
    }
    
    
    function getTotalPiggyBanks() external view returns (uint256) {
        return deployedPiggyBanks.length;
    }
    
   
    
  
    function getUserPiggyBank(address user) external view returns (address) {
        return ownerToPiggyBank[user];
    }
}