/*
Coinbase action button that uses smart wallet provider to complete write actions
using the Coinbase Wallet SDK.
*/
import { useCallback } from "react";
import React from "react";
import { WriteContractParameters } from "@wagmi/core";
import { CustomButton2 } from "monkey-trivia-ui-components";
import { useCallsStatus, useWriteContracts } from "wagmi/experimental";

interface CoinBaseWriteBatchActionButtonProps {
  handleSuccess?: (handleParams: any) => void;
  handleError?: (handleParams: Error) => void;
  text: string;
  contractActions?: WriteContractParameters[];
  paymasterUrl?: string;
}

export function CoinBaseWriteBatchActionButton({
  handleSuccess,
  handleError,
  text,
  contractActions,
  paymasterUrl,
}: CoinBaseWriteBatchActionButtonProps) {
  const { data: id, writeContracts } = useWriteContracts();
  const { data: callsStatus } = useCallsStatus({
    id: id as string,
    query: {
      enabled: !!id,
      // Poll every second until the calls are confirmed
      refetchInterval: data => (data.state.data?.status === "CONFIRMED" ? false : 1000),
    },
  });

  const writeAction = useCallback(() => {
    try {
      if (!contractActions || contractActions.length === 0) {
        throw new Error("No contract action provided");
      }

      if (!paymasterUrl) {
        throw new Error("No capabilities provided");
      }

      writeContracts({
        contracts: contractActions,
        capabilities: {
          paymasterService: {
            url: paymasterUrl,
          },
        },
      });

      // console.log('capabilities on writeAction', currentCapabilities);

      handleSuccess && handleSuccess("sdfgsdfgsdfg");
    } catch (error) {
      handleError && handleError(error as Error);
    }
  }, [handleSuccess, handleError, contractActions, writeContracts, paymasterUrl]);

  return (
    <>
      <CustomButton2 text={text} onClick={writeAction} />
      {callsStatus && <div> Status: {callsStatus.status}</div>}
    </>
  );
}
