// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./GST.sol";
// import "./dummyErc.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UtilitySale is Ownable {
    address payable admin;
    uint256 public saleStart = block.timestamp;
    uint256 public saleEnd = block.timestamp + 604800; //one week

    //

    uint256 private saleStartTime;
    uint256 private saleEndTime;
    uint256 private saleId = 0;
    //
    address public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokenSold;
    bool saleEnded; // can be ended

    enum State {
        // ICO states
        beforeStart,
        running,
        halted,
        afterEnd
        
    }
    State public icoState;

    event sale(address _buyer, uint256 _amount);

    constructor(address _tokenContract, uint256 _tokenPrice) {
        admin == payable(msg.sender);
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
        icoState = State.beforeStart;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier CheckSale() {
        require(saleEnded == false, "sale is ended");
        // require(saleStartTime < block.timestamp, "Sale not started");
        // require(saleEndTime > block.timestamp, "Sale Ended");
        if(saleEndTime > block.timestamp){
            require(saleEnded == true, "public sale is not active");
        }
        _;
    }

    function buyTokens(uint256 _numberOfTokens) public payable CheckSale
     
    {
        //for checking ico state
        icoState = getCurrentState();
        require(icoState == State.running);

        require(msg.value == (_numberOfTokens * tokenPrice), "msg.value error"); //20 tokens *2 wth ---> 40eth
        // tokenContract.approve(msg.sender, _numberOfTokens);
        IERC20(tokenContract).transferFrom(owner(), msg.sender,(_numberOfTokens * (10**18)) ); // tokens is tranfered from  the admin account
        tokenSold += (_numberOfTokens * (10**18));

        emit sale(msg.sender, _numberOfTokens);
    }

    function buyWhiteListUser(uint256 _numberOfTokens)
        public
        payable
        checkSaleValidations(msg.sender, msg.value)
        isWhitelisted(msg.sender)
    {
        //for checking ico state
        icoState = getCurrentState();
        require(icoState == State.running);

        require(msg.value == (_numberOfTokens * tokenPrice), "msg.value error"); //20 tokens *2 wth ---> 40eth
        // tokenContract.approve(msg.sender, _numberOfTokens);
        IERC20(tokenContract).transferFrom(
            owner(),
            msg.sender,
            (_numberOfTokens * (10**18))
        ); // tokens is tranfered from  the admin account
        tokenSold += (_numberOfTokens * (10**18));

        emit sale(msg.sender, _numberOfTokens);
    }

    // modifier checkPublicSale(address _userAddress, uint256 _value) {
    //     require(saleStartTime < block.timestamp, "Sale not started");
    //     require(saleEndTime > block.timestamp, "Sale Ended");
    //     _;
    // }
    modifier checkSaleValidations (address _userAddress, uint256 _value) {
        // require(saleEnded == false, "sale is ended");
        require(saleStartTime < block.timestamp, "Sale not started");
        require(saleEndTime > block.timestamp, "Sale  Ended");
      
        _;
    }

    // function saleWhiteListUser(uint256 _startTime, uint256 _endTime)
    //     external
    //     onlyOwner
    //     returns (bool)
    // {
    //     saleStartTime = _startTime;
    //     saleEndTime = _endTime;
    //     saleId = saleId + 1;
    //     return true;
    // }

    function setSaleParameter(uint256 _startTime, uint256 _endTime)
        external
        onlyOwner
        returns (bool)
    {
        saleStartTime = _startTime;
        saleEndTime = _endTime;
        saleId = saleId + 1;
        return true;
    }

    // emergency stop
    function stop() public onlyAdmin {
        icoState = State.halted;
    }

    // resume ICO after stop
    function resume() public onlyAdmin {
        icoState = State.running;
    }

    //for ico state
    function getCurrentState() public view returns (State) {
        if (icoState == State.halted) {
            return State.halted;
        } else if (block.timestamp < saleStart) {
            return State.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.running;
        } else {
            return State.afterEnd;
        }
    }

    function endSale() public {
        // require admin
        // tranfer remaining token to the admin
        //destroy contract
        require(msg.sender == admin);
        saleEnded = true;

        payable(admin).transfer((address(this)).balance); // send it to the admin wallet
    }

    // white listing  function
    //white listing
    mapping(address => bool) whitelistedAddresses;

    // add white list user
    function addUser(address _addressToWhitelist) public onlyOwner {
        whitelistedAddresses[_addressToWhitelist] = true;
    }

    function verifyUser(address _whitelistedAddress)
        public
        view
        returns (bool)
    {
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
        return userIsWhitelisted;
    }

    modifier isWhitelisted(address _address) {
        require(whitelistedAddresses[_address], "You need to be whitelisted");
        _;
    }

    function exampleFunction()
        public
        view
        isWhitelisted(msg.sender)
        returns (bool)
    {
        return (true);
    }
}
