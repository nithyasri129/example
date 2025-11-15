
const express = require("express");
const router = express.Router();
const db = require("../db");

// GET all students
router.get("/", (req, res) => {
 db.all("SELECT * FROM students ORDER BY id DESC", [], (err, rows) => {
  if(err) return res.status(500).json({error: err.message});
  res.json(rows || []);
 });
});

// GET student by ID
router.get("/:id", (req, res) => {
 db.get("SELECT * FROM students WHERE id = ?", [req.params.id], (err, row) => {
  if(err) return res.status(500).json({error: err.message});
  if(!row) return res.status(404).json({error: "Student not found"});
  res.json(row);
 });
});

// POST new student
router.post("/", (req, res) => {
 const {name, email, roll, grade, phone} = req.body;
 
 // Validation
 if(!name || !email || !roll) {
  return res.status(400).json({error: "Name, email, and roll number are required"});
 }
 
 db.run(
  "INSERT INTO students(name, email, roll, grade, phone) VALUES(?,?,?,?,?)",
  [name, email, roll, grade || null, phone || null],
  function(err){
   if(err) {
    if(err.message.includes("UNIQUE constraint failed")) {
     return res.status(400).json({error: "Roll number already exists"});
    }
    return res.status(500).json({error: err.message});
   }
   res.status(201).json({id: this.lastID, name, email, roll, grade, phone});
  }
 );
});

// PUT/UPDATE student
router.put("/:id", (req, res) => {
 const {name, email, roll, grade, phone} = req.body;
 
 if(!name || !email || !roll) {
  return res.status(400).json({error: "Name, email, and roll number are required"});
 }
 
 db.run(
  "UPDATE students SET name=?, email=?, roll=?, grade=?, phone=? WHERE id=?",
  [name, email, roll, grade || null, phone || null, req.params.id],
  function(err){
   if(err) {
    if(err.message.includes("UNIQUE constraint failed")) {
     return res.status(400).json({error: "Roll number already exists"});
    }
    return res.status(500).json({error: err.message});
   }
   if(this.changes === 0) {
    return res.status(404).json({error: "Student not found"});
   }
   res.json({id: req.params.id, name, email, roll, grade, phone});
  }
 );
});

// DELETE student
router.delete("/:id", (req, res) => {
 db.run("DELETE FROM students WHERE id=?", [req.params.id], function(err){
  if(err) return res.status(500).json({error: err.message});
  if(this.changes === 0) {
   return res.status(404).json({error: "Student not found"});
  }
  res.json({deleted: true, id: req.params.id});
 });
});

module.exports = router;
