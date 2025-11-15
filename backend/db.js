
const fs = require('fs');
const path = require('path');
const sqlite3 = require("sqlite3").verbose();

// Ensure data directory exists and use it for the SQLite file so we can mount a
// named Docker volume to persist the database without hiding the whole app.
const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) {
	fs.mkdirSync(dataDir, { recursive: true });
}

const dbPath = path.join(dataDir, 'students.db');
const db = new sqlite3.Database(dbPath);

db.run(`CREATE TABLE IF NOT EXISTS students(
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 name TEXT NOT NULL,
 email TEXT NOT NULL,
 roll TEXT NOT NULL UNIQUE,
 grade TEXT,
 phone TEXT,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)`);

module.exports = db;
