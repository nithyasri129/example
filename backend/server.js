
const express = require("express");
const cors = require("cors");
const path = require("path");
const db = require("./db");
const studentRoutes = require("./routes/students");

const app = express();
app.use(cors());
app.use(express.json());

// Serve static files from frontend directory
app.use(express.static(path.join(__dirname, "../frontend")));

app.use("/students", studentRoutes);

// Serve index.html for root path
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../frontend/index.html"));
});

app.listen(5000, () => console.log("Server running on port 5000"));
