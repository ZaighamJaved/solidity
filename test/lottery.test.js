const assert = require('assert')
const ganache = require('ganache-cli')
const Web3 = require('web3')
const web3 = new Web3(ganache.provider())
const { abi, evm } = require('../compile')
let accounts, lottery
beforeEach(async () => {
	accounts = await web3.eth.getAccounts()
	lottery = await new web3.eth.Contract(abi).deploy({ data: evm.bytecode.object }).send({ from: accounts[0], gas: 1000000 })
})

describe('Lottery Contract', () => {
	it('deploys a contract', () => {
		assert.ok(lottery.options.address)
	})

	it('allow a participant to register', async () => {
		await lottery.methods.register().send({ from: accounts[1], value: web3.utils.toWei('0.1', 'ether') })
		const players = await lottery.methods.getAllPlayers().call({ from: accounts[1] })
		assert.equal(accounts[1], players[0])
		assert.equal(1, players.length)
	})

	it('allow multiple participants to register', async () => {
		await lottery.methods.register().send({ from: accounts[2], value: web3.utils.toWei('0.1', 'ether') })
		await lottery.methods.register().send({ from: accounts[3], value: web3.utils.toWei('0.1', 'ether') })
		await lottery.methods.register().send({ from: accounts[4], value: web3.utils.toWei('0.1', 'ether') })
		await lottery.methods.register().send({ from: accounts[5], value: web3.utils.toWei('0.1', 'ether') })
		await lottery.methods.register().send({ from: accounts[6], value: web3.utils.toWei('0.1', 'ether') })
		await lottery.methods.register().send({ from: accounts[7], value: web3.utils.toWei('0.1', 'ether') })
		const players = await lottery.methods.getAllPlayers().call({ from: accounts[1] })
		assert.equal(accounts[2], players[0])
		assert.equal(accounts[3], players[1])
		assert.equal(accounts[4], players[2])
		assert.equal(accounts[5], players[3])
		assert.equal(accounts[6], players[4])
		assert.equal(accounts[7], players[5])
		assert.equal(6, players.length)
	})

	it('requires a fixed amout to register a participant', async () => {
		try {
			await lottery.methods.register().send({ from: accounts[0], value: 100 })
			assert(false)
		} catch (error) {
			assert(error)
		}
	})

	it('only manager can call pick a winner function', async () => {
		try {
			await lottery.methods.pickWinner().send({ from: accounts[2] })
			assert(false)
		} catch (error) {
			assert(error)
		}
	})
})