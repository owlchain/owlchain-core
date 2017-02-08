Owlchain Data API
===============
> Some API calls are available with [CORS headers](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) if you add a &cors=true parameter to the GET request



Single Block
-----------------
- https://owlchain.info/ko/rawblock/$block_index
- https://owlchain.info/ko/rawblock/$block_hash
- https://owlchain.info/ko/block-index/$block_index?format=json
```
{
    "hash":"0000000000000bae09a7a393a8acded75aa67e46cb81f7acaa5ad94f9eacd103",
    "ver":1,
    "prev_block":"00000000000007d0f98d9edca880a6c124e25095712df8952e0439ac7409738a",
    "mrkl_root":"935aa0ed2e29a4b81e0c995c39e06995ecce7ddbebb26ed32d550a72e8200bf5",
    "time":1322131230,
    "bits":437129626,
    "nonce":2964215930,
    "n_tx":22,
    "size":9195,
    "block_index":818044,
    "main_chain":true,
    "height":154595,
    "received_time":1322131301,
    "relayed_by":"108.60.208.156",
    "tx":[--Array of Transactions--]
}
```

Single Transaction
-----------------
- https://owlchain.info/ko/rawtx/$tx_index
- https://owlchain.info/ko/rawtx/$tx_hash
- https://owlchain.info/ko/tx-index/$tx_index?format=json
- Optional scripts boolean parameter to include the input and output scripts e.g. &scripts=true

- You can also request the transaction in binary form (Hex encoded) using ?format=hex
```
{
    "hash":"b6f6991d03df0e2e04dafffcd6bc418aac66049e2cd74b80f14ac86db1e3f0da",
    "ver":1,
    "vin_sz":1,
    "vout_sz":2,
    "lock_time":"Unavailable",
    "size":258,
    "relayed_by":"64.179.201.80",
    "block_height, 12200,
    "tx_index":"12563028",
    "inputs":[


            {
                "prev_out":{
                    "hash":"a3e2bcc9a5f776112497a32b05f4b9e5b2405ed9",
                    "value":"100000000",
                    "tx_index":"12554260",
                    "n":"2"
                },
                "script":"76a914641ad5051edd97029a003fe9efb29359fcee409d88ac"
            }

        ],
    "out":[

                {
                    "value":"98000000",
                    "hash":"29d6a3540acfa0a950bef2bfdc75cd51c24390fd",
                    "script":"76a914641ad5051edd97029a003fe9efb29359fcee409d88ac"
                },

                {
                    "value":"2000000",
                    "hash":"17b5038a413f5c5ee288caa64cfab35a0c01914e",
                    "script":"76a914641ad5051edd97029a003fe9efb29359fcee409d88ac"
                }

        ]
}
```

Chart Data
----------
- https://owlchain.info/ko/charts/$chart-type?format=json
```
{
    "values" : [
        {
            "x" : 1290602498, //Unix timestamp
            "y" : 1309696.2116000003
        }]
}
```

Block Height
------------
- https://owlchain.info/ko/block-height/$block_height?format=json
```
{
    "blocks" :
    [
        --Array Of Blocks at the specified height--
    ]
}
```

Single Address
---------------
- https://owlchain.info/ko/address/$hash_160?format=json
- https://owlchain.info/ko/address/$bitcoin_address?format=json
- https://owlchain.info/ko/rawaddr/$bitcoin_address
- Optional limit parameter to show n transactions e.g. &limit=50 (Max 50)

- Optional offset parameter to skip the first n transactions e.g. &offset=100 (Page 2 for limit 50)
```
{
    "hash160":"660d4ef3a743e3e696ad990364e555c271ad504b",
    "address":"1AJbsFZ64EpEfS5UAjAfcUG8pH8Jn3rn1F",
    "n_tx":17,
    "n_unredeemed":2,
    "total_received":1031350000,
    "total_sent":931250000,
    "final_balance":100100000,
    "txs":[--Array of Transactions--]
}
```

Multi Address
--------------
- https://owlchain.info/ko/multiaddr?active=$address|$address (Multiple addresses divided by |)
```
{
    "addresses":[

    {
        "hash160":"641ad5051edd97029a003fe9efb29359fcee409d",
        "address":"1A8JiWcwvpY7tAopUkSnGuEYHmzGYfZPiq",
        "n_tx":4,
        "total_received":1401000000,
        "total_sent":1000000,
        "final_balance":1400000000
    },

    {
        "hash160":"ddbeb8b1a5d54975ee5779cf64573081a89710e5",
        "address":"1MDUoxL1bGvMxhuoDYx6i11ePytECAk9QK",
        "n_tx":0,
        "total_received":0,
        "total_sent":0,
        "final_balance":0
    },

    "txs":[--Latest 50 Transactions--]
}
```

Unspent outputs
---------------------
- https://owlchain.info/ko/unspent?active=$address
- Multiple Addresses Allowed separated by "|"
The tx hash is in reverse byte order. What this means is that in order to get the html transaction hash from the JSON tx hash for the following transaction, you need to decode the hex (using this site for example). This will produce a binary output, which you need to reverse (the last 8bits/1byte move to the front, second to last 8bits/1byte needs to be moved to second, etc.). Then once the reversed bytes are decoded, you will get the html transaction hash.
```
{
    "unspent_outputs":[
        {
            "tx_age":"1322659106",
            "tx_hash":"e6452a2cb71aa864aaa959e647e7a4726a22e640560f199f79b56b5502114c37",
            "tx_index":"12790219",
            "tx_output_n":"0",
            "script":"76a914641ad5051edd97029a003fe9efb29359fcee409d88ac", (Hex encoded)
            "value":"5000661330"
        }
    ]
}
```

Latest Block
------------
- https://owlchain.info/ko/latestblock
```
{
    "hash":"0000000000000538200a48202ca6340e983646ca088c7618ae82d68e0c76ef5a",
    "time":1325794737,
    "block_index":841841,
    "height":160778,
    "txIndexes":[13950369,13950510,13951472]
}
```

Unconfirmed Transactions
------------
- https://owlchain.info/ko/unconfirmed-transactions?format=json
```
{
    "txs":[--Array of Transactions--]
}
```

Blocks
------------
- Blocks for one day: https://owlchain.info/ko/blocks/$time_in_milliseconds?format=json
- Blocks for specific pool: https://owlchain.info/ko/blocks/$pool_name?format=json
```
{
    "blocks" : [
    {
        "height" : 166107,
        "hash" : "00000000000003823fa3667d833a354a437bdecf725f1358b17f949c991bfe0a",
        "time" : 1328830483
    },
    {
        "height" : 166104,
        "hash" : "00000000000008a34f292bfe3098b6eb40d9fd40db65d29dc0ee6fe5fa7d7995",
        "time" : 1328828041
    }]
}
```