const { expect } = require('chai'); 
const { ethers } = require ('hardhat'); 

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}
describe ('Exchange', () => {
    let deployer, feeAccount, exchange //feeAccount - gets fees from the exchange
    
    const feePercent = 10 //% fee per transaction

    beforeEach(async () => {
        accounts = await ethers.getSigners()
        deployer = accounts[0]
        feeAccount = accounts[1]

        const Exchange = await ethers.getContractFactory('Exchange')
        exchange = await Exchange.deploy(feeAccount.address, feePercent)
    })
    
    describe ('Deployment', () => {
       
        it('- tracks the Fee Account', async () => { 
            expect(await exchange.feeAccount()).to.equal(feeAccount.address)
        })

        it('- tracks the Fee Percent', async () => { 
            expect(await exchange.feePercent()).to.equal(feePercent)
        })
    })
})
