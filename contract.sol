// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact contact@mebu.vip
contract MemeBuddha is ERC20, ERC20Burnable, Pausable, Ownable {
    address public charityWallet;
    address public teamWallet;
    mapping (address => bool) public liquidityPools;

    constructor() ERC20("Meme Buddha", "MEBU") {
        _mint(msg.sender, 108000000000 * 10 ** decimals());
    }

    function setCharityWallet(address _charityWallet) public onlyOwner {
        require(_charityWallet != address(0), "Invalid charity wallet address");
        charityWallet = _charityWallet;
    }

    function setTeamWallet(address _teamWallet) public onlyOwner {
        require(_teamWallet != address(0), "Invalid team wallet address");
        teamWallet = _teamWallet;
    }

    function addLiquidityPool(address _liquidityPool) public onlyOwner {
        require(_liquidityPool != address(0), "Invalid liquidity pool address");
        liquidityPools[_liquidityPool] = true;
    }

    function removeLiquidityPool(address _liquidityPool) public onlyOwner {
        require(_liquidityPool != address(0), "Invalid liquidity pool address");
        liquidityPools[_liquidityPool] = false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        if (liquidityPools[to]) {
            uint256 fee = amount * 6 / 100;
            uint256 distributeAmount = fee / 3;
            uint256 amountAfterFee = amount - fee;

            _burn(from, distributeAmount);
            _transfer(from, charityWallet, distributeAmount);
            _transfer(from, teamWallet, distributeAmount);

            // Update the amount being transferred to the liquidity pool
            amount = amountAfterFee;
        }

        super._beforeTokenTransfer(from, to, amount);
    }
}