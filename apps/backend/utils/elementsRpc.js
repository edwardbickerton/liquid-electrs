const fs = require("fs");
const path = require("path");

const { ELEMENTS_CONF_DIR } = require("./const");

function firstNonEmpty(...values) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }

  return "";
}

function normalizeHost(value) {
  const rawValue = firstNonEmpty(value);

  if (!rawValue) {
    return "elements_node_1";
  }

  if (rawValue.startsWith("http://") || rawValue.startsWith("https://")) {
    try {
      return new URL(rawValue).hostname || "elements_node_1";
    } catch (error) {
      return rawValue
        .replace(/^https?:\/\//, "")
        .replace(/\/.*$/, "")
        .replace(/:.*$/, "");
    }
  }

  return rawValue;
}

function parseNumber(value) {
  const parsedValue = Number(value);

  return Number.isFinite(parsedValue) ? parsedValue : undefined;
}

function readElementsConf() {
  const confPath = path.join(ELEMENTS_CONF_DIR, "elements.conf");

  try {
    return fs.readFileSync(confPath, "utf8");
  } catch (error) {
    if (error.code === "ENOENT") {
      throw new Error(
        `Missing Elements config at ${confPath}. This app expects Umbrel's PeerSwap-style \${ELEMENTS_DATA_DIR} mount.`
      );
    }

    throw error;
  }
}

function readRpcPassword() {
  const contents = readElementsConf();

  for (const line of contents.split(/\r?\n/)) {
    const trimmed = line.trim();

    if (!trimmed || trimmed.startsWith("#")) {
      continue;
    }

    const separatorIndex = trimmed.indexOf("=");

    if (separatorIndex < 0) {
      continue;
    }

    const key = trimmed.slice(0, separatorIndex).trim();

    if (key === "rpcpassword") {
      const value = trimmed.slice(separatorIndex + 1).trim();

      if (value) {
        return value;
      }
    }
  }

  throw new Error(
    "Missing rpcpassword in elements.conf. This app expects Umbrel's PeerSwap-style Elements datadir mount."
  );
}

function getElementsRpcConfig() {
  const host = normalizeHost(firstNonEmpty(process.env.ELEMENTS_HOST));
  const port = parseNumber(firstNonEmpty(process.env.ELEMENTS_PORT));
  const username = firstNonEmpty(process.env.ELEMENTS_USER, "elements");
  const password = readRpcPassword();

  if (!port) {
    throw new Error(
      "Missing Elements RPC port. Set ELEMENTS_PORT from Umbrel APP_ELEMENTS_NODE_RPC_PORT."
    );
  }

  return {
    host,
    port,
    username,
    password,
  };
}

module.exports = {
  getElementsRpcConfig,
};
