import { useEffect, useMemo, useRef, useState } from "react";
import React from "react";
import { Stack } from "@mui/joy";
import { CustomButton2, DisplayTitle, ShareModal, colors } from "monkey-trivia-ui-components";
import QRCodeStyling from "qr-code-styling";

type WaitingScreenProps = {
  url: string;
};

export const WaitingScreen = ({ url }: WaitingScreenProps) => {
  const [isShareModalOpen, setShareModalOpen] = useState(false);
  const openShareModal = () => setShareModalOpen(true);
  const closeShareModal = () => setShareModalOpen(false);
  const urlRef = useRef("");
  const ref = useRef(null); //qr code ref

  const qrCode = useMemo(
    () =>
      new QRCodeStyling({
        width: 300,
        height: 300,
        type: "svg",
        data: "",
        image: "https://cryptologos.cc/logos/chimpion-bnana-logo.svg",
        dotsOptions: {
          color: "#4267b2",
          type: "rounded",
        },
        backgroundOptions: {
          color: "#e9ebee",
        },
        imageOptions: {
          crossOrigin: "anonymous",
          margin: 5,
        },
        cornersDotOptions: {
          color: colors.darkYellow,
          type: "dot",
        },
      }),
    [],
  );

  useEffect(() => {
    urlRef.current = url;
    qrCode.update({
      data: url,
    });
    console.log("qrCode URL to share: ", url);
    if (ref.current) {
      qrCode.append(ref.current);
    }
  }, [qrCode, url]);

  return (
    <Stack direction="column" justifyContent="center" alignItems="center" spacing={2}>
      <DisplayTitle text={"Waiting for others to join"} fontSize="2rem" background={colors.yellow} />
      <div ref={ref} onClick={openShareModal} />
      <CustomButton2
        fontSize="2rem"
        background={colors.purple}
        color="#FDD673"
        onClick={openShareModal}
        text="share link"
      />
      <ShareModal url={url} isOpen={isShareModalOpen} onClose={closeShareModal} />
    </Stack>
  );
};
