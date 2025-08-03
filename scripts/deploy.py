import os
from dotenv import load_dotenv

from brownie import (
    RoleManager,
    CompanyManager, 
    CarbonCreditToken,  
    CarbonCreditMarket,
    ProjectManager,
    Project,
    accounts,
    network
)


def main():
    deployer = accounts.load("admin") 
    roleManager = RoleManager.deploy({'from': deployer})
    companyManager = CompanyManager.deploy(roleManager.address, {'from': deployer})
    projectManager = ProjectManager.deploy(roleManager.address, companyManager.address, {'from': deployer})
    carbonToken = CarbonCreditToken.deploy(projectManager.address, roleManager.address, {'from': deployer})
    print(f"Deployed RoleManager at {roleManager.address}")
    print(f"Deployed ProjectManager at {projectManager.address}")
    print(f"Deployed CompanyManager at {companyManager.address}")
    print(f"Deployed CarbonCreditToken at {carbonToken.address}")
    projectManager.setPricePerToken(100, {'from': deployer}) 
    carbonToken.mint(10000, {'from': deployer})  
    projectAddress = projectManager.registerProject(
        "Test Project",
        "This is a test project",
        carbonToken.address,
        1000,
        {'from': deployer}
    )
    project = Project.at(projectAddress)
    print(f"Project created at {project.address}")

def deploy_carbon_market():
    load_dotenv()
    deployer = accounts.load("admin")
    companyManager = CompanyManager.at(os.getenv("COMPANY_MANAGER_ADDRESS"))
    projectManager = ProjectManager.at(os.getenv("PROJECT_MANAGER_ADDRESS"))
    carbonMarket = CarbonCreditMarket.deploy(
        projectManager.address,
        companyManager.address,
        {'from': deployer}
    )
    print(f"Deployed ProjectManager at {projectManager.address}")
    print(f"Deployed CompanyManager at {companyManager.address}")
    print(f"Deployed CarbonCreditMarket at {carbonMarket.address}")