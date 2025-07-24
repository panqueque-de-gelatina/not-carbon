// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Project.sol";
import "./CarbonCreditToken.sol";
import "./interfaces/IRoleManager.sol";
contract ProjectManager {
    address public admin;
    mapping(address => bool) public approvers;
    mapping(address => bool) public registeredProjects;
    uint256 pricePerToken;
    IRoleManager public roleManager;
    event ProjectRegistered(address indexed projectAddress, string name, string description, address creator);
    event ProjectStateUpdated(address indexed projectAddress, Project.ProjectState newState);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can execute this function.");
        _;
    }

    constructor(address _roleManager) {
        admin = msg.sender;
        roleManager = IRoleManager(_roleManager);
    }

    function registerProject(
        string memory _name,
        string memory _description,
        address _carbonCreditTokenAddress,
        uint256 _totalTokens
    ) public returns (address) {
        Project newProject = new Project(
            _name,
            _description,
            _carbonCreditTokenAddress,
            _totalTokens,
            msg.sender ,
            pricePerToken
        );
        address projectAddress = address(newProject);
        registeredProjects[projectAddress] = true;

        CarbonCreditToken token = CarbonCreditToken(_carbonCreditTokenAddress);
        token.transferTokens(projectAddress, _totalTokens);

        emit ProjectRegistered(projectAddress, _name, _description, msg.sender);
        return projectAddress;
    }


    function updateProjectStatus(address _projectAddress, Project.ProjectState _newState) public {
        require(roleManager.isStaffOrAdmin(msg.sender), "Only staff or admin can update project status.");
        require(registeredProjects[_projectAddress], "Project is not registered.");
        Project project = Project(_projectAddress);
        project.updateState(_newState);
        emit ProjectStateUpdated(_projectAddress, _newState);
    }

    function isProjectRegistered(address _projectAddress) public view returns (bool) {
        return registeredProjects[_projectAddress];
    }

    function setPricePerToken(uint256 _price) public {
        require(roleManager.isStaffOrAdmin(msg.sender), "Only staff or admin can set the price per token.");
        pricePerToken = _price;
    }
}