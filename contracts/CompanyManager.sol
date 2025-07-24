// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IRoleManager.sol";
import "./Company.sol";
contract CompanyManager {
    struct CompanyInfo {
        string name;
        address contractAddress;
        uint256 monthlyEmissions;
        bool approved;
    }

    mapping(address => CompanyInfo) public companies;
    address[] public companyList;
    IRoleManager public roleManager;

    event CompanyCreated(address indexed owner, address companyContract, string name);
    event CompanyApproved(address indexed companyContract);

    modifier onlyApprover() {
        require(roleManager.isStaffOrAdmin(msg.sender), "No tenes permiso");
        _;
    }

    constructor(address _roleManagerAddress) {
        roleManager = IRoleManager(_roleManagerAddress);
    }

    function createCompany(string memory _name, uint256 _monthlyEmissions) public {
        require(companies[msg.sender].contractAddress == address(0), "Empresa ya registrada");

        Company company = new Company(msg.sender, _name, _monthlyEmissions);
        address contractAddr = address(company);

        companies[msg.sender] = CompanyInfo({
            name: _name,
            contractAddress: contractAddr,
            monthlyEmissions: _monthlyEmissions,
            approved: false
        });

        companyList.push(contractAddr);
        emit CompanyCreated(msg.sender, contractAddr, _name);
    }

    function approveCompany(address _owner) public onlyApprover {
        require(companies[_owner].contractAddress != address(0), "Empresa no registrada");
        companies[_owner].approved = true;
        emit CompanyApproved(companies[_owner].contractAddress);
    }

    function isApproved(address _owner) external view returns (bool) {
        return companies[_owner].approved;
    }

    function getAllCompanies() public view returns (address[] memory) {
        return companyList;
    }

    function getCompanyContract(address _owner) public view returns (address) {
        return companies[_owner].contractAddress;
    }
}
