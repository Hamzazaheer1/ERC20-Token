// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ERC20 {
    uint256 public totalSupply;
    string public name;
    string public symbol;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        _mint(msg.sender, 100e18);
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    // Transfer tokens from the sender to the recipient
    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        uint256 currentAllowance = allowance[sender][msg.sender];

        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        allowance[sender][msg.sender] = currentAllowance - amount;

        emit Approval(sender, msg.sender, allowance[sender][msg.sender]);

        return _transfer(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function redeem(uint256 amount) external {
        require(amount > 0, "ERC20: cannot redeem 0");

        // Transfer tokens from sender to this contract
        uint256 currentAllowance = allowance[msg.sender][address(this)];
        require(currentAllowance >= amount, "ERC20: redeem amount exceeds allowance");

        allowance[msg.sender][address(this)] = currentAllowance - amount;
        emit Approval(msg.sender, address(this), allowance[msg.sender][address(this)]);

        require(_transfer(msg.sender, address(this), amount), "ERC20: transfer failed");


        // Burn the tokens
        _burn(address(this), amount);

        // Transfer Ether back to sender
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ERC20: ETH transfer failed");
    }

    function _burn(address from, uint256 amount) private {
        require(from != address(0), "ERC20: burn from the zero address");

        uint256 balance = balanceOf[from];
        require(balance >= amount, "ERC20: burn amount exceeds balance");

        balanceOf[from] = balance - amount;
        totalSupply -= amount;

        emit Transfer(from, address(0), amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = balanceOf[sender];
       
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        balanceOf[sender] = senderBalance - amount;
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        return true;
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "ERC20: mint to the zero address");

        totalSupply += amount;
        balanceOf[to] += amount;
        
        emit Transfer(address(0), to, amount);
    }
}