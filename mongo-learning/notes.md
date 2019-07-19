# Mongo Cheat Sheet

## MONGO SHELL

- Manipulate Data and Perform Admininstrative Taks

Inside Mongo Shell you can open connections with the following methods: 

```js
new Mongo()
new Mongo("host")
new Mongo("host:port")

conn = new Mongo();
db = conn.getDB("myDatabase");
```

If Needs authentication:

```js
db.auth()
```

### Datatypes Allowed

#### Date

- Internally, Date objects are stored as a signed 64-bit integer representing the number of milliseconds since the Unix epoch (Jan 1, 1970).

#### ObjectId

The 12-byte ObjectId value consists of:

- a 4-byte value representing the seconds since the Unix epoch, 
- a 5-byte random value, and
- a 3-byte counter, starting with a random value.

#### NumberLong

Support NumberLong() wrapper to handle 64-bit integers.

#### NumberInt

Support NumberLong() wrapper to handle 32-bit integers.

#### NumberDecimal

In Mongo, doubles are 64 bit by default

NumberDecimal() constructor allows to explicitly specify 128-bit decimal-based floating-point values.

Use the NumberDecimal() constructor when checking the equality of decimal values.

#### Checking Datatype of a field

```js
db.inventory.find({ price: { $type: "decimal" }})
```

#### Checking Datatype of a variable

This will return `true` or `false` .

```js
mydoc._id instanceof ObjectId
```

This will return the datatype:

```js
typeof mydoc._id
```

-----

- All docs are limited to 16Mb on size by default
- Documents are stored on `powerof2sizes` up to 16Mb

## CRUD

### Concepts

- Atomicity at document level, even if operation affect nested documents.
- Multi-document operations are atomic for each modified document but not as a whole.
- Multi-document transactions are atomic as a whole.
- Concurrency control
    - Creating `unique` single or composite indexes that prevents duplicated data.
- Read Uncommitted
    - Clients with `local` or `available` read concern, can grab info that can even be rolled back.
    - This does not means that a client will read partially updated documents.
    - Default isolation level for all `mongod`, standalone, replica and sharded.

### Distributed Queries

- By default reads are done to primary if not read preference is specified.
- Reads to secontary or nearest are useful for:
    - Reduce latency in multi-data-center deployments,
    - Improve read throughput by distributing high read-volumes (relative to write volume),
    - Perform backup operations, and/or
    - Allow reads until a new primary is elected.

#### Writes on Replica Sets

- Are directed to primary `mongod` and stored to it's `opLog`, then `asyncronous` transferred to secondaries.

#### Reads on Sharded Clusters

- Are directed to a `mongos`
- Are mor efficient if directed to a single shard. To achieve this you can query by the shard key.
- If query does not includes tha shard key, mongos will direct query to all shards and then merge with `scatter gather` merge.

#### Reads on Sharded Clusters

- `mongos` will redirect writes to the corresponding shard, according to config server database.

### Explain results

#### queryPlanner

- Default explain execution, and shows:
    - Winning Plan.
    - Shards and its servers involved.

#### executionStats

- Details the execution of the winning plan and shows:
    - Stages and shards involved.
    - Returned docs.
    - Scanned Keys and docs.
    - Plans executions.

#### allPlansExecution 

- Shows partial execution statistics collected during plan selection.

#### serverInfo

- Returns the serverInfo for each accessed shard or the current server on unsharded

### Insert

- If the collection is not present will be created automatically.
- Will generate an ObjectId if ommited, also for `upserts`.

```js
db.collection.insert("Object Or Array")
db.collection.insertOne({...})
db.collection.insertMany([{...}, {...}, {...}])
```

---

### Query

- Querying null fields will retrieve those documents with that field being data type `null` or not existent

```js
db.inventory.find( {} )
```

Query one array exactly 

```js
db.inventory.find( { tags: ["red", "blank"] } )
```

Query one array that contains all elements no matter the order

```js
db.inventory.find( { tags: { $all: ["red", "blank"] } } )
```

Query an array that contains `red``

```js
db.inventory.find( { tags: "red" } )
```

Query an element index (0 in this case) of an array for certain criteria:

```js
db.inventory.find( { 'instock.0.qty': { $lte: 20, $gte: 10 } } )
```

Query for documens where have a single nested document with multiple criteria:

```js
db.inventory.find( { "instock": { $elemMatch: { qty: 5, warehouse: "A" } } } )
```

Queries for documents where the instock array has at least one embedded document that contains the field qty equal to 5 and at least one embedded document (but not necessarily the same embedded document) that contains the field warehouse equal to A:

```js
db.inventory.find( { "instock.qty": 5, "instock.warehouse": "A" } )
```

#### Cursors

- Cursors lasts 10 minutes by default, except if defined with `...find({}).noCursorTimeout()`
- cursor.toArray() exhausts the cursor (and also loads the whole resultset into RAM)
- Cursors may retrieve duplicated documents if data has changed/moved since cursos generation.
- Cursor Batches have size limit of `16Mb`
- `find()` and `aggregate()` operations have an initial batch size of 101 documents by default.
- Sort operations without an index will load all documents into memory for sorting.
- `myCursor.objsLeftInBatch()` will grab how much object remains on the Cursor Batch


-----

###  Update

Standard methods:

```js
db.collection.update(query, update, options)
db.collection.updateOne(filter, update, options)
db.collection.updateMany(filter, update, options)
db.collection.replaceOne(filter, replacement, options)
```

Also:

```js
db.collection.findOneAndReplace()
db.collection.findOneAndUpdate()
db.collection.findAndModify()
db.collection.save()
db.collection.bulkWrite()
```


#### Options

```js
{
    upsert: boolean,
    writeConcern: document,
    collation: document,
    arrayFilters: [ filterdocument1, ... ]
}
```

```js
db.collection.update(where, doc_or_partial, [upsert, [multi]])
db.collection.update({
    _id: 100
}, {
    _id: 100,
    x: "hello",
    y: 123
}, true, false)
```

Peeking a doc and update

```js
myDoc = db.collection.findOne();
myDoc.new_or_exsisting_prop = 25;
db.collection.update({
    _id: myDoc._id
}, myDoc);
```

### Partial update

```js
db.collection.update({
    _id: 100
}, {
    $set: {
        field: value
    }
}, true, false)
```

#### Operators

See: https://docs.mongodb.com/manual/reference/operator/update/

---

### Delete

```js
db.collection.deleteMany(filter, options)
db.collection.deleteOne(filter, options)
db.collection.remove(query, removeOptions)
```

#### Options
```js
{
    writeConcern: document,
    collation: document
}
```

#### remove() Options

```js
{
    justOne: boolean [false default],
    writeConcern: document,
    collation: document
}
```
---

### Read Concern

The readConcern option allows you to control the consistency and isolation properties of the data read from replica sets and replica set shards.

Is set at transaction level and `not` over individual operations.

- Read Concern `local`
    - No majority warranty
    - Default for reads to primary
    - Associated with Casual Consistency Session
    - On UNSHARDED, local and available behave equals

- Read Concern `available`
    - No majority warranty
    - Default for reads to secondary
    - `NOT` Associated and `NOT AVAILABLE` with Casual Consistency Session
    - On sharded cluster, may return orphaned documents, as does not contact primary shard or config server for metadata.
    - On UNSHARDED, local and available behave equals

- Read Concern `majority`
    - If `multi-document transaction` only guarantees if data was written with `majority` write concern.
    - Otherwise guarantees that the read data was acknowledged by the majority.
    - Disabling "majority" read concern disables support for Change Streams.

- Read Concern `linearizable`
    - Returns data that reflects all successful majority-acknowledged writes prior read.
    - May wait for concurrently executing writes to propagate to a majority members.

- Read Concern `snapshot`
    - `multi-document transaction` only.
    - When transactions commit with write concern `majority`:
        - If causally consistent session, the transaction are guaranteed to have read from a snapshot of majority-committed data.
        - If `NOT` causally consistent session, the transaction are guaranteed to have read from a snapshot of majority-committed data that provides causal consistency with the operation immediately preceding the transaction start.

---

### Write Concern

- Hidden, delayed, and priority 0 members with members[n].votes greater than 0 can acknowledge "majority" write operations.
- Hidden, delayed, and priority 0 members can acknowledge w: <number> write operations.
- Delayed secondaries can return write acknowledgment no earlier than the configured slaveDelay.

```js
{ w: value, j: boolean, wtimeout: number }
```

- `w` default: 1, can be a integer or `majority``
- `j` [true/false], **Note:** j: true does not by itself guarantee that the write will not be rolled back due to replica set primary failover.
- `wtimeout` time limit in milliseconds for the operation

#### Modify Default Write Concern

You can modify the default write concern for a replica set by setting the settings.getLastErrorDefaults setting in the replica set configuration. The following sequence of commands creates a configuration that waits for the write operation to complete on a majority of the voting members before returning:

```js
cfg = rs.conf()
cfg.settings.getLastErrorDefaults = { w: "majority", wtimeout: 5000 }
rs.reconfig(cfg)
```


#### Behavior

**SEE IMPORTANT!**

https://docs.mongodb.com/manual/reference/write-concern/#acknowledgment-behavior

---

### Text Search

***Remember that a collection can have at most `one and only one` text index defined.***

Query containing terms

```js
db.stores.find( { $text: { $search: "java coffee shop" } } )
```

Exact prhase

```js
db.stores.find( { $text: { $search: "\"coffee shop\"" } } )
```

Term exclusion

```js
db.stores.find( { $text: { $search: "java shop -coffee" } } )
```

Sort by Score

```js
db.stores.find(
   { $text: { $search: "java coffee shop" } },
   { score: { $meta: "textScore" } }
).sort( { score: { $meta: "textScore" } } )
```

 
#### Text Search in aggregations

- The `$match` stage that includes a `$text` must be the first stage in the pipeline.
- A text operator can only occur once in the stage.
- The text operator expression cannot appear in `$or` or `$not` expressions.
- The text search, by default, does not return the matching documents in order of matching scores. Use the `$meta` aggregation expression in the `$sort` stage.


---
### Bulk Writes Operations

- Ordered: Serial, stops if error encountered
- Unordered: Parallel (not guarateed), continue on error.

#### Sharding Consideration

- Pre split if collection is empty, to avoid additional overhead when loading initial data 
- Use Unordered bulks to allow `mongos` communicate with simultaneous shards at the same time.
- On monotonically increasing shard key:
    - Reverse the binary bits of the shard key. This preserves the information and avoids correlating insertion order with increasing sequence of values.
    - Swap the first and last 16-bit words to “shuffle” the inserts. 

```js
try {
   db.characters.bulkWrite(
      [
         { insertOne :
            {
               "document" :
               {
                  "_id" : 4, "char" : "Dithras", "class" : "barbarian", "lvl" : 4
               }
            }
         },
         { insertOne :
            {
               "document" :
               {
                  "_id" : 5, "char" : "Taeln", "class" : "fighter", "lvl" : 3
               }
            }
         },
         { updateOne :
            {
               "filter" : { "char" : "Eldon" },
               "update" : { $set : { "status" : "Critical Injury" } }
            }
         },
         { deleteOne :
            { "filter" : { "char" : "Brisbane"} }
         },
         { replaceOne :
            {
               "filter" : { "char" : "Meldane" },
               "replacement" : { "char" : "Tanys", "class" : "oracle", "lvl" : 4 }
            }
         }
      ]
   );
}
catch (e) {
   print(e);
}
```

---

### Retryable Writes

- Does not support standalone instances
- Does not support MMAPv1 Storage Engine
- Is compatible with Sharded or Replica Set clusters
- Retryable writes make only one retry attempt.

To enable retry writes, connect to the instances with a compatible driver

```
mongodb://localhost/?retryWrites=true
```

Or mongo shell:

```sh
$ mongo --retryWrites
```

## AGGREGATION PIPELINES

Is a Framework for data aggregation modeled on the concept of data processing pipelines.

- Can return a cursor (default) or store on a collection.
- Each returned document are limited to 16MB, this does not affect processed documents during pipeline execution.
- Limited to 100MB RAM unless using `allowDiskUse` to allow temporary files.
- Pipeline operators need not produce one output document for every input document.
- `$graphLookup` is hard limited to 100MB, ignores `allowDiskUse`.
- `$geoNear` must be the first stage and can occur only once.
- `$out` can occur only once.
- `$match` and `$sort` can go anywhere but is recommended to put in the beggining of the pipeline for taking advantage of indexes.
- Is preferred and more performant than `map-reduce` but less flexible.
- On sharded Collections
    - `$out` stage and the `$lookup` stage require running on the database’s primary shard.
    - Aggregation operations that run on multiple shards,(not restricted to primary) will route the results to a random shard to merge the results to avoid overloading the primary shard for that database.
- Automatic optimizations
    - `$match` will be moved before any stage that does not require computation like `$project` or `$addFields`.
    - If multiple `$match` are found, will be optimized for each stage.
    - If a `$match` and a `$sort` are present, `$sort` will be put at the end when possible.
    - When you have a sequence with `$project` followed by `$skip`, the `$skip` moves before `$project`.
    - When a `$sort` precedes a `$limit`, the optimizer can coalesce the `$limit` into the `$sort`

## MAP REDUCE

Is a data processing paradigm for condensing large volumes of data into useful aggregated results

```js
db.orders.mapReduce(
    function() { emit(this.cust_id, this.amount); }, // MAP
    function(key, values) { return Array.sum(values); }, // REDUCE
    {
        query: { status: 'A' }, // FILTER
        out: "order_totals"     // OUTPUT COLLECTION 
    }

);
```

- Result documents are limited to 16MB.
- `map-reduce` functions are Javascript and run in the `mongod`.
- Input and Output collections can be sharded.
- Less performant than `aggregation` but more flexible.
- Map function
    - Returns 0 or more documents.
    - Should not access database.
    - Should be pure.
    - Single emit can hold half of max BSON Document Size (8 Mb)
    - Can emit multiple times.
- Reduce Function
    - Should not access database.
    - Should not affect the outside system.
    - The `values` will be always an array.
    - Must be idempotent, associative and commutative.
- Finalize Function
    - Make last operations on the results after being reduced.
- On Sharded Collections
    - `mongos` will dispatch `map-reduce` jobs to each shard in parallel that owns a chunk and wait for finishing.
- During the operation, map-reduce takes the following locks:
    - The read phase takes a read lock. It yields every 100 documents.
    - The insert into the temporary collection takes a write lock for a single write.
    - If the output collection does not exist, the creation of the output collection takes a write lock.
    - If the output collection exists, then the output actions (i.e. merge, replace, reduce) take a write lock. This write lock is global, and blocks all operations on the mongod instance.

## ObjectId
A special 12-byte BSON type that guarantees uniqueness within the collection. The ObjectId is generated based on timestamp, machine ID, process ID, and a process-local incremental counter. MongoDB uses ObjectId values as the default values for _id fields.

## DATA MODELING

- Challenge in data modeling is balancing the needs of the application, the performance characteristics of the database engine, and the data retrieval patterns.
- Each index take at least 8Kb
- Each collection take few Kb
- A single namespacefile `database_name.ns` stores all database metadata. Each index or collection have its own entry. 
- Namespace files are 16 MB by default.
- For MMAP1 can be 24,000 namespaces in total (16MB each), (size / 628), and the size can be configured with `nsSize` option. and cannot be larger than 2047Mb.
- After changing namespace size with `--nssize`, run the `db.repairDatabase()`.
- Namespace files are not subject to such limitations for `wiredTiger`.
- Data validation can be done via JSONShema model during collection creation.
    - You can specify object type, required fields, data type, etc.
    - Two types of validations:
        - **strict** (default): Applies to all Insert/updates
        - **moderate**: Applies to existing documents that already fulfill validations.

### Database Refs

#### Manual via ObjectId

```js
original_id = ObjectId()

db.places.insert({
    "_id": original_id,
    "name": "Broadway Center",
    "url": "bc.example.net"
})

db.people.insert({
    "name": "Erin",
    "places_id": original_id,
    "url":  "bc.example.net/Erin"
})
```

#### Via DBRef 

This allows to make references to another databases / collections

- `$ref`: The $ref field holds the name of the collection where the referenced document resides.
- `$id`: The $id field contains the value of the _id field in the referenced document.
- `$db`: (Optional) Contains the name of the database where the referenced document resides.

```js
{
  "_id" : ObjectId("5126bbf64aed4daf9e2ab771"),
  "creator" : {
                  "$ref" : "creators",
                  "$id" : ObjectId("5126bc054aed4daf9e2ab772"),
                  "$db" : "users"
               }
}
```

Add Validation to existing collection:

```js
db.runCommand( {
   collMod: "contacts",
   validator: { $jsonSchema: {
      bsonType: "object",
      required: [ "phone", "name" ],
      properties: {
         phone: {
            bsonType: "string",
            description: "must be a string and is required"
         },
         name: {
            bsonType: "string",
            description: "must be a string and is required"
         }
      }
   } },
   validationLevel: "moderate"
} )
```

JSONSchema Style Validation

```js
db.createCollection("students", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: [ "name", "year", "major", "gpa", "address.street" ],
         properties: {
            name: {
               bsonType: "string",
               description: "must be a string and is required"
            year: {
               bsonType: "int",
               minimum: 2017,
               maximum: 3017,
               exclusiveMaximum: false,
               description: "must be an integer in [ 2017, 3017 ] and is required"
            },
            major: {
               enum: [ "Math", "English", "Computer Science", "History", null ],
               description: "can only be one of the enum values and is required"
            },
            gpa: {
               bsonType: [ "double" ],
               minimum: 0,
               description: "must be a double and is required"
            },
            "address.street" : {
               bsonType: "string",
               description: "must be a string and is required"
            }
         }
      }
   }
})
```

Query Type Validation

```js
db.createCollection( "contacts",
   { validator: { $or:
      [
         { phone: { $type: "string" } },
         { email: { $regex: /@mongodb\.com$/ } },
         { status: { $in: [ "Unknown", "Incomplete" ] } }
      ]
   }
} )
```

## TRANSACTIONS

- Only on WiredTiger.
- Read Concern level precedence:
    - Transaction level (if set) -> Session level (if set) -> Client level (defaults `local`). 
- Write Concern level precedence:
    - Transaction level (if set) -> Session level (if set) -> Client level (defaults { 'w':1 }). 
- Supports `local`, `majority`, `snapshot` read concerns.
- Supports multidocument transactions against replica-sets, (sharded clusters scheduled for Mongo 4.2)
- Can be across multiple operations, databases, collections and documents.
- All-or-nothing proposition.
- Are associated with a session and can have at most one transaction per session.
- Data is not visible outside transaction until commit.
- If rolled back all data is discarded.

### Notes

- You can specify read/write (CRUD) operations on existing collections. The collections can be in different databases.
- You cannot read/write to collections in the config, admin, or local databases.
- You cannot write to system.* collections.
- You cannot return the supported operation’s query plan (i.e. explain).
- For cursors created outside of transactions, you cannot call getMore inside a transaction.
- For cursors created in a transaction, you cannot call getMore outside the transaction.
- Creating or dropping a collection or an index, are not allowed in multi-document transactions. `listCollections` and `listIndexes` are also excluded.
- `isMaster`, `buildInfo`, `connectionStatus` are allowed but must not be the first operation in transaction.
- Non-CRUD and non-informational operations, such as createUser, getParameter, count, etc. and their helpers are `not` allowed.

### Operations

- For count use a aggregation with a group and sum.
- Cannot use `$collStats`, `$currentOp`, `$indexStats`, `$listLocalSessions`, `$listSessions`, `$out` on aggregations.


```js
Session.startTransaction()
Session.commitTransaction()
Session.abortTransaction()
```

## Query Samples

Show documents properly indented

```js
db.collection.find().pretty()
```

Show documents in an array like form

```js
db.collection.find().toArray()
```

Geospatial Query

```js
db.place.find({
    loc: {
        $near: {
            $geometry: {
                type: "Point",
                coordinates: [2, 2.01]
            },
            spherical: true
        }
    }
})
```

Full text search

```js
db.place.find({
    $text: {
        $search: "find me"
    }
})
```

Full text search with scores

```js
db.place.find({
    $text: {
        $search: "find me"
    }
}, {
    score: {
        $meta: "textScore"
    }
}).sort({
    score: {
        $meta: "textScore"
    }
})
```

## INDEXES

- `_id` index cannot be dropped.
- Indexes can be traversed on either direction.
- On sharded clusters.
    - You must ensure de uniqueness of `_id` field (or use de automatic ObjectId)
- You can create indexes on single fields, embedded documents, and embedded fields on those documents.
- Index types:
    - **Single Field**: Like it sounds, single field of a document.
    - **Compound Index**: More than one field of a document.
    - **Multikey Index**: Index over tehe content of an array. Mongo will create an index entry for each element.  
    - **Geospatial Index**
    - **Text Index**: This do not store `stop words` and `stem` the words in a collection to store root words. 
    - **Hashed Index**: This supports only `equality` match, not range. Have more random distribution.
- Index Properties:
    - **Unique**
    - **Partial**: Index only documents that meets a query selection.
    - **Sparce**: Index only documents if the fields on the index definition are present.
    - **TTL Index**: Index that automatically remove items.
- Index and Collations:
    - `text`, `geoHaystack`, `2d` indexes does not support collation.
    - An index with a collation, can only be used if the query operation specify the same collation.
    - If the index prefix is numeric, a index can still satisfy the prefix portion, and can be used even if the operation is not on the same collation.
- Sort can be covered only on straight or negative, not combinations:

```js
// THIS INDEX:
db.events.createIndex( { "username" : 1, "date" : -1 } )

// CAN COVER THE FOLLOWING QUERIES
db.events.find().sort( { username: 1, date: -1 } )
db.events.find().sort( { username: -1, date: 1 } )

// BUT THIS DOES NOT
db.events.find().sort( { username: 1, date: 1 } )
```

### Covered queries

Is a query where, the `query` portion and the `projection` portion ***ONLY*** contains the indexed fields.

### Index Intersection

When an index can satisfy a part of the query, and another index can satisfy another part of the query.

### Text Index

- Does not support collations.
- You can specify `db.collection.createIndex( { "$**": "text" } )`, a wildcard, to specify that all `string`fields will be text indexed.
- Case insesitivity.
- Diacritic insensitivity.
- Are always sparce.
- Cannot use hint().
- A collection can have at most one text index.
- Cannot use sort option.
- A compound index with a `text` index, cannot have another special indexes like `multikey` or `geospatial`.
- If a compound index contains preceding keys to the `text` index, all the preceding keys must be queried with an equalilty match.
- Phrase queries will run much more effectively when the entire collection fits in RAM.

### Hashed Index

- Support Sharding.
- `convertShardKeyToHashed()` can convert a key to hashed. 
- Can collapse a single embedded document and generate a hash.
- Dont suport multikey indexes.

### TTL Index

Create index that auto-evict documents, checking a `date` or a `[date]` field.

- Cannot be a compound index.
- If created in background, Mongo can remove documents while creating the index.
- If created in foreground, Mongo will remove documents as soon it finish to create the index.
- Deletion task run every 60 seconds.
- Deletion depends on the load of the server. 
- Replica set delete documents only on primary, secondaries have this job idle.
- Cannot be applied to `Capped Collections`.
- You have to use the `collMod` command to modify the `expireAfterSeconds` or recreate the index.
- Cannot declare a TTL index over a single field thar have an index already.

```js
db.eventlog.createIndex( { "lastModifiedDate": 1 }, { expireAfterSeconds: 3600 } )
```

### Unique index

- Can be single, compound or multikey.
- Be aware of combinations of multikeys.
- Hashed keys cannot be unique.
- To create an index on a replica set issue `db.collection.createIndex()` on primary
- To create an index on a sharded cluster `db.collection.createIndex()` on a `mongos`
- To create an index via `rolling procedure` you must stop all writes on affected collection.
- Missing fields will be treated as `null` with a duplicate key constraint if trying to insert the same combination of null fields.
- Can be partials.

### Partial Index

- Accepts the following expressions: `$exists`, `$gt`, `$gte`, `$lt`, `$lte`, `$type`, `$and`.
- The infex can be on a field and the filter on another field(s)
- Can be unique, but the uniqueness only will be checked if the inserted document meets the filter criteria.

```js
db.restaurants.createIndex(
   { cuisine: 1, name: 1 },
   { partialFilterExpression: { rating: { $gt: 5 } } }
)
```

For this index,the following query will use the index, as will return a complete resultset, (the result is inside the subset of the filter in the partial specification)

```js
db.restaurants.find( { cuisine: "Italian", rating: { $gte: 8 } } )
```

Likewise, the following query will `NOT`use the index, as using the index results in an incomplete resultset.

```js
db.restaurants.find( { cuisine: "Italian", rating: { $lt: 8 } } )
```

### Insensitive Case Index

- If collation strenght is <= 2, the index or collection collation will be case insensitive.

```js
db.createCollection("fruit")

db.fruit.createIndex( { type: 1},
                      { collation: { locale: 'en', strength: 2 } } )
```


```js
db.people.createIndex( { zipcode: 1 }, { background: true } )
```

- Default limit on memory usage for a createIndexes operation is 500 megabytes
- If a `background` index is interrupted by a `mongod` termination, it will resume as `foreground` when `mongod` brings up.
- On **Replica Sets or Sharded Clusters**
    - On `foreground` the replication worker will take a global DB lock on `all databases`.
    - On `background` no lock will be taken.
    - Secondaries will be replicated afted primary finish.
- Interrupt a index creation is possible via `db.killOp()` but cannot be immediate and may occur after index completion.
    - When the index has begun the replication on secondaries it cannot be interrupted. 
- `rolling` Index build:
    - Stop each secondary, Start `standalone` ouside the replica set on another port, create the index, start it again inside the replica set.
    - `rs.stepDown()` the primary, once elections took place, stop the stepped down node, Start `standalone` ouside the replica set on another port, create the index, start it again inside the replica set.

### Index Intersection

Mongo can use two or more indexes to satisfy a query, this include index prefix intersections.

- Mongo cannot intersect indexes if a `$sort` operation uses a index outside the predicate, the sort stage must use one of the intersected indexes.

```js
// THESE TWO INDEXES:
{ qty: 1 }
{ item: 1 }

// CAN SATISFY THIS QUERY
db.orders.find( { item: "abc123", qty: { $gt: 15 } } )
```

- `explain()` will include either an `AND_SORTED` stage or an `AND_HASH` stage.


### Notes & limitations

- A Sort by a Multikey index will cause a blocking operation.
- Cannot create a compound `hashed` index.
- Cannot create a compound multikey index with more than one field being an array. Also, cannot add a document if violates this rule.
- A multikey index cannot be a shard key index.
- A hashed index cannot be multikey.
- Multikey index cannot cover queries over array fields.
- Creating an index in `foreground` on a populated collection `will block` the database containing the collection.
- If database needs to be available consider using `background` index creation. The shell / connetion where this background operation is issued will be blocked until it finish.
- To get index statistics you can use: `db.orders.aggregate( [ { $indexStats: { } } ] )` 
- Using a find with `.hint( { $natural: 1 } )` prevents Mongo using `any` index.
- Create Indexes to Support Your Queries
- Use Indexes to Sort Query Results
- Ensure Indexes Fit in RAM
- Create Queries that Ensure Selectivity 

#### Important Metrics

- serverStatus `db.runCommand({serverStatus: 1})`
    - metrics.queryExecutor.scanned
    - metrics.operation.scanAndOrder
- collStats `db.runCommand({collStats: "bios"})`
    - totalIndexSize
    - indexSizes
- dbStats `db.runCommand({"dbStats":1)`
    - dbStats.indexes
    - dbStats.indexSize

### Prefixes

Index prefixes are the beginning subsets of indexed fields. Queries can use an index if use part of the prefix of an index.

You can remove single indexes that contains prefixes of another more complex index.

---

## Security

- Trusted environment
- Mongodb authentication
    - Auth (client access)
    - Keyfile (intra cluster)
- Access Control
- Encryption
- Network Setup
- Audity

### Authentication

#### Creating Users

- When create a user you add to a specific database, and it will be the authentication database.

#### Authentication

- Use the mongo command-line authentication options (`--username`, `--password`, and `--authenticationDatabase`) when connecting to the mongod or mongos instance.
- Connect first to the mongod or mongos instance, and then run the authenticate command or the db.auth() method against the authentication database.

---

- Authorization
    - Role-Based Access Control
    - Enable Access Control
    - Manage Users and Roles
- TLS/SSL
    - TLS/SSL (Transport Encryption)
    - Configure mongod and mongos for TLS/SSL
    - TLS/SSL Configuration for Clients
- Enterprise Only
    - Kerberos Authentication
    - LDAP Proxy Authentication
    - Encryption at Rest
    - Auditing

---

**Authentication Methods**

- SCRAM (default, username & password): Supports `SCRAM-SHA-1` & `SCRAM-SHA-256`
- x.509: To authenticate using x.509 client certificate, include the `--ssl` and `--sslPEMKeyFile` parameters.
    - A single Certificate Authority (CA) must issue all the x.509 certificates.
    - The Organization attributes (O’s), the Organizational Unit attributes (OU’s), and the Domain Components (DC’s) must match those from the certificates for the other cluster members.
    - Each member of the cluster must have `--clusterAuthMode` and `--sslClusterFile` parameters.
    

```js
db.getSiblingDB("$external").auth({ mechanism: "MONGODB-X509" })
```

**SSL Modes**

| SSL MODE |  DESCRIPTION |
| -- | -- |
| disabled      | The server does not use TLS/SSL. |
| allowSSL      | Connections between servers do not use TLS/SSL. For incoming connections, the server accepts both TLS/SSL and non-TLS/non-SSL. |
| preferSSL     | Connections between servers use TLS/SSL. For incoming connections, the server accepts both TLS/SSL and non-TLS/non-SSL. |
| requireSSL    | The server uses and accepts only TLS/SSL encrypted connections. |

Example of valid Certificates Attributes.

```js 
CN=host1,OU=Dept1,O=MongoDB,ST=NY,C=US
C=US, ST=CA, O=MongoDB, OU=Dept1, CN=host2
```

#### Internal Authentication with KEYFILE

- Create a random string file.

Generate a keyfile

```sh
touch keyfile
chmod 600 keyfile
openssl rand -base64 60 >> keyfile
```

- Add `--auth --keyFile .\keyfile` to every `mongod` call on the cluster
- Add `--keyFile .\keyfile` to every `mongos` call on the cluster

***Rolling the keyfile with no downtime***

- Copy the keyfile to each replica set member.
- Start all `mongod` instances with `--keyFile` paramenter.
- For running replica sets:
    - Restart each secondary one by one with `--transitionToAuth` to allow both authenticated and non-authenticated connections while implementing auth on an existens replica set.
    - Step down primary, `rs.stepDown()` and restart with `--transitionToAuth`
    - Restart each secondary one by one **WITHOUT** `--transitionToAuth` 
    - Step down the actual primary, `rs.stepDown()` and restart **WITHOUT** `--transitionToAuth`
- For running Sharded
    - Restart each `mongos` one by one with with `--keyFile` and `--transitionToAuth`
    - Apply changes to each shard according to a replica set instructions.

#### Internal Authentication with x.509

Starting a x.509 Authenticated cluster:

```sh
$ mongod --replSet <name> --sslMode requireSSL --clusterAuthMode x509 \
--sslClusterFile <file.pem> --sslPEMKeyFile <path to TLS/SSL and key PEM file> \
--sslCAFile <CA_PEM_file> --bind_ip <ip address(es)>
```

Authenticate with a x.509 certificate:

```sh
$ mongo --ssl --sslPEMKeyFile <path to CA signed client PEM file> --sslCAFile <path to root CA PEM file>  --authenticationDatabase '$external' --authenticationMechanism MONGODB-X509
```


### Role based Access Control

- Mongo should be initialized with `--auth` flag to use Role Based Access Control.
- Roles grant privileges to `actions` on `resources`. Either explicit specified or inherited.
- Roles can inherit all privileges specified by another role. 

```
db.grantPrivilegesToRole(rolename, privileges, writeConcern) 
db.grantRolesToRole(rolename, roles, writeConcern) 
db.grantRolesToUser(username, roles, writeConcern)

db.revokePrivilegesFromRole(rolename, privileges, writeConcern) 
db.revokeRolesFromRole(rolename, roles, writeConcern) 
db.revokeRolesFromUser(username, roles, writeConcern)
```

#### Database Administration Roles

The database administration roles we can use are the following:

- dbAdmin – Grant privileges to perform administrative tasks
- userAdmin – Allows you to create and modify users and roles on the current database
- dbOwner – This role combines the following:
    - readWrite
    - dbAdmin
    - userAdmin

#### Cluster Administration Roles

Roles at the admin database for administering the whole system.

- clusterMonitor – Provides read-only access to monitoring tools
- clusterManager – For management and monitoring actions on the cluster
- hostManager – To monitor and manage servers
- clusterAdmin – Combines the other three roles plus dropDatabase action

#### Backup and Restoration Roles

This role belongs to the admin database.

- backup – Provides the privileges needed for backing up data
- restore – Provides the privileges needed to restore data from backups

#### All-Database Roles

These roles lie on the admin database and provide privileges which apply to all databases.

- readAnyDatabase – The same as ‘read’ role but applies to all databases
- readWriteAnyDatabase – The same as ‘readWrite’ role but applies to all databases
- userAdminAnyDatabase – The same as ‘userAdmin’ role but applies to all databases
- dbAdminAnyDatabase – The same as ‘dbAdmin’ role but applies to all databases

#### Superuser Roles

The following roles are not superuser roles directly but are able to assign any user any privilege on any database, also themselves.

- userAdmin
- dbOwner
- userAdminAnyDatabase

### Configuring Basic authentication

To initialize authentication you must add `--auth` to mongod and `mongos` 

```sh
./bin/mongod.exe --dbpath ./dataAuth/ --auth
```

Open a localhost console and perform the following operations to create first root user:

```js
// Set to administrative database
use admin

// Create an user
var me = {
    user: "lchacon",
    pwd: "123456789",
    roles: ["clusterAdmin", "userAdminAnyDatabase", "readWriteAnyDatabase", "dbAdminAnyDatabase"]
}
var me = {
    user: "testuser2",
    pwd: "123456789",
    roles: ["readWrite"]
}
var me = {
    user: "lchacon",
    pwd: "123456789",
    roles: ["clusterAdmin", "userAdminAnyDatabase", "readWriteAnyDatabase", "dbAdminAnyDatabase"]
}

var me = {
    user: "testuser2",
    pwd: "123456789",
    roles: ["readWrite"]
}
db.createUser(me)
```

Re-login

```sh
mongo localhost/admin -u lchacon -p 123456789
```

#### Change user password 

```js
$ mongo --port 27017 -u myUserAdmin -p 'abc123' --authenticationDatabase 'admin'

db.changeUserPassword("reporting", "SOh3TbYhxuLiW8ypJPxmt1oOfL")
```

----

### TLS/SSL

- Mongo accept TLS/SSL cyphers with a 128bit **minimum** key length for all connections.
- You must have PEM files.
- Can use any valid TLS/SSL certificates. Self-signed or CA signed. 


## REPLICATION

- Collections on **local** database are not replicated.
- Oplog size is 50MB-50GB for in memory, 990MB-50GB for WiredTiger

You can use the commands `replSetResizeOplog` and `oplogSizeMB` to see and change the OpLog Size.

- The `--slowms` is 100ms by default.
- To recover from transient network or operation failures, initial sync has built-in retry logic.
- Initial sync Clones all databases except `local` database.
- While applying a batch, MongoDB blocks all read operations. As a result, secondary read queries can never return data that reflect a state that never existed on the primary.
- Adding a member to the replica set does not always increase the fault tolerance.

### Comapct oplog for recovering space

- The replica set member cannot replicate oplog entries while the compact operation is ongoing.
- Do not run compact against the primary replica set member. 

```js
use local
db.runCommand({ "compact" : "oplog.rs" } )
``` 


### Index creation

**Notes:**

- `_id` is automatic and unique.
- Other than `_id` should be explicit.
- Keys can be any type.
- Automatically used, no hints needed.
- Can index arrays
- `dropDups` options are not enabled on Mongo > 3

Get indexes in a collection

```js
db.collection.getIndexes()
```

Single field, (no matter if the field is a full document)

```js
db.collection.ensureIndex({
    field: order
});
```

Background index creation

> - **Non blocking on primary.**
> - Time consuming, resource consuming, slower than foreground.
> - In secondary is always done in foreground and *is blocking*.

```js
db.collection.ensureIndex({
    field: order
}, {
    background: true
});
```

### Subfield

```js
db.collection.ensureIndex({
    "field.subfield": order
})
```

### Unique

```js
db.collection.ensureIndex({
    field: order
}, {
    unique: boolean
});
```

Field that are rare or not common should be created like this for performance reasons

```js
db.collection.ensureIndex({
    field: order
}, {
    sparse: boolean
});
```

### Geospatial 

This are always sparce by default, given the followind doc:

```js
{
    "_id": ObjectId("9999"),
    "loc": [40.75, -73.98]
}
```

The index greation could be

```js
db.collection.ensureIndex({
    geofield: geooption
});
```

### Full Text indexes

```js
db.collection.ensureIndex({
    field1: "text",
    "field2.subfield": "text"
}, {
    name: "MyIndex"
});
```

Full Text indexes with weights

```js
db.collection.ensureIndex({
    content: "text",
    keywords: "text"
}, {
    weights: {
        content: 10,
        keywords: 5
    },
    name: "MyIndex"
});
```

## Index Deletion

Remove a standard Index

> You have to delete it specifying the exact way it was built

```js
db.collection.dropIndex({
    field: order
});
```

Remove a fulltext Index

> You have to delete it specifying name

```js
db.collection.dropIndex("MyIndex");
```

> `order` : 1 ASC, -1 DESC

> `geooption` : "2dsphere", "2d"

> `boolean` : [true / false]


### Mongo statistics

```shell
mongostat
mongotop
```

## Replication

- Minimum 3 members, 1 Primary, 2 Secondary or 1 Primary, 1 Secondary, 1 Arbiter (vote only)
- Asyncronous
- Automatic failover
- Automatic node recovery after failure
- Not instantaneous but is 10 secs

Start locally the processes

```batch
.\bin\mongod.exe --replSet abc --dbpath ./data/a --port 27001 --bind_ip 0.0.0.0 --oplogSize 50
.\bin\mongod.exe --replSet abc --dbpath ./data/b --port 27002 --bind_ip 0.0.0.0 --oplogSize 50
.\bin\mongod.exe --replSet abc --dbpath ./data/c --port 27003 --bind_ip 0.0.0.0 --oplogSize 50
```

Initialize the repset

- Specify config
- Initial data
- Dont use ip-addresses
- Dont use /etc/hosts 
- Use DNS and an appropiate TTL

Connect to the first node and run to make a 1 PRIM 2 SEC Repset:

```js
cfg = {
    _id: "abc",
    members: [{
            _id: 0,
            host: "localhost:27001"
        },
        {
            _id: 1,
            host: "localhost:27002"
        },
        {
            _id: 2,
            host: "localhost:27003"
        },
    ]
}
// Initiate replicaset
rs.initiate(cfg)
```

Connect to the first node and run to make a 1 PRIM 1 SEC 1 Arbiter Repset:

```js
cfg = {
    _id: "abc",
    members: [{
            _id: 0,
            host: "localhost:27001",
            priority: 1
        },
        {
            _id: 1,
            host: "localhost:27002",
            priority: 0.5
        },
        {
            _id: 2,
            host: "localhost:27003",
            arbiterOnly: true
        },
    ]
}
// Initiate replicaset
rs.initiate(cfg)
```

### Reconfiguring the replica set 

To check the actual configuration: 

```js
rs.conf()
cfg = rs.conf()
cfg.members[2].slaveDelay = NumberLong(300)
cfg.members[2].priority = 0
rs.reconfig(cfg)
```

 

### Cluster wide commits

- Write is true when commited from majority of the replica set
- We can get acknowledgment of this

### The `w` parameter

- This defines how much servers should have acknowledged commit

```js
db.runCommand({
    getLastError: 1,
    w: 1
})
db.runCommand({
    getLastError: 1,
    w: 'majority'
})
```

## Sharding

### Initialize Config Servers

Initialize `AuxisRepSetCfg` , initialize the config servers replica set, connect to one of the config servers and do:

```js
cfg = {
    _id: "AuxisRepSetCfg",
    configsvr: true,
    members: [{
            _id: 0,
            host: "localhost:27101",
            priority: 1
        },
        {
            _id: 1,
            host: "localhost:27102",
            priority: 0.5
        },
        {
            _id: 2,
            host: "localhost:27103",
            priority: 0.5
        },
    ]
}
// Initiate replicaset
rs.initiate(cfg)
```

### Initialize shard replicas

Initialize the shard replicas connecting to one of the servers on shard replica set, and do:

Initialize `AuxisRepSetShard1` 

```js
cfg = {
    _id: "AuxisRepSetShard1",
    members: [{
            _id: 0,
            host: "localhost:27001",
            priority: 1
        },
        {
            _id: 1,
            host: "localhost:27002",
            priority: 0.5
        },
        {
            _id: 2,
            host: "localhost:27003",
            priority: 0.5
        },
    ]
}
// Initiate replicaset
rs.initiate(cfg)
```

Initialize `AuxisRepSetShard2` 

```js
cfg = {
    _id: "AuxisRepSetShard2",
    members: [{
            _id: 0,
            host: "localhost:27011",
            priority: 1
        },
        {
            _id: 1,
            host: "localhost:27012",
            priority: 0.5
        },
        {
            _id: 2,
            host: "localhost:27013",
            priority: 0.5
        },
    ]
}
// Initiate replicaset
rs.initiate(cfg)
```

Initialize `AuxisRepSetShard3` 

```js
cfg = {
    _id: "AuxisRepSetShard3",
    members: [{
            _id: 0,
            host: "localhost:27021",
            priority: 1
        },
        {
            _id: 1,
            host: "localhost:27022",
            priority: 0.5
        },
        {
            _id: 2,
            host: "localhost:27023",
            priority: 0.5
        },
    ]
}
// Initiate replicaset
rs.initiate(cfg)
```

Initialize `AuxisRepSetShard4` 

```js
cfg = {
    _id: "AuxisRepSetShard4",
    members: [{
            _id: 0,
            host: "localhost:27031",
            priority: 1
        },
        {
            _id: 1,
            host: "localhost:27032",
            priority: 0.5
        },
        {
            _id: 2,
            host: "localhost:27033",
            priority: 0.5
        },
    ]
}
// Initiate replicaset
rs.initiate(cfg)
```

### Add Shards to mongos

Add the shards to the mongos, connect to default port and add the shards throug its first member:

```js
sh.addShard("AuxisRepSetShard1/localhost:27001");
sh.addShard("AuxisRepSetShard2/localhost:27011");
sh.addShard("AuxisRepSetShard3/localhost:27021");
sh.addShard("AuxisRepSetShard4/localhost:27031");
```

Check status:

```js
mongos > sh.status()

{
    sharding version: {
        "_id": 1,
        "minCompatibleVersion": 5,
        "currentVersion": 6,
        "clusterId": ObjectId("5cf59e8280db52a5b1cce851")
    }
    shards: {
        "_id": "AuxisRepSetShard1",
        "host": "AuxisRepSetShard1/localhost:27001,localhost:27002,localhost:27003",
        "state": 1
    } {
        "_id": "AuxisRepSetShard2",
        "host": "AuxisRepSetShard2/localhost:27011,localhost:27012,localhost:27013",
        "state": 1
    } {
        "_id": "AuxisRepSetShard3",
        "host": "AuxisRepSetShard3/localhost:27021,localhost:27022,localhost:27023",
        "state": 1
    } {
        "_id": "AuxisRepSetShard4",
        "host": "AuxisRepSetShard4/localhost:27031,localhost:27032,localhost:27033",
        "state": 1
    }
    active mongoses:
        "4.0.10": 3
    autosplit:
        Currently enabled: yes
    balancer:
        Currently enabled: yes
    Currently running: no
    Failed balancer rounds in last 5 attempts: 0
    Migration Results
    for the last 24 hours:
        No recent migrations
    databases: {
        "_id": "config",
        "primary": "config",
        "partitioned": true
    }
}

mongos > use config;
mongos > db.shards.find(); {
    "_id": "AuxisRepSetShard1",
    "host": "AuxisRepSetShard1/localhost:27001,localhost:27002,localhost:27003",
    "state": 1
} {
    "_id": "AuxisRepSetShard2",
    "host": "AuxisRepSetShard2/localhost:27011,localhost:27012,localhost:27013",
    "state": 1
} {
    "_id": "AuxisRepSetShard3",
    "host": "AuxisRepSetShard3/localhost:27021,localhost:27022,localhost:27023",
    "state": 1
} {
    "_id": "AuxisRepSetShard4",
    "host": "AuxisRepSetShard4/localhost:27031,localhost:27032,localhost:27033",
    "state": 1
}
```

### Sharding a collection

Enable database sharding:

```js
sh.enableSharding("test")
sh.shardCollection("test.prueba", {
        _id: 'hashed'
    }, false)

    // you will see it on sh.status()
    ...{
        "_id": "test",
        "primary": "AuxisRepSetShard2",
        "partitioned": true,
        "version": {
            "uuid": UUID("26d85361-2314-42a3-bd2d-7915cf14b095"),
            "lastMod": 1
        }
    }
    ...
```

## db.serverStatus( )

**IMPORTANT!**

By default, serverStatus excludes in its output some content in the repl document.

see: https://docs.mongodb.com/manual/reference/command/serverStatus/

## Backup

### Methods

- mogodump / mongorestore
- filesystem snapshot ( Journaling required )
- backup from secondary
    - shutdown
    - copy files
    - restart

### For single servers

```sh
// Dump
mongodump

// Restore
mongorestore
```

 

### For sharded cluster

- Turn off the balancer
    - `sh.stopBalancer()` 

```sh
mongo --host some_mongos --eval "sh.stopBalancer()"
```

- Backup configdb
    - `mongodump --db config` 

```sh
mongodump --host some_mongos_or_config_server --db config /backup/configdb
```

- Backup each shard ReplSet

```sh
mongodump --host shard1_srv1 --oplog /backup/shard1
mongodump --host shard2_srv1 --oplog /backup/shard2
mongodump --host shard3_srv1 --oplog /backup/shard3
```

- Turn on the balancer
    - `sh.startBalancer()` 

```sh
mongo --host some_mongos --eval "sh.startBalancer()"
```

```sh
// Dump
mongodump --oplog

// Restore
mongorestore --oplogReplay
```

 

## MongoDB Debug 

- mongostats
- mongotop
- mongoreplay
- mogo 

querys oplgogs
wiredtiger engine
sharding constraints and indexes
pre-split data on shards
backups - sharding backups
import - export
ssl and keystore

## PDF 2nd Edition

http://usuaris.tinet.cat/bertolin/pdfs/mongodb_%20the%20definitive%20guide%20-%20kristina%20chodorow_1401.pdf

M312 MongoDb
https://www.youtube.com/playlist?list=PL848tmGuwg9hWvZ6QETJQ-bGfSrN6YAte

https://www.sanfoundry.com/1000-mongodb-questions-answers/

https://github.com/ozlerhakan/mongodb-json-files