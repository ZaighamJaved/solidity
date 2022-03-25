const path = require('path')
const fs = require('fs')
const solc = require('solc')
const inboxContractPath = path.resolve(__dirname, 'contracts', 'Inbox.sol')
const sourceCode = fs.readFileSync(inboxContractPath, 'utf8')

var solcInput = {
	language: "Solidity",
	sources: {
		contract: {
			content: sourceCode
		}
	},
	settings: {
		optimizer: {
			enabled: true
		},
		evmVersion: "byzantium",
		outputSelection: {
			"*": {
				"": [
					"legacyAST",
					"ast"
				],
				"*": [
					"abi",
					"evm.bytecode.object",
					"evm.bytecode.sourceMap",
					"evm.deployedBytecode.object",
					"evm.deployedBytecode.sourceMap",
					"evm.gasEstimates"
				]
			},
		}
	}
}



solcInput = JSON.stringify(solcInput)

var contractObject = solc.compile(solcInput)
contractObject = JSON.parse(contractObject)
module.exports = contractObject.contracts['contract']['Inbox']
// console.log(contractObject)
