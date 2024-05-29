import { useContext, useMemo, useState } from "react";
import styles from "./FrameInitialScreen.module.css";
import { CustomButton, TopicContext } from "monkey-trivia-ui-components";

// import { Card, Container, FileInput, Flex, Input, Loader,
//      Modal, SegmentedControl, Image, Group, Text,
//      Badge,
//      Textarea,
//      NumberInput} from '@mantine/core';
// import { IconPacman } from '@tabler/icons-react';
// import SelectedTopicEntries from '../components/topics/SelectedTopicEntries';
// import { useDisclosure } from '@mantine/hooks';
// import { TopicContext } from '../components/topics/TopicContext';
// import { colors } from '../components/colors';
// import ChooseTopicComponent from './components/ChooseTopicComponent';
// import { FRAMES_URL } from '../ApiServiceConfig';
// import FrameInitiaHeader from './FrameHeader';
// import { login } from '../authentication/Login';
// import { Web3Auth } from '@web3auth/modal';
// import React from 'react';
// import { createFrame } from '../mongo/FrameHandler';
// import { WaitingScreen } from './components';
// import { createWarpcastLink } from '../components/share/WarpCastLink';
const endpoint = "https://api.devnet.solana.com";

export const FrameInitialScreenUIComponent = () => {
  // const { wallets } = useWallet();
  const [frameTitle, setFrameTitle] = useState("");
  const [collectionName, setCollectionName] = useState("");
  const [numberQuestions, setNumberQuestions] = useState("1");
  // const [opened, { open, close }] = useDisclosure(false);
  // const [buildNftOpened, { open: buildNftOpen, close: buildNftClose }] = useDisclosure(false);
  const { topics } = useContext(TopicContext);
  const [loading, setLoading] = useState(false);
  const [frameSessionCreated, setFrameSessionCreated] = useState(false);
  // const [web3auth, setWeb3auth] = useState<Web3Auth>();
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [description, setDescription] = useState("");
  const [sellerBasisPoints, setSellerBasisPoints] = useState(5);
  const [connected, setConnected] = useState(false);
  const [urlFrame, setUrlFrame] = useState("");

  const [scoreToWin, setScoreToWin] = useState("50");

  // console.log('topics: ', topics);
  const handleFileSelect = (file: any) => {
    console.log("file: ", file);
    if (file) {
      setSelectedImage(file);
    }
  };

  // set solana metaplex seller basis points
  const onSellerBasisPointsChange = (percent: number) => {
    console.log("percent: ", percent);
    // Multiply by 100 to convert to basis points

    setSellerBasisPoints(percent);

    console.log("sellerBasisPoints: ", percent);
  };

  const handleCreateFrameSubmitted = async () => {
    setLoading(true);

    if (topics.length === 0 || !topics[0]?.metaphor_id) {
      // alert('Please select a topic');
      setLoading(false);
      return;
    }

    try {
      // console.log("wallets: ", wallets);
      // Upload the image to the bundlr
      const fileUrl = await uploadImage();

      // const currentWalletPublicKey = wallets[0].adapter.publicKey?.toString();
      // if (!currentWalletPublicKey) {
      //     console.error('Please connect your wallet first');
      //     setLoading(false);
      //     return;
      // }

      // const metadata = {
      //     name: collectionName,
      //     description: description ?? "Collection description",
      //     imageUri: fileUrl ?? "https://raw.githubusercontent.com/mantinedev/mantine/master/.demo/images/bg-8.png",
      //     symbol: "MNTN"
      // }

      //Upload collection metadata to arweave
      // const collectionMetadataUri = await uploadCollectionMetadata(metadata);

      // if (!collectionMetadataUri && !collectionMetadataUri.collectionUri) {
      //     console.error('An error occurred while uploading the collection metadata');
      //     setLoading(false);
      //     return;
      // }

      // Create the collection on solana
      // const collectionMintReceipt = await createNftCollection(
      //     {
      //         name: collectionName,
      //         description: description ?? "Collection description",
      //         imageUri: fileUrl ?? "https://raw.githubusercontent.com/mantinedev/mantine/master/.demo/images/bg-8.png",
      //         sellerFeeBasisPoints: sellerBasisPoints,
      //         symbol: "MNTN",
      //         tokenOwner: currentWalletPublicKey,
      //         uri: collectionMetadataUri.collectionUri
      //     }
      // )

      // console.log('collectionMintReceipt: ', collectionMintReceipt);

      // Create the frame
      // const { frame } = await createFrame({
      //     name: frameTitle,
      //     numberOfQuestions: parseInt(numberQuestions),
      //     topic: {
      //         name: topics[0]?.name,
      //         metaphor_id: topics[0]?.metaphor_id
      //     },
      //     scoreToPass: parseInt(scoreToWin),
      //     collectionMint: collectionMintReceipt.collectionMint,
      // })
      // // console.log('frame: ', frame);
      // // console.log('questions: ', questions);
      // const frameSessionURL = generateFrameSessionURL(frame._id);

      // const warpcastUrl = createWarpcastLink("Play a game with Monkey Trivia!", [frameSessionURL]);
      // setUrlFrame(warpcastUrl);
      // setFrameSessionCreated(true);
    } catch (error) {
      console.error(error);
      // alert('An error occurred while creating the frame');
    }
    setLoading(false);
  };

  // Function to generate a URL for the frame session
  // const generateFrameSessionURL = (frameId: string) => {
  //     return `${FRAMES_URL}/trivia/session/${frameId}`;
  // }

  // const onConnectWalletClicked = async () => {
  //     const { currentUserPublicKey, web3auth } = await login();
  //     console.log('currentUserPublicKey: ', currentUserPublicKey);

  //     if (web3auth) {
  //         setWeb3auth(web3auth);
  //         console.log('web3auth set!');
  //         console.log('connected: ', web3auth.connected);
  //         setConnected(web3auth.connected);
  //         console.log('connected wallet[0]:', wallets[0].adapter.name);
  //         // console.log('connected wallet[1]:', wallets[1].adapter.name);
  //     }
  // }

  const onDoneInBuildNftCollection = () => {
    console.log(`
            collectionName: ${collectionName}
            scoreToWin: ${scoreToWin}
            description: ${description}
            sellerBasisPoints: ${sellerBasisPoints}
            selectedImage: ${selectedImage?.name}
        `);

    // close build nft modal
    // buildNftClose();
  };

  const uploadImage = async () => {
    // if (!web3auth) {
    //     // alert('Please connect your wallet first');
    //     console.error('Please connect your wallet first');
    //     return;
    // }
    // if (web3auth && web3auth.provider) {
    //     console.log('selected adapter: ', web3auth.connectedAdapterName);
    //     // const wallet = new SolanaWallet(web3auth.provider) as unknown as WalletAdapter;
    //     await wallets[0].adapter.connect();
    //     const umi = createUmi(endpoint)
    //         .use(walletAdapterIdentity(wallets[0].adapter))
    //         .use(bundlrUploader())
    //         // .use(mplTokenMetadata());
    //     const fileUri = await uploadFile(umi, selectedImage as File);
    //     console.log('fileUri: ', fileUri);
    //     return fileUri;
    // }
  };

  type BuildComponentProps = {
    opened: boolean;
    close: () => void;
    open: () => void;
    handleFileSelect: (file: any) => void;
  };

  const BuildNftComponent = ({ opened: o, close, handleFileSelect }: BuildComponentProps) => {
    return (
      <></>
      // <Modal
      //     yOffset={'5dvh'}
      //     opened={o}
      //     onClose={close}
      //     radius={'xl'}
      //     withCloseButton={false}
      //     styles={{
      //         body: {
      //             backgroundColor: colors.blue_turquoise
      //         }
      //     }}
      // >
      //     <Flex
      //         gap="sm"
      //         justify="center"
      //         align="center"
      //         direction="column"
      //         w="100%"
      //         p={'xl'}
      //     >
      //     <Input
      //         leftSection={<IconPacman />}
      //         placeholder="Collection Name"
      //         radius="md"
      //         value={collectionName}
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
      //         onChange={(e) => setCollectionName(e.currentTarget.value)}
      //     />

      //     <FileInput
      //         size="lg"
      //         radius="md"
      //         label="Collection Image"
      //         labelProps={{
      //             style: {
      //                 color: colors.black,
      //                 fontFamily: 'umbrage2',
      //                 fontSize: '1rem',
      //             }
      //         }}
      //         withAsterisk
      //         // descriptionProps={{style: {
      //         //     color: colors.black,
      //         //     fontFamily: 'umbrage2',
      //         //     fontSize: '1rem'
      //         // }}}
      //         value={selectedImage}
      //         onChange={handleFileSelect}
      //         // description="This image will be used for all your NFTs in this collection"
      //         placeholder="Collection Image (PNG, JPEG)"
      //         style={{
      //             width: '100%'
      //         }}
      //     />
      //     <Textarea
      //         label="Description"
      //         placeholder="Description of the collection"
      //         labelProps={{
      //             style: {
      //                 color: colors.black,
      //                 fontFamily: 'umbrage2',
      //                 fontSize: '1rem',
      //             }
      //         }}
      //         style={{
      //             width: '100%',

      //         }}

      //         // value={description}
      //         defaultValue={description}
      //         onBlur={(e) => setDescription(e.currentTarget.value)}
      //         // autosize
      //         minRows={2}
      //         maxRows={4}
      //     />
      //     <NftPreviewCard
      //         imageUri={selectedImage ? URL.createObjectURL(selectedImage) : undefined}
      //         // name={collectionName}
      //         // description={description}
      //         style={{
      //             width: '100%',
      //         }}
      //     />
      //     <CustomButton fontSize='1.5rem' onClick={onDoneInBuildNftCollection}> Done </CustomButton>
      //     </Flex>
      // </Modal>
    );
  };

  type NftPreviewCardProps = {
    imageUri?: string;
    // name?: string;
    // description?: string;
    style?: React.CSSProperties;
  };

  function NftPreviewCard({
    style,
    imageUri,
  }: //  name, description:descr
  NftPreviewCardProps) {
    return (
      <></>
      //   <Card shadow="sm" padding="lg" radius="md" withBorder style={style}>
      //     <Card.Section component="a" href="https://mantine.dev/">
      //       <Image
      //         bg={'darkGray'}
      //         src={ imageUri ?? "https://raw.githubusercontent.com/mantinedev/mantine/master/.demo/images/bg-8.png"}
      //         height={160}
      //         fit={'contain'}
      //         alt="Norway"
      //       />
      //     </Card.Section>

      //     <Group justify="space-between" mt="md" mb="xs">
      //       <Text fw={500}>{collectionName && collectionName.length > 0 ? collectionName : "Collection Name"}</Text>
      //       <Badge color="pink">{sellerBasisPoints ? `${sellerBasisPoints}%` : `5%`}</Badge>
      //     </Group>

      //     <Text size="sm" c="dimmed">
      //       {description && description.length > 0 ? description : `With Fjord Tours you can explore more of the magical fjord landscapes with tours and
      //       activities on and around the fjords of Norway`}
      //     </Text>

      //     <NumberInput
      //         label="Seller royalties"
      //         placeholder="Percents"
      //         suffix="%"
      //         // defaultValue={5}
      //         max={100}
      //         value={sellerBasisPoints}
      //         onBlur={(value) => {
      //             const percent = value.currentTarget.value.replace('%', '')
      //             console.log('value: ', percent);
      //             onSellerBasisPointsChange(Number(percent))}
      //         }
      //         onChange={
      //             (value) => {
      //                 // const percent = value.currentTarget.value.replace('%', '')
      //             console.log('value: ', value);
      //             onSellerBasisPointsChange(Number(value))
      //         }

      //         }
      //         mt="md"
      //     />

      //     {/* <Button color="blue" fullWidth mt="md" radius="md">
      //       Book classic tour now
      //     </Button> */}
      //   </Card>
    );
  }

  return (
    <div className={styles.main}></div>
    //     <FrameInitiaHeader onConnect={onConnectWalletClicked} isConnected={connected} />
    //     {!loading && !frameSessionCreated ?
    //     <>
    //     <Flex
    //         gap="sm"
    //         justify="center"
    //         align="center"
    //         direction="column"
    //         w="100%"
    //         h="auto" // Fixed height
    //     >
    //         <Input
    //             leftSection={<IconPacman />}
    //             placeholder="Frame Title"
    //             radius="md"
    //             styles={{
    //                 input: {
    //                     textAlign: 'center',
    //                     width: '100%',  // Ensure the input field takes up the full width of the div
    //                     background: '#DAD5D5',
    //                     opacity: 1,
    //                     fontFamily: 'umbrage2',
    //                     fontSize: '32px',
    //                 },
    //             }}
    //             onChange={(e) => setFrameTitle(e.currentTarget.value)}
    //         />

    //         <Container fluid bg="#FDD673" w="100%" className='container-number-players'>
    //             Number of Questions
    //         </Container>
    //         <SegmentedControl w='100%'
    //             fullWidth size="xl"
    //             color="gray"
    //             value={numberQuestions}
    //             data={[
    //                 { value: '1', label: '1' },
    //                 { value: '5', label: '5' },
    //                 { value: '10', label: '10' },
    //             ]}
    //             onChange={(value) => {
    //                 setNumberQuestions(value);
    //             }}

    //             style={{ fontFamily: 'umbrage2', marginBottom: '10px' }}
    //         />
    //         <Container fluid bg="#FDD673" w="100%" className='container-number-players'>
    //             Score requirement to win
    //         </Container>
    //         <SegmentedControl w='100%'
    //             fullWidth size="xl"
    //             color="gray"
    //             value={scoreToWin}
    //             data={[
    //                 { value: '50', label: '50' },
    //                 { value: '60', label: '60' },
    //                 { value: '70', label: '70' },
    //                 { value: '80', label: '80' },
    //                 { value: '90', label: '90' }
    //             ]}
    //             onChange={(value) => {
    //                 setScoreToWin(value);
    //             }}

    //             style={{ fontFamily: 'umbrage2', marginBottom: '10px' }}
    //         />
    //         <CustomButton
    //             fontSize={"24px"}
    //             onClick={open}
    //             background='linear-gradient(to bottom right, #FDD673, #D5B45B)'
    //             color='#2B2C21'
    //             style={{
    //                 marginTop: '5px',
    //                 marginBottom: '5px',
    //             }}>Pick a topic
    //         </CustomButton>
    //         <SelectedTopicEntries
    //             entrySize={topics.length}
    //         />

    //         <CustomButton
    //             fontSize={"24px"}
    //             onClick={buildNftOpen}
    //             background='linear-gradient(to bottom right, #FDD673, #D5B45B)'
    //             color='#2B2C21'
    //         >Build Nft Collection
    //         </CustomButton>
    //         <CustomButton
    //             onClick={handleCreateFrameSubmitted}
    //             style={{
    //                 marginTop: '5%',
    //                 marginBottom: '5%',
    //             }}
    //         >Create Frame
    //         </CustomButton>

    //         {/* <CustomButton
    //             onClick={onSignMessageClicked}
    //             style={{
    //                 marginTop: '5%',
    //                 marginBottom: '5%',
    //             }}
    //         >Sign Message
    //         </CustomButton> */}

    //     </Flex>
    //     <Modal
    //         yOffset={'5dvh'}
    //         opened={opened}
    //         onClose={close}
    //         radius={'xl'}
    //         withCloseButton={false}
    //         styles={{
    //             body: { backgroundColor: colors.blue_turquoise },
    //         }}
    //     >
    //     <ChooseTopicComponent
    //         numberOfQuestions={parseInt(numberQuestions)}
    //         closeModal={close}
    //         style={
    //             {
    //                 backgroundColor: colors.blue_turquoise,
    //             }
    //         }
    //     />
    //     </Modal>
    //     <BuildNftComponent
    //         opened={buildNftOpened}
    //         close={buildNftClose}
    //         open={buildNftOpen}
    //         handleFileSelect={handleFileSelect}
    //     />
    //     </> : null}

    //     {loading ? <Loader color={colors.yellow} /> : null}
    //     {frameSessionCreated ? <WaitingScreen url={urlFrame}/> : null}
  );
};

export const FrameInitialScreen = () => {
  // devnet endpoint

  // const endpoint = 'https://api.mainnet-beta.solana.com';

  const wallets = useMemo(
    () => [
      // new PhantomWalletAdapter(),
    ],
    [],
  );

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
