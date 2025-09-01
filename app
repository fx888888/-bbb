import React, { useState } from "react";
import { ethers } from "ethers";

// FishingVRF ABI (only main functions)
const abi = [
  "function buyAmmo() payable",
  "function playWithYNGG(uint256 amount) returns (bytes32)",
  "function settle(bytes32 reqId)",
  "function balanceOf(address) view returns (uint256)"
];

const contractAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS";

export default function App() {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [contract, setContract] = useState(null);
  const [account, setAccount] = useState("");
  const [betAmount, setBetAmount] = useState("");
  const [status, setStatus] = useState("");

  async function connectWallet() {
    if (window.ethereum) {
      const prov = new ethers.BrowserProvider(window.ethereum);
      await prov.send("eth_requestAccounts", []);
      const signer = await prov.getSigner();
      const contract = new ethers.Contract(contractAddress, abi, signer);
      setProvider(prov);
      setSigner(signer);
      setContract(contract);
      setAccount(await signer.getAddress());
    } else {
      alert("Please install MetaMask!");
    }
  }

  async function buyAmmo() {
    if (!contract) return;
    try {
      const tx = await contract.buyAmmo({ value: ethers.parseEther("1") });
      await tx.wait();
      setStatus("Bought 100 YNGG with 1 CORE!");
    } catch (err) {
      console.error(err);
      setStatus("Buy ammo failed");
    }
  }

  async function playGame() {
    if (!contract) return;
    try {
      const tx = await contract.playWithYNGG(ethers.parseUnits(betAmount, 18));
      const receipt = await tx.wait();
      const event = receipt.logs[0].topics[1]; // bet reqId hash
      setStatus("Game started, reqId: " + event);
    } catch (err) {
      console.error(err);
      setStatus("Play failed");
    }
  }

  return (
    <div style={{ padding: 20, fontFamily: "Arial" }}>
      <h1>ð£ Fishing Game DApp</h1>
      {!account ? (
        <button onClick={connectWallet}>Connect Wallet</button>
      ) : (
        <p>Connected: {account}</p>
      )}

      <hr />
      <h2>Buy Ammo</h2>
      <button onClick={buyAmmo}>Buy 100 YNGG (cost 1 CORE)</button>

      <hr />
      <h2>Play Game</h2>
      <input
        type="text"
        placeholder="Enter YNGG amount"
        value={betAmount}
        onChange={(e) => setBetAmount(e.target.value)}
      />
      <button onClick={playGame}>Shoot!</button>

      <p>Status: {status}</p>
    </div>
  );
}
