import {
  useAccount,
  useConnect,
  useContract,
  useContractRead,
  useContractWrite,
} from "@starknet-react/core";
import tourney from "./abi/tourney_tourney.contract_class.json";
import { useMemo, useState } from "react";

export const Tourney = () => {
  const { data: highScore, isLoading: isHighScoreLoading } = useContractRead({
    functionName: "get_high_score",
    args: [],
    abi: tourney.abi,
    address: import.meta.env.VITE_PUBLIC_TOURNEY,
    watch: true,
  });

  const { data: winner, isLoading: isWinnerLoading } = useContractRead({
    functionName: "get_winner",
    args: [],
    abi: tourney.abi,
    address: import.meta.env.VITE_PUBLIC_TOURNEY,
    watch: true,
  });

  const { data: survivorId, isLoading: isSurvivorIdLoading } = useContractRead({
    functionName: "get_survivor_id",
    args: [],
    abi: tourney.abi,
    address: import.meta.env.VITE_PUBLIC_TOURNEY,
    watch: true,
  });

  const { data: blocksTillEnd, isLoading: isBlocksTillEndLoading } =
    useContractRead({
      functionName: "get_blocks_till_end",
      args: [],
      abi: tourney.abi,
      address: import.meta.env.VITE_PUBLIC_TOURNEY,
      watch: true,
    });

  const loading =
    isHighScoreLoading ||
    isWinnerLoading ||
    isSurvivorIdLoading ||
    isBlocksTillEndLoading;

  const { address } = useAccount();
  const [statusMessage, setStatusMessage] = useState("");
  const [adventurerId, setAdventurerId] = useState("");

  const { connector } = useConnect();

  const { contract } = useContract({
    abi: tourney.abi,
    address: import.meta.env.VITE_PUBLIC_TOURNEY,
  });

  const claimWinner = useMemo(() => {
    if (!address || !contract) return [];
    return contract.populateTransaction["claim_erc20"]!(
      import.meta.env.VITE_PUBLIC_CONTRACT
    );
  }, [contract, address]);

  const { writeAsync, isPending } = useContractWrite({
    calls: claimWinner,
  });

  const setHighScore = useMemo(() => {
    if (!address || !contract || !adventurerId) return [];
    return contract.populateTransaction["set_high_score"]!(
      parseInt(adventurerId),
      connector?.name === "braavos" ? 1 : 0
    );
  }, [contract, address, adventurerId, connector?.name]);

  const { writeAsync: setHighScoreWriteAsync, isPending: isPendingHighScore } =
    useContractWrite({
      calls: setHighScore,
    });

  const handleClaim = async () => {
    try {
      await writeAsync();
      setStatusMessage("Harvest request sent.");
    } catch (error) {
      setStatusMessage("Error sending harvest request.");
      console.error(error);
    }
  };

  const handleSetHighScore = async () => {
    try {
      await setHighScoreWriteAsync();
      setStatusMessage("Harvest request sent.");
    } catch (error) {
      setStatusMessage("Error sending harvest request.");
      console.error(error);
    }
  };

  const isWinner = useMemo(() => {
    return address === winner;
  }, [winner]);

  return (
    <div className="border border-terminal-green sm:w-1/2 mt-4">
      <div className=" p-3">
        <h3 className="text-3xl">1000 Block Tourney</h3>
        <p>
          You can submit a survivor that was born in the last 1000 blocks. If
          you are a top score.
        </p>
      </div>

      {loading && <div>Loading...</div>}

      {!loading && (
        <div className="grid grid-cols-2 border-terminal-green">
          <div className="border border-terminal-green p-3">
            <h4 className="text-xl">High Score</h4>
            {highScore?.toString()}
          </div>
          <div className="border border-terminal-green p-3">
            <h4 className="text-xl">Winner</h4>
            {winner?.toString()}
          </div>

          <div className="border border-terminal-green p-3">
            <h4 className="text-xl">Survivor ID</h4>
            {survivorId?.toString()}
          </div>

          <div className="border border-terminal-green p-3">
            <h4 className="text-xl">Blocks Until Score Expires</h4>
            {blocksTillEnd?.toString()}
          </div>
        </div>
      )}

      {isWinner && (
        <button
          className="active:scale-95 inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-offset-2 disabled:bg-terminal-black disabled:pointer-events-none data-[state=open]:bg-slate-100 uppercase font-sans-serif border border-transparent disabled:text-slate-600 bg-terminal-green text-black hover:bg-terminal-green/80 hover:animate-pulse shadow-inner text-center sm:h-10 px-2 py-1 sm:py-2 sm:px-4 text-xs sm:text-sm w-full"
          onClick={handleClaim}
          disabled={isPending}
        >
          {isPending ? <div>Harvesting...</div> : "Claim"}
        </button>
      )}

      {!isWinner && (
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
            onClick={handleSetHighScore}
            disabled={isPendingHighScore}
          >
            {isPending ? <div>Harvesting...</div> : "Set High Score"}
          </button>
          {statusMessage && (
            <div className="text-terminal-green">{statusMessage}</div>
          )}
        </div>
      )}
    </div>
  );
};
