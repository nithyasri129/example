
const express = require("express");
const cors = require("cors");
const path = require("path");
const db = require("./db");
const studentRoutes = require("./routes/students");
const { register, metricsMiddleware, studentsTotal } = require("./metrics");

const app = express();
app.use(cors());
app.use(express.json());
app.use(metricsMiddleware);

// Serve static files from frontend directory
app.use(express.static(path.join(__dirname, "../frontend")));

app.use("/students", studentRoutes);

// Health check endpoint for Docker and monitoring
app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

// Prometheus metrics endpoint
app.get('/metrics', async (req, res) => {
  try {
    // Update students total count
    db.get("SELECT COUNT(*) as count FROM students", [], (err, row) => {
      if (!err && row) {
        studentsTotal.set(row.count);
      }
    });
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (error) {
    res.status(500).end(error);
  }
});

// Serve index.html for root path
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../frontend/index.html"));
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
