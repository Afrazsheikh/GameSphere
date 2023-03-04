// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// interface ERC20Interface {
//     function totalSupply() external view returns (uint);
//     function balanceOf(address tokenOwner) external view returns (uint balance);
//     function transfer(address to, uint tokens) external returns (bool success);
    
//     function allowance(address tokenOwner, address spender) external view returns (uint remaining);
//     function approve(address spender, uint tokens) external returns (bool success);
//     function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
//     event Transfer(address indexed from, address indexed to, uint tokens);
//     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
// }
 
 
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract UtilityToken is Context, Ownable, ERC20 {
    // admin address
    address private admin;
    // set max circulation of tokens: 100000000000000000000
    uint256 private _maxSupply = 100 * (10**uint256(decimals()));
    uint256 private _unit = 10**uint256(decimals());

    // only admin account can unlock escrow
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can mint tokens.");
        _;
    }

    /**
     * @dev Returns max supply of the token.
     */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev Returns single unit of account.
     */
    function unit() public view returns (uint256) {
        return _unit;
    }

    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        admin = msg.sender;
        // init circulation
        mint();
    }

    function mint() public onlyAdmin {
        _mint(msg.sender, _maxSupply);
    }

    // player must approve allowance for escrow/P2EGame contract to use (spender)
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        amount = _maxSupply; // <-- 100 by default which is max supply
        // amount = max possible to allow for better player UX (don't have to approve every time)
        // in-game this means UX doesn't need to include call to approve each play, but will need to check/read allowance
        // TODO: player approves only amount needed each play
        _approve(owner, spender, amount);
        return true;
    }
}
//  contract UtilityToken is  ERC20Interface {
//     string public name = "GST Token";
//     string public symbol = "GST";
//     uint public decimals = 18;
//     uint public override totalSupply;
    
//     address public founder;
//     mapping(address => uint) public balances;
//     // balances[0x1111...] = 100;
    
//     mapping(address => mapping(address => uint)) allowed;
//     // allowed[0x111][0x222] = 100;
    
    
//     constructor(){
//         totalSupply = 1000000000;
//         founder = msg.sender;
//         balances[founder] = totalSupply;
//     }
    
    
//     function balanceOf(address tokenOwner) public view override returns (uint balance){
//         return balances[tokenOwner];
//     }
    
    
//     function transfer(address to, uint tokens) public virtual override returns(bool success){
//         require(balances[msg.sender] >= tokens);
        
//         balances[to] += tokens;
//         balances[msg.sender] -= tokens;
//         emit Transfer(msg.sender, to, tokens);
        
//         return true;
//     }
    
    
//     function allowance(address tokenOwner, address spender) public view override returns(uint){
//         return allowed[tokenOwner][spender];
//     }
    
    
//     function approve(address spender, uint tokens) public override returns (bool success){
//         require(balances[msg.sender] >= tokens);
//         require(tokens > 0);
        
//         allowed[msg.sender][spender] = tokens;
        
//         emit Approval(msg.sender, spender, tokens);
//         return true;
//     }
    
    
//     function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success){
//          require(allowed[from][to] >= tokens);
//          require(balances[from] >= tokens);
         
//          balances[from] -= tokens;
//          balances[to] += tokens;
//          allowed[from][to] -= tokens;
         
//          return true;
//      }
// }
 

