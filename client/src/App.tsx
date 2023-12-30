import "./App.css";
import { goerli } from "@starknet-react/chains";
import {
  StarknetConfig,
  argent,
  blastProvider,
  braavos,
} from "@starknet-react/core";
import { Wallet } from "./Wallet";
import { Claim } from "./Claim";
import { Tourney } from "./Tourney";

function App() {
  const chains = [goerli];

  const provider = blastProvider({
    apiKey: "de586456-fa13-4575-9e6c-b73f9a88bc97",
  });

  const connectors = [braavos(), argent()];

  return (
    <>
      <StarknetConfig
        chains={chains}
        provider={provider}
        connectors={connectors}
        autoConnect={true}
      >
        <div className="w-screen h-screen bg-black text-terminal-green p-10">
          <Wallet />
          <div className=" py-8">
            <div className="text-3xl">
              Elite Gold shines bright. <br /> Proof of skill, l33t's delight.
              <br />
              For the elite's might.
            </div>
            <a
              className="hover:underline"
              href="https://survivor.realms.world/"
              target="_blank"
            >
              Survive here
            </a>
          </div>
          <Claim />
          <Tourney />
        </div>
      </StarknetConfig>
    </>
  );
}

export default App;
