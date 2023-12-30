import { useState } from "react";
import { useContractWrite } from "@starknet-react/core";
import leetGold from "./abi/elite_gold_EliteGold.contract_class.json";
import { useMemo } from "react";
import { useContract, useAccount, useConnect } from "@starknet-react/core";

export const Claim = () => {
  const { address } = useAccount();
  const { connector } = useConnect();
  const [adventurerId, setAdventurerId] = useState("");
  const [statusMessage, setStatusMessage] = useState("");

  const { contract } = useContract({
    abi: leetGold.abi,
    address: import.meta.env.VITE_PUBLIC_CONTRACT,
  });

  const calls = useMemo(() => {
    if (!address || !contract || !adventurerId) return [];
    return contract.populateTransaction["harvest_elite_gold"]!(
      parseInt(adventurerId),
      connector?.name === "braavos" ? 1 : 0
    );
  }, [contract, address, connector, adventurerId]);

  const { writeAsync, isPending } = useContractWrite({
    calls,
  });

  const handleHarvest = async () => {
    if (!adventurerId) {
      setStatusMessage("Please enter an Adventurer ID.");
      return;
    }
    try {
      await writeAsync();
      setStatusMessage("Harvest request sent.");
    } catch (error) {
      setStatusMessage("Error sending harvest request.");
      console.error(error);
    }
  };

  return (
    <div className="sm:w-1/2">
      <div className="">
        <input
          placeholder="Adventurer ID"
          className="inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-offset-2 disabled:bg-terminal-black disabled:pointer-events-none uppercase font-sans-serif shadow-inner text-center sm:h-10 px-2 py-1 sm:py-2 sm:px-4 text-xs sm:text-sm bg-black text-terminal-green p-2 border-terminal-green border"
          type="text"
          value={adventurerId}
          onChange={(e) => setAdventurerId(e.target.value)}
        />
        <button
          className="active:scale-95 inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-offset-2 disabled:bg-terminal-black disabled:pointer-events-none data-[state=open]:bg-slate-100 uppercase font-sans-serif border border-transparent disabled:text-slate-600 bg-terminal-green text-black hover:bg-terminal-green/80 hover:animate-pulse shadow-inner text-center sm:h-10 px-2 py-1 sm:py-2 sm:px-4 text-xs sm:text-sm"
          onClick={handleHarvest}
          disabled={isPending}
        >
          {isPending ? <div>Harvesting...</div> : "Harvest Elite Gold"}
        </button>
        {statusMessage && (
          <div className="text-terminal-green">{statusMessage}</div>
        )}
      </div>
    </div>
  );
};
