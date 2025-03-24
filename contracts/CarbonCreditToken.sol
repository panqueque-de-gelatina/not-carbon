// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CarbonCreditToken is ERC20 {
    address public admin;
    address public project_manager;

    // Evento para registrar la creación de nuevos tokens
    event TokensMinted(address indexed to, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can execute this function.");
        _;
    }
    modifier onlyProjectManager() {
        require(msg.sender == project_manager, "Only the project manager can execute this function.");
        _;
    }

    constructor(address projectManager) ERC20("CarbonCreditToken", "CCT") {
        admin = msg.sender; 
        project_manager = projectManager;
    }

    // Función para minar (crear) nuevos tokens y asignarlos al contrato
    function mint(uint256 amount) public onlyAdmin {
        _mint(address(this), amount); 
        emit TokensMinted(address(this), amount);
    }

    // Función para transferir tokens desde el contrato a otra dirección
    function transferTokens(address recipient, uint256 amount) public onlyProjectManager {
        require(balanceOf(address(this)) >= amount, "Insufficient token balance in contract");
        _transfer(address(this), recipient, amount);
    }

    // Función para quemar (destruir) tokens
    function burn(uint256 amount) public {
        _burn(msg.sender, amount); // Quema tokens de la dirección que llama la función
    }
}