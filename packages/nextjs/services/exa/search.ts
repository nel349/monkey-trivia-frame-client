import { BASE_SERVICE_URL } from "../configs";
import axios from "axios";
import { ExaEntry } from "~~/domain/ExaEntry";

export const search = async (topic: string): Promise<ExaEntry[]> => {
  console.log("service url", BASE_SERVICE_URL);
  const response = await axios.post(`${BASE_SERVICE_URL}/api/metaphor/search`, { topic });
  return response.data;
};
