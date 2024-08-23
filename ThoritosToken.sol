// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ThoritosToken is ERC20, Ownable {
    uint8 private _decimals = 8;
    uint256 private _totalSupply = 100000 * (10 ** uint256(_decimals));

    mapping(address => uint256) private _lockedUntil;

    constructor(address initialOwner) ERC20("Thoritos", "THOR") Ownable(msg.sender) {
        _mint(initialOwner, _totalSupply);
        transferOwnership(initialOwner);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }

    function lockTokens(uint256 amount, uint256 time) public {
        require(time > block.timestamp, "Lock time must be in the future");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to lock tokens");
        
        _lockedUntil[msg.sender] = time;
    }

    function getLockedUntil(address account) public view returns (uint256) {
        return _lockedUntil[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(block.timestamp >= _lockedUntil[msg.sender], "Tokens are locked");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(block.timestamp >= _lockedUntil[sender], "Tokens are locked");
        return super.transferFrom(sender, recipient, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}

