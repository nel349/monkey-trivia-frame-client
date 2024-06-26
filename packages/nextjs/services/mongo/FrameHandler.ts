import { BASE_SERVICE_URL } from "../configs";
import axios from "axios";

interface FrameData {
  name: string;
  numberOfQuestions: number;
  topic: {
    name: string;
    metaphor_id: string;
  };
  scoreToPass: number;
  token_nft: {
    address: string;
    token_id: string;
  };
}

export const createFrame = async (data: FrameData) => {
  try {
    const response = await axios.post(`${BASE_SERVICE_URL}/api/frames/createFrame`, data);
    return response.data;
  } catch (error) {
    console.error(error);
    throw error;
  }
};
