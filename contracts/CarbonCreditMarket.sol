// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ProjectManager.sol";
import "./interfaces/ICompanyManager.sol";
import "./interfaces/IProject.sol";

contract CarbonCreditMarket {
    ProjectManager public projectManager;
    ICompanyManager public companyManager;

    constructor(address _projectManager, address _companyManager) {
        projectManager = ProjectManager(_projectManager);
        companyManager = ICompanyManager(_companyManager);
    }

    function buyFromAny(uint256 totalAmount, address payable buyer) public payable {
        require(companyManager.isApproved(buyer), "Company not approved");

        uint256 remaining = totalAmount;
        uint256 totalSpent = 0;

        address[] memory projects = projectManager.getAllProjects(); 

        for (uint i = 0; i < projects.length && remaining > 0; i++) {
            IProject p = IProject(projects[i]);

            uint256 available = p.getAvailableTokens();

            if (available > 0) {
                uint256 toBuy = available >= remaining ? remaining : available;
                uint256 cost = toBuy * p.pricePerToken();

                require(msg.value >= totalSpent + cost, "Insufficient ETH");

                p.buyFor{value: cost}(buyer, toBuy);

                remaining -= toBuy;
                totalSpent += cost;
            }
        }
        require(remaining == 0, "Could not complete purchase with available projects");

        if (msg.value > totalSpent) {
            payable(buyer).transfer(msg.value - totalSpent);
        }
    }
}
