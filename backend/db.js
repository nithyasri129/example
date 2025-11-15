
const sqlite3 = require("sqlite3").verbose();
const db = new sqlite3.Database("./students.db");

db.run(`CREATE TABLE IF NOT EXISTS students(
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 name TEXT,
 age INTEGER
)`);

module.exports = db;
