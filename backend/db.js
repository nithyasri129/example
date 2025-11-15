
const sqlite3 = require("sqlite3").verbose();
const db = new sqlite3.Database("./students.db");

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
