from brownie import Project
def verify():
    project = Project.at("0x8a4b579bda0b552E7Ee9dAB9134B4D4e33da7983")
    Project.publish_source(project)