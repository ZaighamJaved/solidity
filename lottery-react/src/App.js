import logo from './logo.svg'
import './App.css'
import web3 from './web3'
import lottery from './lottery'

function App() {
  const manager = lottery.methods.manager().call()
  console.log('manager: ', manager)
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Lottery App

        </a>
      </header>
    </div>
  )
}

export default App
