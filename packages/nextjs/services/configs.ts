const DEV_BASE_URL = "http://localhost:3333";

export const isDev = process.env.NEXT_PUBLIC_MODE === "dev-service" ? true : false;

export let BASE_SERVICE_URL = isDev ? DEV_BASE_URL : process.env.NEXT_PUBLIC_PROD_MT_SERVICE_URL;

export const DEV_FRAMES_URL = "http://localhost:3000";

export const isDev_Frames = process.env.NEXT_PUBLIC_MODE === "prod-service-dev-frame" ? true : false;

export let FRAMES_URL = isDev_Frames ? DEV_FRAMES_URL : process.env.NEXT_PUBLIC_PROD_FRAMES_URL;

// is dev service and dev frame
export const isDevServiceAndFrame = process.env.NEXT_PUBLIC_MODE === "dev-service-dev-frame" ? true : false;

if (isDevServiceAndFrame) {
  BASE_SERVICE_URL = DEV_BASE_URL;
  FRAMES_URL = DEV_FRAMES_URL;
} else {
  BASE_SERVICE_URL = process.env.NEXT_PUBLIC_PROD_MT_SERVICE_URL;
  FRAMES_URL = process.env.NEXT_PUBLIC_PROD_FRAMES_URL;
}
