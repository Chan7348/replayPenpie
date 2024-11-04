// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface Interfaces {
    // PendleYieldContractFactory
    function createYieldContract(
        address SY,
        uint32 expiry,
        bool doCacheIndexSameBlock
    ) external returns (address PT, address YT);

    // PendleMarketFactoryV3
    function createNewMarket(
        address PT,
        int256 scalarRoot,
        int256 initialAnchor,
        uint80 lnFeeRateRoot
    ) external returns (address market);

    // Penpie_PendleMarketRegisterHelper
    function registerPenpiePool(address _market) external;

    // PendleYieldToken
    function mintPY(
        address receiverPT,
        address receiverYT
    ) external returns (uint256 amountPYOut);

    // PendleMarketV3
    function mint(
        address receiver,
        uint256 netSyDesired,
        uint256 netPtDesired
    ) external returns (uint256 netLpOut, uint256 netSyUsed, uint256 netPtUsed);

    function redeemRewards(address user) external returns (uint256[] memory);

    // Penpie_PendleMarketDepositHelper_0x1c1f
    function depositMarket(address _market, uint256 _amount) external;
    function withdrawMarket(address _market, uint256 _amount) external;

    // balancerVault
    function flashLoan(
        address recipient,
        address[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;

    // PenpieStaking_0x6e79
    struct Pool {
        address market;
        address rewarder;
        address helper;
        address receiptToken;
        uint256 lastHarvestTime;
        bool isActive;
    }

    function pools(address) external view returns(Pool memory);

    function batchHarvestMarketRewards(
        address[] calldata _markets,
        uint256 minEthToRecieve
    ) external;

    function harvestMarketReward(
        address _market,
        address _caller,
        uint256 _minEthRecive
    ) external;

    // PendleRouterV4
    enum SwapType {
        NONE,
        KYBERSWAP,
        ONE_INCH,
        ETH_WETH
    }

    struct SwapData {
        SwapType swapType;
        address extRouter;
        bytes extCalldata;
        bool needScale;
    }

    struct TokenInput {
        address tokenIn;
        uint256 netTokenIn;
        address tokenMintSy;
        address pendleSwap;
        SwapData swapData;
    }

    function addLiquiditySingleTokenKeepYt(
        address receiver,
        address market,
        uint256 minLpOut,
        uint256 minYtOut,
        TokenInput calldata input
    ) external payable returns (uint256 netLpOut, uint256 netYtOut, uint256 netSyMintPy, uint256 netSyInterm);

    enum OrderType {
        SY_FOR_PT,
        PT_FOR_SY,
        SY_FOR_YT,
        YT_FOR_SY
    }

    struct Order {
        uint256 salt;
        uint256 expiry;
        uint256 nonce;
        OrderType orderType;
        address token;
        address YT;
        address maker;
        address receiver;
        uint256 makingAmount;
        uint256 lnImpliedRate;
        uint256 failSafeRate;
        bytes permit;
    }

    struct FillOrderParams {
        Order order;
        bytes signature;
        uint256 makingAmount;
    }

    struct LimitOrderData {
        address limitRouter;
        uint256 epsSkipMarket;
        FillOrderParams[] normalFills;
        FillOrderParams[] flashFills;
        bytes optData;
    }
    struct TokenOutput {
        address tokenOut;
        uint256 minTokenOut;
        address tokenRedeemSy;
        address pendleSwap;
        SwapData swapData;
    }

    function removeLiquiditySingleToken(
        address receiver,
        address market,
        uint256 netMarketoRemove,
        TokenOutput calldata output,
        LimitOrderData calldata limit
    ) external returns (uint256 netTokenOut, uint256 netSyFee, uint256 netSyInterm);

    // Penpie_MasterPenpie
    function multiclaim(
        address[] calldata _stakingTokens
    ) external;
}