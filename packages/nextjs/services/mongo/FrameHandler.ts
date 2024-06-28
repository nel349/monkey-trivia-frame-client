import { BASE_SERVICE_URL } from "../configs";
import axios from "axios";

export interface FrameData {
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
  game_id: string;
}

const postFrameData = async (endpoint: string, data: FrameData) => {
  try {
    const response = await axios.post(`${BASE_SERVICE_URL}/api/frames/${endpoint}`, data);
    return response.data;
  } catch (error) {
    console.error(error);
    throw error;
  }
};

export const createFrame = (data: FrameData) => postFrameData("createFrame", data);
export const updateFrame = (data: FrameData) => postFrameData("update", data);
