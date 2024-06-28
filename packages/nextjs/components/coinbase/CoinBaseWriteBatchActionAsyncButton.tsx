/*
Coinbase action button that uses smart wallet provider to complete write actions
using the Coinbase Wallet SDK.
*/
import { useCallback } from "react";
import React from "react";
import { WriteContractParameters } from "@wagmi/core";
import { CustomButton2 } from "monkey-trivia-ui-components";
import { WalletCallReceipt } from "viem";
import { useCallsStatus, useWriteContracts } from "wagmi/experimental";

interface CoinBaseWriteBatchActionAsyncButtonProps {
  handleSuccess?: (handleParams: any) => void;
  handleError?: (handleParams: Error) => void;
  text: string;
  contractActions?: WriteContractParameters[];
  paymasterUrl?: string;
  handleReceipts?: (receipts: WalletCallReceipt<bigint, "success" | "reverted">[]) => void; // Updated type
  preRun?: () => boolean;
  postRun?: () => void;
}

export function CoinBaseWriteBatchActionAsyncButton({
  handleSuccess,
  handleError,
  text,
  contractActions,
  paymasterUrl,
  handleReceipts,
  preRun,
  postRun,
}: CoinBaseWriteBatchActionAsyncButtonProps) {
  const { data: id, writeContractsAsync } = useWriteContracts();
  const { data: callsStatus } = useCallsStatus({
    id: id as string,
    query: {
      enabled: !!id,
      // Poll every second until the calls are confirmed and the receipts are available
      refetchInterval: data => {
        if (data.state.data?.status === "CONFIRMED" && data.state.data?.receipts) {
          console.log("callsStatus", data.state.data);
          console.log("callsStatus receipts", data.state.data?.receipts);
          handleReceipts && handleReceipts(data.state.data.receipts);
          return false;
        }
        return 1000;
      },
    },
  });

  const writeAction = useCallback(async () => {
    const canRun = preRun && preRun();
    if (!canRun) {
      alert("Precheck failed");
      return;
    }

    try {
      if (!contractActions || contractActions.length === 0) {
        throw new Error("No contract action provided");
      }

      if (!paymasterUrl) {
        throw new Error("No capabilities provided");
      }

      await writeContractsAsync({
        contracts: contractActions,
        capabilities: {
          paymasterService: {
            url: paymasterUrl,
          },
        },
      });
    } catch (error) {
      handleError && handleError(error as Error);
    } finally {
      if (canRun) {
        postRun && postRun();
      }
    }
  }, [handleSuccess, handleError, contractActions, writeContractsAsync, paymasterUrl, postRun]);

  return (
    <>
      <CustomButton2 text={text} onClick={writeAction} />
      {callsStatus && <div> Status: {callsStatus.status}</div>}
      {/* {callsStatus && callsStatus.receipts && <div> Hash: {callsStatus.receipts[0].transactionHash}</div>} */}
    </>
  );
}
