const assert = require('assert')
const ganache = require('ganache-cli')
const Web3 = require('web3')
const web3 = new Web3(ganache.provider())
const { abi, evm } = require('../compile')

let accounts, inbox
beforeEach(async () => {
	accounts = await web3.eth.getAccounts()
	// console.log('fetched accounts: \n', accounts)
	inbox = await new web3.eth.Contract(abi).deploy({ data: evm.bytecode.object, arguments: ['I am'] }).send({ from: accounts[0], gas: 1000000 })
})

describe('Inbox', () => {
	it('deploys a contract', () => {
		assert.ok(inbox.options.address)
	})

	it('has a default message', async () => {
		const message = await inbox.methods.message().call()
		assert.equal(message, 'I am')
	})

	it('can change the message', async () => {
		const message = 'A new Message from wallet'
		await inbox.methods.setMessage(message).send({ from: accounts[1], gas: 1000000 })
		const newMessage = await inbox.methods.message().call()
		assert.equal(newMessage, message)
	})
})