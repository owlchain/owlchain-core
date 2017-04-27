# owlchain addressing and identification name system

owlchain name system refer to 
[Escaping the Evils of Centralized Control with self-certifying pathnames](http://www.sigops.org/ew-history/1998/papers/mazieres.ps),
[SFS namespace](https://web.archive.org/web/20080725193436/http://www.fs.net/sfswww/sfsfaq.html)

base58-check encode
double-hash is RIPEMD160(SHA256(K))

- account id
- transaction(tx) id
- block id
- namespace
    - owl id 
    - tal id
- node id
- quorum id

```
/[ontology]/[hash of public key]/path/to

/owlchain/520dda64646c17a28b9eec232ff89eddbf9fddc9/account/
/owlchain/520dda64646c17a28b9eec232ff89eddbf9fddc9/tx/
/owlchain/520dda64646c17a28b9eec232ff89eddbf9fddc9/tal/
/owlchain/520dda64646c17a28b9eec232ff89eddbf9fddc9/owl/

/BOScoin/610e987a0ff3cb28e40559e11ed120144af9e9da/account/
/BOScoin/610e987a0ff3cb28e40559e11ed120144af9e9da/tx/
/BOScoin/610e987a0ff3cb28e40559e11ed120144af9e9da/tal/
/BOScoin/610e987a0ff3cb28e40559e11ed120144af9e9da/owl/

/stardaq/15bb87ae8ccc5f7e48cf8354d205c6574a4169cf/account/
/stardaq/15bb87ae8ccc5f7e48cf8354d205c6574a4169cf/tx/
/stardaq/15bb87ae8ccc5f7e48cf8354d205c6574a4169cf/tal/
/stardaq/15bb87ae8ccc5f7e48cf8354d205c6574a4169cf/owl/
```


