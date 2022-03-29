const HDWalletProvider = require('truffle-hdwallet-provider')
const Web3 = require('web3')
const { abi, evm } = require('./compile')
const dotenv = require('dotenv')
dotenv.config()
const privateKey = process.env.WALLET_PRIVATE_KEY
const provider = new HDWalletProvider(privateKey, 'https://rinkeby.infura.io/v3/6326e5f8712341d4b40147d068298de4')

const web3 = new Web3(provider)

const deploy = async () => {
	const account = (await web3.eth.getAccounts())[0]
	console.log('using account: ', account)
	const deployedContract = await new web3.eth.Contract(abi).deploy({ data: evm.bytecode.object, arguments: ['Deployment on Rinkeby'] }).send({ from: account, gas: 1000000 })
	console.log('deployed contract address: ', deployedContract.options.address)
	return
}


deploy()