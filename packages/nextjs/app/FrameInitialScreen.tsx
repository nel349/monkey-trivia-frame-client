import { FormEvent, FormEventHandler, useCallback, useContext, useEffect, useState } from "react";
import { search } from "../services/exa";
import styles from "./FrameInitialScreen.module.css";
import Stack from "@mui/material/Stack";
import {
  ChooseTopicModal,
  CustomButton,
  CustomButton2,
  DisplayTitle,
  SegmentedControl,
  SelectedTopicEntries,
  TextFieldMt,
  TopicContext,
  TopicProvider,
  colors,
} from "monkey-trivia-ui-components";

export const FrameInitialScreenUIComponent = () => {
  const [loading, setLoading] = useState(false);
  const [frameSessionCreated, setFrameSessionCreated] = useState(false);
  const [frameTitle, setFrameTitle] = useState("");
  const [collectionName, setCollectionName] = useState("Collection Name");
  const [numberQuestions, setNumberQuestions] = useState("1");
  const { topics } = useContext(TopicContext);
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [description, setDescription] = useState("");
  const [sellerBasisPoints, setSellerBasisPoints] = useState(5);
  const [connected, setConnected] = useState(false);
  const [urlFrame, setUrlFrame] = useState("");
  const [scoreToWin, setScoreToWin] = useState("50");

  const [showTopicModal, setShowTopicModal] = useState(false);

  useEffect(() => {
    console.log("Selected fields\n--");
    console.log("frameTitle", frameTitle);
    console.log("numberQuestions", numberQuestions);
    console.log("scoreToWin", scoreToWin);
    console.log("---");
  }, [frameTitle, numberQuestions, scoreToWin]);

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
            background={`linear-gradient(to bottom right, ${colors.yellow}, #D5B45B)`}
            color="#2B2C21"
          />

          <ChooseTopicModal
            open={showTopicModal}
            onClose={() => {
              console.log("closed modal");
              setShowTopicModal(false);
            }}
            numberQuestions={1}
            onSearch={
              // async (search: string) => {
              //   await sleep(1000);
              //   const data = mockData.slice(0, 10).map((item) => ({ value: item.id, label: item.title }))
              //   console.log("searching for :", search);
              //   return data;
              // }
              async (topic: string) => {
                console.log("searching for :", topic);
                const data = await search(topic);
                const preparedData = data.slice(0, 10).map(item => ({ value: item.id, label: item.title }));
                console.log("data", preparedData);
                return preparedData;
              }
            }
          />

          <SelectedTopicEntries entrySize={topics.length} />

          <CustomButton2
            text="Create Frame"
            onClick={() => {
              console.log("create frame");
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
  // devnet endpoint

  // const endpoint = 'https://api.mainnet-beta.solana.com';

  return (
    // <ConnectionProvider endpoint={endpoint}>
    //     <WalletProvider wallets={wallets} autoConnect>
    <TopicProvider>
      <FrameInitialScreenUIComponent />
    </TopicProvider>
    // {/* </WalletProvider>
    // </ConnectionProvider> */}
  );
};

export default FrameInitialScreen;

// https://warpcast.com/~/compose?text=Play%20a%20game%20with%20Monkey%20Trivia!&embeds[]=http://localhost:3000/trivia/session/66246bcf6d706c32793fa04b
