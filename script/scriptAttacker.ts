import { ChainContext, ContractParser } from "@derivation-tech/web3-core";
import "dotenv/config";
import { Exploiter__factory } from "../typechain-types";

async function main() {
    const ctx = await ChainContext.getInstance("ethereum");
    console.log(ctx.chainName);
    const exploiterAddr = '0x4476b6ca46B28182944ED750e74e2Bb1752f87AE';
    const exploiter = Exploiter__factory.connect(exploiterAddr, ctx.provider);
    const exchangeRate = await exploiter.exchangeRate();
    console.log(exchangeRate.toString());
}

main().catch(console.error);