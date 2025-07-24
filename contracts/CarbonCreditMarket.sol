// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ProjectManager.sol";
import "./interfaces/ICompanyManager.sol";
import "./interfaces/IProject.sol";

contract CarbonCreditMarket {
    ProjectManager public projectManager;
    ICompanyManager public companyManager;

    constructor(address _pm, address _cm) {
        projectManager = ProjectManager(_pm);
        companyManager = ICompanyManager(_cm);
    }

    function buyFromAny(uint256 totalAmount) public payable {
        require(companyManager.isApproved(msg.sender), "Company not approved");

        uint256 remaining = totalAmount;
        uint256 totalSpent = 0;

        address[] memory projects = projectManager.getAllProjects(); 

        for (uint i = 0; i < projects.length && remaining > 0; i++) {
            IProject p = IProject(projects[i]);
            uint256 available = p.getReleasedTokens() - p.releasedTokens();

            if (available > 0) {
                uint256 toBuy = available >= remaining ? remaining : available;
                uint256 cost = toBuy * p.pricePerToken();

                require(msg.value >= totalSpent + cost, "Insufficient ETH");

                p.buyFor{value: cost}(msg.sender, toBuy);

                remaining -= toBuy;
                totalSpent += cost;
            }
        }
        require(remaining == 0, "Could not complete purchase with available projects");

        if (msg.value > totalSpent) {
            payable(msg.sender).transfer(msg.value - totalSpent);
        }
    }
}
