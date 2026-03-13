const express = require("express");

const router = express.Router();
const { version } = require("../package.json");

router.get("/", (req, res) => {
  res.status(200).json({ version });
});

module.exports = router;
