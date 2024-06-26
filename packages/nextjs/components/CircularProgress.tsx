import React from "react";
import Image from "next/image";
import monkeyIcon from "../app/assets/avatar/meditating-monkey2-200x-200.png";
import CircularProgress from "@mui/joy/CircularProgress";

export function CircularProgressWithAvatar() {
  return (
    <CircularProgress color="primary" sx={{ "--CircularProgress-size": "200px" }}>
      <Image src={monkeyIcon} alt="Monkey" width={150} height={150} />
    </CircularProgress>
  );
}
