// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICarbonCreditToken {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Project {
    address public owner;
    address public creator;
    string public projectName;
    string public projectDescription;
    
    enum ProjectState { Phase0, Phase1, Phase2, Phase3, Phase4 }
    ProjectState public currentState;
    
    address public carbonCreditTokenAddress;
    uint256 public totalTokens; 
    uint256 public releasedTokens; 
    
    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
    event StateChanged(ProjectState newState);
    event TokensPurchased(address indexed buyer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this function.");
        _;
    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator can execute this function.");
        _;
    }

    constructor(
        string memory _name,
        string memory _description,
        address _carbonCreditTokenAddress,
        uint256 _totalTokens,
        address _creator
    ) {
        owner = msg.sender;
        projectName = _name;
        projectDescription = _description;
        currentState = ProjectState.Phase0;
        carbonCreditTokenAddress = _carbonCreditTokenAddress;
        totalTokens = _totalTokens;
        releasedTokens = 0; 
        creator = _creator;
    }

    function updateState(ProjectState _newState) external {
        require(msg.sender == owner, "Only the owner (ProjectManager) can update the state.");
        require(uint(_newState) > uint(currentState), "New state must be a higher phase.");
        currentState = _newState;
        emit StateChanged(_newState);
    }

    function getCreator() public view returns(address) {
        return creator; 
    }

    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public onlyCreator {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(creator).transfer(_amount);
        emit Withdrawal(creator, _amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getReleasedTokens() public view returns (uint256) {
        if (currentState == ProjectState.Phase0) {
            return 0;
        }
        else if (currentState == ProjectState.Phase1) {
            return (totalTokens * 10) / 100; 
        } else if (currentState == ProjectState.Phase2) {
            return (totalTokens * 40) / 100;
        } else if (currentState == ProjectState.Phase3) {
            return (totalTokens * 60) / 100; 
        } else if (currentState == ProjectState.Phase4) {
            return totalTokens; 
        }
        return 0;
    }

    function buyCarbonCredits(uint256 _amount) public {
        ICarbonCreditToken token = ICarbonCreditToken(carbonCreditTokenAddress);
        
        uint256 availableTokens = getReleasedTokens() - releasedTokens;
        require(_amount <= availableTokens, "Amount exceeds available tokens for this phase");
        
        require(token.balanceOf(address(this)) >= _amount, "Insufficient token balance");
        
        require(token.transfer(msg.sender, _amount), "Token transfer failed");
        
        releasedTokens += _amount;
        
        emit TokensPurchased(msg.sender, _amount);
    }
}