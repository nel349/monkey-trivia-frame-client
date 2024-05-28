// This functions get details about Star Wars characters. This example will showcase usage of HTTP requests and console.logs.
// 1, 2, 3 etc.
const game_id = args[0]
// const participant_id = args[1]

// make sure all letters are lower case in participant_id
const participant_id = args[1].toLowerCase()

console.log('game_id:', game_id);
console.log('participant_id:', participant_id);

// Execute the API request (Promise)
const apiResponse = await Functions.makeHttpRequest({
  url: `https://trivia-monkey-server.vercel.app/api/frames/getCurrentScore`,
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  data: {
    game_id,
    participant_id
  }
})

// if (apiResponse.error) {
//   console.error(apiResponse.error)
//   throw Error("Request failed")
// }

const {data}  = apiResponse;

console.log('api response:', data);

// console.log('API response data:', JSON.stringify(data, null, 2));

// Return Character Name
return Functions.encodeString(data)