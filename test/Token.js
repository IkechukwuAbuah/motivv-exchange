const {expect} = require('chai'); //pull expect function from chai library
const {ethers} = require ('hardhat'); //pull ethers library from hardhat library

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}
describe ('Token', () => {//All tests go inside here..
    let token, accounts, deployer
    

    beforeEach(async () => {

        const Token = await ethers.getContractFactory('Token')
        token = await Token.deploy('Dapp University', 'DAPP','1000000000000000000000000')

        accounts = await ethers.getSigners() //gets all accounts - will return array
        deployer = accounts[0] //will get the first value in the array [0]
    })


    describe ('Deployment', () => { //Test for deployment
        const name = 'Dapp University'
        const symbol = 'DAPP'
        const decimals = '18'
        const totalSupply = tokens('1000000')


        it('has correct name', async () => { //Name
            //Read token name & check for correctnes
            expect(await token.name()).to.equal(name)
        })
    
    
        it('has correct symbol', async () => { //Symbol
            //Read token sybol & check for correctness
            expect(await token.symbol()).to.equal(symbol)
        })
    
    
        it('has correct decimals', async () => { //decimals
            //Read token symbol & check for correctness
            expect(await token.decimals()).to.equal(decimals)
        })
    
    
        it('has correct total Supply', async () => {  //Read token total supply & check for correctness
            expect(await token.totalSupply()).to.equal(tokens(totalSupply))
        })


        it('assigns total supply to deployer', async () => {  //Read token total supply & check for correctness
            expect(await token.balanceOf(deployer.address)).to.equal(tokens(totalSupply))
        })
    })


    //Describe Spending
    //Describe approving
})
