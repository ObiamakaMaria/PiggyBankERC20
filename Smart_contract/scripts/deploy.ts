import { ethers } from "hardhat";


async function main() {
    

    const piggyFactory = await ethers.deployContract("PiggyBankFactory", ["0x536f7190ca407227d16FeeEe7b894dD6301c0871"])
    await piggyFactory.waitForDeployment()

    console.log(" PiggyFactory  Contract Deployed ")
    console.log("Contract Address: ", piggyFactory.target)


}

main().catch((error) => {
    console.error(error)
    process.exit(1)
})