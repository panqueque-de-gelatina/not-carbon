// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CarbonCreditToken is ERC20 {
    address public admin;

    // Evento para registrar la creación de nuevos tokens
    event TokensMinted(address indexed to, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can execute this function.");
        _;
    }

    constructor() ERC20("CarbonCreditToken", "CCT") {
        admin = msg.sender; // El que despliega el contrato es el admin
    }

    // Función para minar (crear) nuevos tokens
    function mint(address to, uint256 amount) public onlyAdmin {
        _mint(to, amount); // Crea nuevos tokens y los asigna a la dirección `to`
        emit TokensMinted(to, amount);
    }

    // Función para quemar (destruir) tokens
    function burn(uint256 amount) public {
        _burn(msg.sender, amount); // Quema tokens de la dirección que llama la función
    }

    // Función para transferir tokens
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Función para aprobar que otra dirección gaste tokens en nombre del propietario
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // Función para transferir tokens en nombre del propietario
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance(sender, _msgSender()) - amount);
        return true;
    }
}