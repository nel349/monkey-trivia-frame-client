import { base, baseSepolia } from "viem/chains";

export const PAYMASTER_URL = () => {
  // if REACT_APP_MODE is set to 'development', use the development paymaster
  if (process.env.NEXT_PUBLIC_SMART_WALLET_MODE === "production") {
    return process.env.NEXT_PUBLIC_PAYMASTER_URL_COINBASE_MAINNET ?? "";
  } else {
    return process.env.NEXT_PUBLIC_PAYMASTER_URL_COINBASE_SEPOLIA ?? "";
  }
};

export const CHAIN_ID = () => {
  if (process.env.NEXT_PUBLIC_SMART_WALLET_MODE === "production") {
    return base.id;
  } else {
    return baseSepolia.id;
  }
};
