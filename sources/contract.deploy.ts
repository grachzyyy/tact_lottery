import * as fs from "fs";
import * as path from "path";
import { Address, contractAddress, toNano } from "@ton/core";
import { Lottery } from "./output/sample_Lottery";
import { prepareTactDeployment } from "@tact-lang/deployer";

(async (): Promise<void> => {
    // Parameters
    let testnet = true;
    let packageName = "sample_Lottery.pkg";
    let owner = Address.parse("0QClacqt1G1VQ9sasHogYbaMn0pZJdTKnrZBfYmDXOELmu4E");
    let init = await Lottery.init(
    toNano("1"),        // bid = 1 TON
    toNano("0.5"),      // minPrize = 0.5 TON
    toNano("1.01")      // maxPrize = 1.01 TON 
    );

    // Load required data
    let address = contractAddress(0, init);
    let data = init.data.toBoc();
    let pkg = fs.readFileSync(path.resolve(__dirname, "output", packageName));

    // Prepareing
    console.log("Uploading package...");
    let prepare = await prepareTactDeployment({ pkg, data, testnet });

    // Deploying
    console.log("============================================================================================");
    console.log("Contract Address");
    console.log("============================================================================================");
    console.log();
    console.log(address.toString({ testOnly: testnet }));
    console.log();
    console.log("============================================================================================");
    console.log("Please, follow deployment link");
    console.log("============================================================================================");
    console.log();
    console.log(prepare);
    console.log();
    console.log("============================================================================================");
})();
