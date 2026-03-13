const express = require("express");

const systemLogic = require("../../logic/system");
const electrsService = require("../../services/electrs");
const safeHandler = require("../../utils/safeHandler");

const router = express.Router();

router.get(
  "/electrum-connection-details",
  safeHandler(async (req, res) => {
    res.status(200).json(await systemLogic.getElectrumConnectionDetails());
  })
);

router.get(
  "/version",
  safeHandler(async (req, res) => {
    res.status(200).json(await electrsService.getVersion());
  })
);

router.get(
  "/syncPercent",
  safeHandler(async (req, res) => {
    res.status(200).json(await electrsService.syncPercent());
  })
);

module.exports = router;
