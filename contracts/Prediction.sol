// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title Prediction
/// @notice This contract facilitates a prediction bet between two parties, based on the price of WBTC in USDC after a certain time period.

import "@api3/contracts/v0.8/interfaces/IProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Interface for the ERC20 standard
interface IERC20 {
    function approve(address spender, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function balanceOf(address holder) external returns (uint256);
}

contract Prediction is Ownable {

        uint256 constant PREDICTION_LENGTH = 7 days;
        uint256 constant PRICE_PREDICTION = 35000;      // 35,000 USD per BTC
        //uint256 constant MIN_USDC = 35000e6;          // 6 decimals  //Proxy Mumbai 0x8DF7d919Fe9e866259BB4D135922c5Bd96AF6A27
        //uint256 constant MIN_WBTC = 1e8;              // 8 decimals  //Proxy Mumbai 0x28Cac6604A8f2471E19c8863E8AfB163aB60186a
        uint256 constant MIN_USDC = 2 ether;            // for simplicity using 2 usdc for every 1 wbtc
        uint256 constant MIN_WBTC = 1 ether;
        uint256 public startBetTimestamp;

        address public proxyAddress;
        address public wbtcDepositor;
        address public usdcDepositor;

        bool public usdcDeposited;
        bool public wbtcDeposited;
        bool public betInitiated;

        IERC20 USDC;
        IERC20 WBTC;

        /// @notice Constructor for the Prediction contract
        /// @param _proxyAddress Address of the proxy contract for data feed
        /// @param _USDC Address of the USDC token contract
        /// @param _WBTC Address of the WBTC token contract
        constructor(address _proxyAddress, address _USDC, address _WBTC) {
            proxyAddress = _proxyAddress;
            USDC = IERC20(_USDC);
            WBTC = IERC20(_WBTC);
        }

        /// @notice Allows the owner of the contract to set the proxy address
        /// @param _proxyAddress The new proxy address
        function setProxyAddress (address _proxyAddress) public onlyOwner {
            proxyAddress = _proxyAddress;
        }

        /// @notice Allows a user to deposit WBTC to the contract
        function depositWBTC() external {
            require(!betInitiated, "Bet already initiated");
            require(!wbtcDeposited, "WBTC already deposited");
            WBTC.transferFrom(msg.sender, address(this), MIN_WBTC);
            wbtcDeposited = true;
            wbtcDepositor = msg.sender;
            if(usdcDeposited){
                startBetTimestamp = block.timestamp;
                betInitiated = true;
            }
        }

        /// @notice Allows a user to deposit USDC to the contract
        function depositUSDC() external {
            require(!betInitiated, "Bet already initiated");
            require(!usdcDeposited, "USDC already deposited");
            USDC.transferFrom(msg.sender, address(this), MIN_USDC);
            usdcDeposited = true;
            usdcDepositor = msg.sender;
            if(wbtcDeposited){
                startBetTimestamp = block.timestamp;
                betInitiated = true;
            }
        }

        /// @notice Allows a user to close the prediction and resolve the bet
        function closePrediction() external {
            require(betInitiated, "Bet not initiated");
            require(block.timestamp >= startBetTimestamp + PREDICTION_LENGTH, "Bet not finished");
            // read data feed
            (uint256 price, uint256 priceTimestamp) = readDataFeed();
            require(priceTimestamp >= (block.timestamp - 3 minutes), "Price Stale");
            //local variable to store winner
            address winner;
            //decide winner
            if (price >= PRICE_PREDICTION) {
                winner = usdcDepositor;
            } else {
                winner = wbtcDepositor;
            }
            uint256 usdcBalance = USDC.balanceOf(address(this));
            uint256 wbtcBalance = WBTC.balanceOf(address(this));
            USDC.transfer(winner, usdcBalance);
            WBTC.transfer(winner, wbtcBalance);
            //reset bet
            betInitiated = false;
            //reset deposits
            usdcDeposited = false;
            wbtcDeposited = false;
            usdcDepositor = address(0);
            wbtcDepositor = address(0);
        }

        /// @notice Allows a user to return funds if the bet has not been initiated
        function returnFunds() external {
            require(betInitiated, "Bet not initiated");
            uint256 usdcBalance = USDC.balanceOf(address(this));
            uint256 wbtcBalance = WBTC.balanceOf(address(this));
            if(usdcDeposited){
                USDC.transfer(usdcDepositor, usdcBalance);
            }
            if(wbtcDeposited){
                WBTC.transfer(wbtcDepositor, wbtcBalance);
            }
            //reset Prediction
            usdcDeposited = false;
            wbtcDeposited = false;
            usdcDepositor = address(0);
            wbtcDepositor = address(0);
        }

        /// @notice Reads the WBTC/USDC price feed from the proxy contract
        /// @return price The current price of WBTC in USDC
        /// @return timestamp The timestamp of the latest price update
        function readDataFeed() public view returns (uint256, uint256){
            (int224 value, uint256 timestamp) = IProxy(proxyAddress).read();
            uint256 price = uint224(value);
            return (price, timestamp);
        }

}
