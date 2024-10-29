// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "contracts/Exploiter.sol";
import "forge-std/Test.sol";

interface interfaces {
    function assetInfo() external view returns (uint8, address, uint8);
    function exchangeRate() external view returns (uint);
}

contract TTT is Test {
    address PendleYieldContractFactory = 0x35A338522a435D46f77Be32C70E215B813D0e3aC;

    Exploiter exploiter = Exploiter(0x4476b6ca46B28182944ED750e74e2Bb1752f87AE);

    function setUp() public {
        vm.createSelectFork(vm.envString("ETHEREUM_RPC"));
    }

    function test_info() public {
        // console.log("token name:", exploiterSY.name());
        // console.log("token decimals:", exploiterSY.decimals());
        // console.log("symbol:", exploiterSY.symbol());
        vm.startPrank(PendleYieldContractFactory);
        // (uint8 assType, address asset, uint8 symbol) = interfaces(0x4476b6ca46B28182944ED750e74e2Bb1752f87AE).assetInfo();
        // console.log("asset type:", assType);
        // console.log("asset:", asset);
        // console.log("symbol:", symbol);
        uint rate = exploiter.exchangeRate();
        console.log("rate:", rate);
        vm.stopPrank();
    }
}