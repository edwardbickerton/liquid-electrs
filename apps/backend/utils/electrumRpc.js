const net = require("net");

const {
  ELECTRS_HOST,
  ELECTRS_RPC_PORT,
  ELECTRS_RPC_TIMEOUT_MS,
} = require("./const");

function rpcErrorMessage(error, fallback) {
  if (!error) {
    return fallback;
  }

  if (typeof error === "string" && error.trim()) {
    return error.trim();
  }

  if (typeof error.message === "string" && error.message.trim()) {
    return error.message.trim();
  }

  return fallback;
}

function callElectrum(method, params = []) {
  return new Promise((resolve, reject) => {
    const socket = net.createConnection({
      host: ELECTRS_HOST,
      port: ELECTRS_RPC_PORT,
    });
    const requestId = `${method}-${Date.now()}`;
    let buffer = "";
    let settled = false;

    function finish(callback, value) {
      if (settled) {
        return;
      }

      settled = true;
      socket.removeAllListeners();
      socket.destroy();
      callback(value);
    }

    socket.setEncoding("utf8");
    socket.setTimeout(ELECTRS_RPC_TIMEOUT_MS);

    socket.once("connect", () => {
      // Electrum speaks newline-delimited JSON-RPC over plain TCP.
      socket.write(
        `${JSON.stringify({
          jsonrpc: "2.0",
          id: requestId,
          method,
          params,
        })}\n`
      );
    });

    socket.on("data", (chunk) => {
      buffer += chunk;

      while (buffer.includes("\n")) {
        const lineBreakIndex = buffer.indexOf("\n");
        const line = buffer.slice(0, lineBreakIndex).trim();
        buffer = buffer.slice(lineBreakIndex + 1);

        if (!line) {
          continue;
        }

        let message;

        try {
          message = JSON.parse(line);
        } catch (error) {
          finish(
            reject,
            new Error(`Invalid Electrum response for ${method}: ${line}`)
          );
          return;
        }

        if (message.id !== requestId) {
          continue;
        }

        if (message.error) {
          finish(
            reject,
            new Error(
              rpcErrorMessage(
                message.error,
                `Electrum method ${method} returned an error.`
              )
            )
          );
          return;
        }

        finish(resolve, message.result);
        return;
      }
    });

    socket.once("timeout", () => {
      finish(reject, new Error(`Timed out waiting for Electrum ${method}.`));
    });

    socket.once("error", (error) => {
      finish(reject, error);
    });

    socket.once("close", () => {
      if (settled) {
        return;
      }

      finish(
        reject,
        new Error(`Electrum closed the connection before responding to ${method}.`)
      );
    });
  });
}

module.exports = {
  callElectrum,
};
