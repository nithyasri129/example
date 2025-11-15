
const express = require("express");
const cors = require("cors");
const db = require("./db");
const studentRoutes = require("./routes/students");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/students", studentRoutes);

app.listen(3000, () => console.log("Server running on port 3000"));
