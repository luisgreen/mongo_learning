const MongoClient = require('mongodb').MongoClient;
const DateGenerator = require('random-date-generator');
var random_name = require('node-random-name');

let startDate = new Date(1900, 1, 1);
let endDate = new Date(2018, 6, 6);

//var mongolab_uri = "mongodb://localhost:27001,localhost:27002,localhost:27003/?replicaSet=abc";
var mongolab_uri = "mongodb://lchacon:123456789@localhost:27017";

var options = {
    useNewUrlParser: true,
    autoReconnect: false,
    keepAlive: 1,
    connectTimeoutMS: 30000,
    socketTimeoutMS: 0
}

const client = new MongoClient(mongolab_uri, options);
let db;
let collection;

client.connect(function (err) {
    if (err) {
        console.log(err);
    } else {
        db = client.db("test");
        collection = db.collection("prueba");
        collection.createIndex({ "nombre": 1 });

        for (let i = 0; i < 150; i++) {
            Promise.all(generateInserts()).then((values) => {
                console.log("llegue aqui", values);
                client.close();
            });
        }

    }
});

function generateInserts() {
    const documents = [];
    for (let i = 0; i < 150; i++) {
        documents.push({
            nombre: random_name({ random: Math.random }),
            birth_date: DateGenerator.getRandomDateInRange(startDate, endDate),
            number: Math.random(),
            numberb: Math.random()
        });
    }

    return [collection.insertMany(documents, { writeConcern: { w: "majority" } }).then(result => {
        console.log(result);
        return result.insertedId;
    })]
};