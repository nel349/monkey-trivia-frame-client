import { useEffect, useMemo, useRef, useState } from "react";
import React from "react";
import { Stack } from "@mui/joy";
import QRCodeStyling from "@solana/qr-code-styling";
import { CustomButton2, DisplayTitle, ShareModal, colors } from "monkey-trivia-ui-components";

type WaitingScreenProps = {
  url: string;
};

export const WaitingScreen = ({ url }: WaitingScreenProps) => {
  const [isShareModalOpen, setShareModalOpen] = useState(false);
  const openShareModal = () => setShareModalOpen(true);
  const closeShareModal = () => setShareModalOpen(false);
  const urlRef = useRef("");
  const ref = useRef<HTMLDivElement>(null);

  const qrCode = useMemo(
    () =>
      new QRCodeStyling({
        width: 300,
        height: 300,
        type: "svg",
        data: "",
        image: "https://cryptologos.cc/logos/chimpion-bnana-logo.svg",
        dotsOptions: {
          color: colors.black,
          type: "square",
        },
        backgroundOptions: {
          color: "#e9ebee",
        },
        imageOptions: {
          crossOrigin: "anonymous",
          margin: 5,
        },
        margin: 10,
        cornersDotOptions: {
          color: colors.black,
          type: "square",
        },
      }),
    [],
  );

  useEffect(() => {
    if (ref.current) {
      // Clear the existing QR code
      ref.current.innerHTML = "";
      // Append the new QR code
      qrCode.append(ref.current);
    }
  }, [qrCode]);

  useEffect(() => {
    urlRef.current = url;
    qrCode.update({
      data: url,
    });
  }, [qrCode, url]);

  return (
    <Stack
      direction="column"
      justifyContent="center"
      alignItems="center"
      spacing={3}
      sx={{
        background: colors.black,
        borderRadius: "1rem",
        padding: "2rem",
      }}
    >
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
