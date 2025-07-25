// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/ICompanyManager.sol";
import "./interfaces/IProject.sol";
import "./interfaces/ICarbonCreditMarket.sol";
contract Company {
    address public owner;
    string public name;
    uint256 public monthlyEmissions;
    uint256 public carbonCredits;
    bool public approved;

    constructor(address _owner, string memory _name, uint256 _monthlyEmissions) {
        owner = _owner;
        name = _name;
        monthlyEmissions = _monthlyEmissions;
        carbonCredits = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function buyFromProject(address payable projectAddress, uint256 amount) external payable onlyOwner {
        IProject project = IProject(projectAddress);
        project.buyCarbonCredits{value: msg.value}(amount);
    }

    function buyFromMarket(address market, uint256 amount) external payable onlyOwner {
        ICarbonCreditMarket(market).buyFromAny{value: msg.value}(amount);
    }

    function approve() external onlyOwner {
        approved = true;
    }

    function isApproved() external view returns (bool) {
        return approved;
    }
}
