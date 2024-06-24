import axios from "axios";

export const getNFTsForOwner = async (owner: string): Promise<any> => {
  const options = {
    method: "GET",
    url: `https://base-sepolia.g.alchemy.com/nft/v3/${process.env.NEXT_PUBLIC_ALCHEMY_API_KEY}/getNFTsForOwner`,
    params: {
      owner: owner,
      withMetadata: "true",
      pageSize: "100",
    },
    headers: { accept: "application/json" },
  };
  //   const response = await axios.get(`${process.env.NEXT_PUBLIC_ALCHEMY_API_URL}`, { topic });

  const response = await axios.request(options);
  return response.data;
};
