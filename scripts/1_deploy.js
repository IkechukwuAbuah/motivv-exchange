async function main() {
    //Fetch contract to deploy
    const Token = await ethers.getContractFactory("Token")

    //Deploy the contract
   const token = await Token.deploy()
   await token.deployed()
   console.log(`Token Deployed to: ${token.address}`) //log token address to the console
  }
  
  //here is where main is called. Reccomended pattern. Helps catch errors
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  