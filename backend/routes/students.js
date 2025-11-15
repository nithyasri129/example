
const express = require("express");
const router = express.Router();
const db = require("../db");

router.get("/", (req, res) => {
 db.all("SELECT * FROM students", [], (err, rows) => {
  if(err) return res.status(500).send(err);
  res.json(rows);
 });
});

router.post("/", (req, res) => {
 const {name, age} = req.body;
 db.run("INSERT INTO students(name, age) VALUES(?,?)",[name, age], function(err){
   if(err) return res.status(500).send(err);
   res.json({id:this.lastID, name, age});
 });
});

router.patch("/:id", (req,res)=>{
 const {name, age} = req.body;
 db.run("UPDATE students SET name=?, age=? WHERE id=?",[name,age,req.params.id],function(err){
  if(err) return res.status(500).send(err);
  res.json({updated:true});
 });
});

router.delete("/:id",(req,res)=>{
 db.run("DELETE FROM students WHERE id=?",[req.params.id],function(err){
  if(err) return res.status(500).send(err);
  res.json({deleted:true});
 });
});

module.exports = router;
