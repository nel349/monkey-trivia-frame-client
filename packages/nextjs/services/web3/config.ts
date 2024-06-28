import { CreateConfigParameters, createConfig, http } from "wagmi";
import { baseSepolia } from "wagmi/chains";
import { coinbaseWallet } from "wagmi/connectors";

const configParams: CreateConfigParameters = {
  chains: [baseSepolia],
  connectors: [
    coinbaseWallet({
      appName: "Create Wagmi",
      preference: "smartWalletOnly",
    }),
  ],
  transports: {
    [baseSepolia.id]: http(),
  },
};

export const myConfig = createConfig(configParams);
