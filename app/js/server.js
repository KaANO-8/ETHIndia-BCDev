const express = require('express')
var bodyParser = require('body-parser')
var MongoClient = require('mongodb').MongoClient;

const app = express()
const port = 3000
const successStatus=200
const createdStatus=201
var url = "mongodb://localhost:27017/";
const dbname="EthIndia"
const collection="ngos"

app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

function addToMongo(name,dsc,about)
{
    MongoClient.connect(url, function(err, db) {
        if (err) throw err;
        var dbo = db.db(dbname);
        var ngo = { name: name, dsc: dsc, about:about};
        dbo.collection(collection).insertOne(ngo, function(err, res) {
          if (err) throw err;
          console.log("1 document inserted");
          db.close();
        });
      });
}

function findNgos(name,callback)
{
    var result1;
    MongoClient.connect(url, function(err, db) {
        if (err) throw err;
        var dbo = db.db(dbname);
        dbo.collection(collection).find({}).toArray(function(err, result) {
          if (err) throw err;
          console.log(result);
          db.close();
          callback(result);
        });
      });
}

app.post('/onboard', function(req, res) {   
    console.log(req.body.name)
    addToMongo(req.body.name,req.body.dsc,req.body.about)
    res.status(createdStatus).send({status:"Success"})
});

app.get('/displayngos', function(req,res){
    findNgos(req.params.tagId,(data) => {
        console.log(data);
        res.status(successStatus).send(JSON.stringify(data))
    })
});

app.listen(port, () => console.log('Example app listening on port 3000!'))
