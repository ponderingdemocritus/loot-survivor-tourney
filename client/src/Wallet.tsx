import { useConnect, useAccount, useBalance } from "@starknet-react/core";

export const Wallet = () => {
  const { connect, connectors } = useConnect();
  const { address, status } = useAccount();

  const { isLoading, isError, error, data } = useBalance({
    address,
    watch: true,
    token: import.meta.env.VITE_PUBLIC_CONTRACT,
  });

  console.log({ isLoading, isError, error, data });

  return (
    <div className="border p-2 border-terminal-green flex justify-between md:w-1/2">
      <div>{address}</div>

      {status !== "connected" && (
        <ul className="flex space-x-2">
          {connectors.map((connector) => (
            <li key={connector.id}>
              <button
                className="active:scale-95 inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-offset-2 disabled:bg-terminal-black disabled:pointer-events-none data-[state=open]:bg-slate-100 uppercase font-sans-serif border border-transparent disabled:text-slate-600 bg-terminal-green text-black hover:bg-terminal-green/80 hover:animate-pulse shadow-inner text-center sm:h-10 px-2 py-1 sm:py-2 sm:px-4 text-xs sm:text-sm"
                onClick={() => connect({ connector })}
              >
                {connector.name}
              </button>
            </li>
          ))}
        </ul>
      )}
      <div>{data ? "EGLD:" + data?.value.toString() : ""}</div>
    </div>
  );
};
