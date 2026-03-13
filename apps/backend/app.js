const express = require("express");
const path = require("path");

const pingRouter = require("./routes/ping");
const electrsRouter = require("./routes/v1/electrs");

const app = express();
const frontendDist = path.join(__dirname, "..", "frontend", "dist");

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/ping", pingRouter);
app.use("/v1/electrs", electrsRouter);
app.use("/", express.static(frontendDist));

app.get("*", (req, res) => {
  res.sendFile(path.join(frontendDist, "index.html"));
});

module.exports = app;
