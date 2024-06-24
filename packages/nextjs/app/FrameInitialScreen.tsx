import { FormEvent, useContext, useEffect, useState } from "react";
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
  colors,
} from "monkey-trivia-ui-components";
import { useAccount } from "wagmi";
import { getNFTsForOwner } from "~~/services/alchemy/NftApi";

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

  return (
    <div className={styles.main}>
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

          <CustomButton2
            text="Create Frame"
            onClick={() => {
              console.log("Selected fields\n--");
              console.log("frameTitle", frameTitle);
              console.log("numberQuestions", numberQuestions);
              console.log("scoreToWin", scoreToWin);
              console.log("topicsChosen", topics);
              console.log("nftSelected", nftSelected);
              console.log("---");
            }}
            style={{
              marginTop: "5%",
              marginBottom: "5%",
            }}
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
