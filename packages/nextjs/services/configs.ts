const DEV_BASE_URL = "http://localhost:3333";

export const isDev = process.env.NEXT_PUBLIC_MODE === "dev-service" ? true : false;

export const BASE_SERVICE_URL = isDev ? DEV_BASE_URL : process.env.NEXT_PUBLIC_PROD_MT_SERVICE_URL;
