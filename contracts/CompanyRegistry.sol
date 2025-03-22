// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./RoleManager.sol";

contract CompanyRegistry {
    struct Company {
        string name;
        address wallet;
        uint256 monthlyEmissions;
        bool approved;
        uint256 carbonCredits;
    }

    mapping(address => Company) public companies;
    RoleManager public roleManager; 

    event CompanyRegistered(address indexed company, string name);
    event CompanyApproved(address indexed company);
    event CarbonCreditsAssigned(address indexed company, uint256 amount);

    constructor(address _roleManagerAddress) {
        roleManager = RoleManager(_roleManagerAddress);
    }
    modifier onlyApprover() {
        require(roleManager.isStaffOrAdmin(msg.sender), "No tenes permiso");
        _;
    }


    function registerCompany(string memory _name, uint256 _monthlyEmissions) public {
        require(companies[msg.sender].wallet == address(0), "Empresa ya registrada");
        companies[msg.sender] = Company({
            name: _name,
            wallet: msg.sender,
            monthlyEmissions: _monthlyEmissions,
            approved: false,
            carbonCredits: 0
        });

        emit CompanyRegistered(msg.sender, _name);
    }

    function approveCompany(address _company) public onlyApprover{
        require(companies[_company].wallet != address(0), "Empresa no registrada");
        companies[_company].approved = true;
        emit CompanyApproved(_company);
    }
}
