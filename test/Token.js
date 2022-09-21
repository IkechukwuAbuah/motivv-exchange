const { expect } = require('chai'); //pull expect function from chai library
const { ethers } = require ('hardhat'); //pull ethers library from hardhat library

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}
describe ('Token', () => {//All tests go inside here..
    let token, accounts, deployer, receiver
    
    beforeEach(async () => {

        const Token = await ethers.getContractFactory('Token')
        token = await Token.deploy('Dapp University', 'DAPP','1000000')

        accounts = await ethers.getSigners() //gets all accounts - will return array
        deployer = accounts[0] //will get the first value in the array [0]
        receiver = accounts[1] 
    })

    describe ('Deployment', () => { //Test for deployment
        const name = 'Dapp University'
        const symbol = 'DAPP'
        const decimals = '18'
        const totalSupply = tokens('1000000')


        it('- has correct name', async () => { //Name
            //Read token name & check for correctnes
            expect(await token.name()).to.equal(name)
        })
    
    
        it('- has correct symbol', async () => { //Symbol
            //Read token sybol & check for correctness
            expect(await token.symbol()).to.equal(symbol)
        })
    
    
        it('- has correct decimals', async () => { //decimals
            //Read token symbol & check for correctness
            expect(await token.decimals()).to.equal(decimals)
        })
    
    
        it('- has correct total Supply', async () => {  //Read token total supply & check for correctness
            expect(await token.totalSupply()).to.equal(totalSupply)
        })


        it('- assigns total supply to deployer', async () => {  //Read token total supply & check for correctness
            expect(await token.balanceOf(deployer.address)).to.equal(totalSupply)
        })
    })

    //Describe Spending
    describe('Sending Tokens', () => {
        let amount, transaction, result//amount to be tranfered between deployer and receiver. Derived from "token"
        
        describe('Success', ()=> {

            beforeEach(async() => {
                amount = tokens(100)
                //Transfer tokens
                transaction = await token.connect(deployer).transfer(receiver.address, amount) // connects deployer wallet to smart contract
                result = await transaction.wait() //waits for the entire transaction to finish on the block before moving on to the next step
            })
    
            it('- transfers token balances', async () => {
                //Ensure tokens were transfered & balance changes
                expect(await token.balanceOf(deployer.address)).to.equal(tokens(999900))
                expect(await token.balanceOf(receiver.address)).to.equal(amount)
              
            })
    
            it('- emits a Transfer event', async () => {
                //check for events
            const event = result.events[0] 
            expect (event.event).to.equal('Transfer')
            
            //check for arguments
            const args = event.args 
            expect(args.from).to.equal(deployer.address)
            expect(args.to).to.equal(receiver.address)
            expect(args.to).to.equal(receiver.address)
            expect(args.value).to.equal(amount)
            })
        })

        describe ('Failure', () =>{
            it('- rejects insufficent balances', async () => {
                //To test, transfer more tokens than the deployer has e.g 100M. For sufficent balance txns, this test will fail e.g 10 tokens
                const invalidAmount = tokens(100000000)
                await expect (token.connect(deployer).transfer(receiver.address, invalidAmount)).to.be.reverted
            })

            //Reject invalid receipients
            it('- rejects invalid receipts', async () =>{
                const amount = tokens(100)
                await expect(token.connect(deployer).transfer('0x0000000000000000000000000000000000000000',amount)).to.be.reverted
            })
        })
    })
    //Describe approving
})
