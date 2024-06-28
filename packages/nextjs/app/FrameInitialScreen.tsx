import { FormEvent, useContext, useEffect, useState } from "react";
import jsonAbi from "../abis/TriviaGameHub.sol/TriviaGameHub.json";
import { search } from "../services/exa";
import styles from "./FrameInitialScreen.module.css";
import Stack from "@mui/material/Stack";
import {
  ChooseTopicModal,
  CustomButton2,
  NftCardBaseItemList,
  NftCardBaseProps,
  PickNftModal,
  SegmentedControl,
  SelectedTopicEntries,
  TextFieldMt,
  TopicContext,
  TopicProvider,
  WaitingScreen,
  colors,
  createWarpcastLink,
} from "monkey-trivia-ui-components";
import { AbiItem } from "viem";
import { useAccount } from "wagmi";
import { CircularProgressWithAvatar } from "~~/components/CircularProgress";
import { CoinBaseWriteBatchActionAsyncButton } from "~~/components/coinbase/CoinBaseWriteBatchActionAsyncButton";
// import { CoinBaseWriteBatchActionAsyncButton } from "~~/components/coinbase/CoinBaseWriteBatchActionAsyncButton";
import { CoinBaseWriteBatchActionButton } from "~~/components/coinbase/CoinBaseWriteBatchActionButton";
import { PAYMASTER_URL } from "~~/services/CoinbaseServiceConfigs";
import { getNFTsForOwner } from "~~/services/alchemy/NftApi";
import { FRAMES_URL } from "~~/services/configs";
import { createFrame } from "~~/services/mongo";

export const FrameInitialScreenUIComponent = () => {
  const [loading, setLoading] = useState(false);
  const [frameSessionCreated, setFrameSessionCreated] = useState(false);
  const [frameTitle, setFrameTitle] = useState("");
  const [numberQuestions, setNumberQuestions] = useState("1");
  const { topics } = useContext(TopicContext);
  const [urlFrame, setUrlFrame] = useState("");
  const [scoreToWin, setScoreToWin] = useState("50");

  const [showTopicModal, setShowTopicModal] = useState(false);
  const [showNftModal, setShowNftModal] = useState(false);
  const [nfts, setNfts] = useState<NftCardBaseProps[]>([]);
  const [nftSelected, setNftSelected] = useState<NftCardBaseProps | null>(null);

  // Get current account
  const { address } = useAccount();

  useEffect(() => {
    console.log("showNftModal", showNftModal);

    if (!address) {
      return;
    }

    const _getNFTsForOwner = async () => {
      const nfts = await getNFTsForOwner(address);
      return nfts;
    };

    if (showNftModal) {
      _getNFTsForOwner().then(nfts => {
        const t_nfts = nfts.ownedNfts.map((nft: any) => {
          return {
            name: nft.name,
            description: nft.description,
            tokenType: nft.tokenType,
            image: {
              thumbnailUrl: nft.image.thumbnailUrl,
              originalUrl: nft.image.originalUrl,
            },
            attributes: nft.raw.metadata.attributes,
            tokenId: nft.tokenId,
            contractAddress: nft.contract.address,
          } as NftCardBaseProps;
        });
        console.log("t_nfts", t_nfts);
        setNfts(t_nfts);
      });
    }
  }, [showNftModal, address]);

  // useEffect(() => {
  //   console.log("Selected fields\n--");
  //   console.log("frameTitle", frameTitle);
  //   console.log("numberQuestions", numberQuestions);
  //   console.log("scoreToWin", scoreToWin);
  //   console.log("topicsChosen", topics);
  //   console.log("---");
  // }, [frameTitle, numberQuestions, scoreToWin, topics]);

  const handleFrameTitleChange = (e: FormEvent<HTMLDivElement>) => {
    const target = e.target as HTMLInputElement;
    console.log("target", target.value);
    setFrameTitle(target.value);
  };

  const handleCreateFrame = async () => {
    setLoading(true);

    // wait 1 second as test
    // await new Promise(resolve => setTimeout(resolve, 2000));

    if (topics.length === 0 || !topics[0]?.metaphor_id) {
      alert("Please select a topic");
      setLoading(false);
      return;
    }

    try {
      // check contract address and token id
      if (!nftSelected?.contractAddress || !nftSelected?.tokenId) {
        alert("Please select a NFT");
        setLoading(false);
        return;
      }

      // Create the frame
      const { frame } = await createFrame({
        name: frameTitle,
        numberOfQuestions: parseInt(numberQuestions),
        topic: {
          name: topics[0]?.name,
          metaphor_id: topics[0]?.metaphor_id,
        },
        scoreToPass: parseInt(scoreToWin),
        token_nft: {
          address: nftSelected?.contractAddress,
          token_id: nftSelected?.tokenId,
        },
      });
      console.log("frame: ", frame);
      // // console.log('questions: ', questions);

      const generateFrameSessionURL = (frameId: string) => {
        return `${FRAMES_URL}?frameId=${frameId}&gamePhase=initial`;
      };

      const frameSessionURL = generateFrameSessionURL(frame._id);

      const warpcastUrl = createWarpcastLink("Play a game with Monkey Trivia!", [frameSessionURL]);

      // https://warpcast.com/~/compose?text=Play%20a%20game%20with%20Monkey%20Trivia!&embeds[]=https://on-chain-summer2024-frames.vercel.app?frameId=667cdb65e7d4dddbd4ea5b1d&gamePhase=initial
      // https://warpcast.com/~/compose?text=Play%20a%20game%20with%20Monkey%20Trivia!&embeds[]=https://on-chain-summer2024-frames.vercel.app?frameId=667ce170e7d4dddbd4ea5b21&gamePhase=initial
      // https://warpcast.com/~/compose?text=Play%20a%20game%20with%20Monkey%20Trivia!&embeds[]=https://d857-2600-100f-a101-9e22-598e-623f-f200-2e08.ngrok-free.app/api/frame?frameId=667ce170e7d4dddbd4ea5b21&gamePhase=initial

      setUrlFrame(warpcastUrl);
      setFrameSessionCreated(true);
    } catch (error) {
      console.error(error);
      // alert('An error occurred while creating the frame');
    }
    setLoading(false);
  };

  return (
    <div className={styles.main}>
      {!loading && frameSessionCreated && <WaitingScreen url={urlFrame} />}
      {loading && <CircularProgressWithAvatar></CircularProgressWithAvatar>}
      {!loading && !frameSessionCreated ? (
        <Stack spacing={3} width={"70%"} alignItems="center">
          {TextFieldMt({
            key: "frameTitle",
            label: "Frame Title",
            placeholder: "",
            onInput: e => {
              handleFrameTitleChange(e);
            },
          })}
          <SegmentedControl
            data={["1", "5", "10"]}
            title={"Number of Questions"}
            onSelectedValueChange={value => {
              setNumberQuestions(value);
            }}
            defaultValue="1"
          />
          <SegmentedControl
            data={["50", "60", "70", "80", "90"]}
            title={"Score requirement"}
            onSelectedValueChange={value => {
              setScoreToWin(value);
            }}
            defaultValue="50"
          />
          <CustomButton2
            text="Pick topic"
            fontSize={"2rem"}
            onClick={() => {
              setShowTopicModal(true);
            }}
            background={`linear-gradient(to bottom right, ${colors.yellow}, ${colors.yellow3})`}
            color={colors.black}
          />

          <CustomButton2
            text="Prize NFT Details"
            fontSize={"2rem"}
            onClick={() => {
              setShowNftModal(true);
            }}
            background={`linear-gradient(to bottom right, ${colors.yellow}, ${colors.yellow3})`}
            color={colors.black}
          />

          <PickNftModal
            open={showNftModal}
            onClose={() => {
              console.log("closed modal");
              setShowNftModal(false);
            }}
            onDone={() => {
              console.log("done");
              setShowNftModal(false);
            }}
            nfts={nfts}
            onSelectedIndexChange={(index: number) => {
              console.log("nft yaaay!", index);
              console.log("nft selected e: ", nfts[index]);
              setNftSelected(nfts[index]);
            }}
          />

          {
            // Box showing the selected nft: contract address and token id
            nftSelected &&
              NftCardBaseItemList({
                ...nftSelected,
              })
          }

          <ChooseTopicModal
            open={showTopicModal}
            onClose={() => {
              console.log("closed modal");
              setShowTopicModal(false);
            }}
            numberQuestions={1}
            onSearch={async (topic: string) => {
              console.log("searching for :", topic);
              const data = await search(topic);
              const preparedData = data.slice(0, 10).map(item => ({ value: item.id, label: item.title }));
              console.log("data", preparedData);
              return preparedData;
            }}
          />

          <SelectedTopicEntries entrySize={topics.length} />

          {/* <CustomButton2
            text="Create Frame"
            onClick={() => {
              console.log("Selected fields\n--");
              console.log("frameTitle", frameTitle);
              console.log("numberQuestions", numberQuestions);
              console.log("scoreToWin", scoreToWin);
              console.log("topicsChosen", topics);
              console.log("nftSelected", nftSelected);
              console.log("---");

              // Lets create the frame
              handleCreateFrame();
            }}
            style={{
              marginTop: "5%",
              marginBottom: "5%",
            }}
          /> */}
          <CoinBaseWriteBatchActionAsyncButton
            handleReceipts={receipts => {
              console.log("receipt hash: ", receipts[0].transactionHash);

              // handle create frame
              handleCreateFrame();
            }}
            text="Create Frame"
            contractActions={[
              {
                address: "0xB29849cA492bF0B07Df7E9c03780334a1961044e",
                abi: jsonAbi.abi as AbiItem[],
                functionName: "createGameWithInterval",
                args: [3600], // inteval should be 1 hour for now in seconds
              },
            ]}
            paymasterUrl={PAYMASTER_URL()}
          />
        </Stack>
      ) : null}
    </div>
  );
};

export const FrameInitialScreen = () => {
  return (
    <TopicProvider>
      <FrameInitialScreenUIComponent />
    </TopicProvider>
  );
};

export default FrameInitialScreen;

// https://warpcast.com/~/compose?text=Play%20a%20game%20with%20Monkey%20Trivia!&embeds[]=http://localhost:3000/trivia/session/66246bcf6d706c32793fa04b
