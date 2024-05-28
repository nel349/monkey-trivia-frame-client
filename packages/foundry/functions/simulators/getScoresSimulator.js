const requestConfig = require("../configs/getScoresConfig.js")
const { simulateScript, decodeResult } = require("@chainlink/functions-toolkit")


async function main() {
    const arg1 = process.argv[2];
    const arg2 = process.argv[3];
    console.log("Simulating script with argument: %s and %s", arg1, arg2)
    requestConfig.args = [arg1, arg2]
    const { responseBytesHexstring, errorString, capturedTerminalOutput } = await simulateScript(requestConfig)
    console.log(`${capturedTerminalOutput}\n`)
    if (responseBytesHexstring) {
        console.log(
            `Response returned by script during local simulation: ${decodeResult(
                responseBytesHexstring,
                requestConfig.expectedReturnType
            ).toString()}\n`
        )
    }
    if (errorString) {
        console.log(`Error returned by simulated script:\n${errorString}\n`)
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});