// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
            address from,
            address to,
            uint256 amount
        ) external returns (bool);
}

contract Staking {

        uint256 public  yieldRate = 42; // % APY
        address internal _owner;
        address public yieldTokenAddress;
        address public stakeTokenAddress;
        struct Farmers {
           uint256 money;
           uint256 timestamp;
        }
        mapping(address => Farmers) public farmers;
        
        constructor(address _StakeToken, address _YieldToken ) {
            _owner = msg.sender;
            stakeTokenAddress = _YieldToken;    
            yieldTokenAddress = _StakeToken;
        }

        IERC20 public StakeToken =  IERC20(stakeTokenAddress);
        IERC20 public YieldToken =  IERC20(yieldTokenAddress);

        modifier onlyOwner() {
            require(_owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

        function deposit(uint256 amount) public {
            address user = msg.sender;
            if (getUserYield(user) > 0) {
                 claimTokens();
            }
            StakeToken.transferFrom(msg.sender, address(this), amount);
            farmers[user].timestamp = block.timestamp;
            farmers[user].money += amount; 
        }
  
        function claimTokens() public {
            YieldToken.transfer(msg.sender,  getUserYield(msg.sender));
        }

        function unstake() public {
            address user = msg.sender;
            StakeToken.transfer(user, farmers[user].money);
            claimTokens();
        }

        function getUserYield(address user)  public view returns (uint256) {
              return (block.timestamp - farmers[user].timestamp) * farmers[user].money * yieldRate / (100*3600*24*365);
        }

        function setYieldRate(uint256  _yieldRate) public onlyOwner {
            yieldRate = _yieldRate;
        }

        function withdraw() external onlyOwner {
              YieldToken.transfer(msg.sender, YieldToken.balanceOf(address(this)));
        }

}