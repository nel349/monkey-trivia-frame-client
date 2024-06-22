import { useContext, useState } from "react";
import styles from "./FrameInitialScreen.module.css";
import Stack from "@mui/material/Stack";
import {
  ChooseTopicModal,
  CustomButton,
  CustomButton2,
  DisplayTitle,
  SegmentedControl,
  TextFieldMt,
  TopicContext,
  colors,
} from "monkey-trivia-ui-components";

export const FrameInitialScreenUIComponent = () => {
  const [loading, setLoading] = useState(false);
  const [frameSessionCreated, setFrameSessionCreated] = useState(false);
  const [frameTitle, setFrameTitle] = useState("");
  const [collectionName, setCollectionName] = useState("");
  const [numberQuestions, setNumberQuestions] = useState("1");
  const { topics } = useContext(TopicContext);
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [description, setDescription] = useState("");
  const [sellerBasisPoints, setSellerBasisPoints] = useState(5);
  const [connected, setConnected] = useState(false);
  const [urlFrame, setUrlFrame] = useState("");
  const [scoreToWin, setScoreToWin] = useState("50");

  const [showTopicModal, setShowTopicModal] = useState(false);

  return (
    <div className={styles.main}>
      {!loading && !frameSessionCreated ? (
        <Stack spacing={3} width={"70%"} alignItems="center">
          <TextFieldMt label="Frame Title" placeholder={""} onChange={e => console.log(e.currentTarget.value)} />
          <SegmentedControl data={["1", "5", "10"]} title={"Number of Questions"} />
          <SegmentedControl data={["50", "60", "70", "80", "90"]} title={"Score requirement"} />
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
              async (search: string) => {
                console.log("searching for :", search);
                return [];
              }
            }
          />

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
    // {!loading && !frameSessionCreated ?
    // <>
    // <Flex
    //     gap="sm"
    //     justify="center"
    //     align="center"
    //     direction="column"
    //     w="100%"
    //     h="auto" // Fixed height
    // >
    //     <Input
    //         leftSection={<IconPacman />}
    //         placeholder="Frame Title"
    //         radius="md"
    //         styles={{
    //             input: {
    //                 textAlign: 'center',
    //                 width: '100%',  // Ensure the input field takes up the full width of the div
    //                 background: '#DAD5D5',
    //                 opacity: 1,
    //                 fontFamily: 'umbrage2',
    //                 fontSize: '32px',
    //             },
    //         }}
    //         onChange={(e) => setFrameTitle(e.currentTarget.value)}
    //     />

    //     <Container fluid bg="#FDD673" w="100%" className='container-number-players'>
    //         Number of Questions
    //     </Container>
    //     <SegmentedControl w='100%'
    //         fullWidth size="xl"
    //         color="gray"
    //         value={numberQuestions}
    //         data={[
    //             { value: '1', label: '1' },
    //             { value: '5', label: '5' },
    //             { value: '10', label: '10' },
    //         ]}
    //         onChange={(value) => {
    //             setNumberQuestions(value);
    //         }}

    //         style={{ fontFamily: 'umbrage2', marginBottom: '10px' }}
    //     />
    //     <Container fluid bg="#FDD673" w="100%" className='container-number-players'>
    //         Score requirement to win
    //     </Container>
    //     <SegmentedControl w='100%'
    //         fullWidth size="xl"
    //         color="gray"
    //         value={scoreToWin}
    //         data={[
    //             { value: '50', label: '50' },
    //             { value: '60', label: '60' },
    //             { value: '70', label: '70' },
    //             { value: '80', label: '80' },
    //             { value: '90', label: '90' }
    //         ]}
    //         onChange={(value) => {
    //             setScoreToWin(value);
    //         }}

    //         style={{ fontFamily: 'umbrage2', marginBottom: '10px' }}
    //     />
    //     <CustomButton
    //         fontSize={"24px"}
    //         onClick={open}
    //         background='linear-gradient(to bottom right, #FDD673, #D5B45B)'
    //         color='#2B2C21'
    //         style={{
    //             marginTop: '5px',
    //             marginBottom: '5px',
    //         }}>Pick a topic
    //     </CustomButton>
    //     <SelectedTopicEntries
    //         entrySize={topics.length}
    //     />

    //     <CustomButton
    //         fontSize={"24px"}
    //         onClick={buildNftOpen}
    //         background='linear-gradient(to bottom right, #FDD673, #D5B45B)'
    //         color='#2B2C21'
    //     >Build Nft Collection
    //     </CustomButton>
    //     <CustomButton
    //         onClick={handleCreateFrameSubmitted}
    //         style={{
    //             marginTop: '5%',
    //             marginBottom: '5%',
    //         }}
    //     >Create Frame
    //     </CustomButton>

    //     {/* <CustomButton
    //         onClick={onSignMessageClicked}
    //         style={{
    //             marginTop: '5%',
    //             marginBottom: '5%',
    //         }}
    //     >Sign Message
    //     </CustomButton> */}

    // </Flex>
    // <Modal
    //     yOffset={'5dvh'}
    //     opened={opened}
    //     onClose={close}
    //     radius={'xl'}
    //     withCloseButton={false}
    //     styles={{
    //         body: { backgroundColor: colors.blue_turquoise },
    //     }}
    // >
    // <ChooseTopicComponent
    //     numberOfQuestions={parseInt(numberQuestions)}
    //     closeModal={close}
    //     style={
    //         {
    //             backgroundColor: colors.blue_turquoise,
    //         }
    //     }
    // />
    // </Modal>
    // <BuildNftComponent
    //     opened={buildNftOpened}
    //     close={buildNftClose}
    //     open={buildNftOpen}
    //     handleFileSelect={handleFileSelect}
    // />
    // </> : null}

    // {loading ? <Loader color={colors.yellow} /> : null}
    // {frameSessionCreated ? <WaitingScreen url={urlFrame}/> : null}
  );
};

export const FrameInitialScreen = () => {
  // devnet endpoint

  // const endpoint = 'https://api.mainnet-beta.solana.com';

  return (
    // <ConnectionProvider endpoint={endpoint}>
    //     <WalletProvider wallets={wallets} autoConnect>
    <FrameInitialScreenUIComponent />
    // {/* </WalletProvider>
    // </ConnectionProvider> */}
  );
};

export default FrameInitialScreen;

// https://warpcast.com/~/compose?text=Play%20a%20game%20with%20Monkey%20Trivia!&embeds[]=http://localhost:3000/trivia/session/66246bcf6d706c32793fa04b
