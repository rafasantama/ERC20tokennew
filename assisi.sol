// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract ASISI is ERC20 {
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner
    ) ERC20(name, symbol) {
        _mint(owner, initialSupply);
    }
    function crear_tokens (uint _cantidad) public{
        require(msg.sender==owner,"Solo el owner puede crear humus!!!");
        _mint(owner,_cantidad);
    }
    function quemar_tokens(uint _cantidad) public{
        require(msg.sender==owner,"Solo el owner puede crear humus!!!");
        _burn(owner,_cantidad);
    }
}