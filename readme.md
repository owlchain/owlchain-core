# Owlchain (BOScoin)

[![Build Status](https://travis-ci.org/owlchain/owlchain-core.svg?branch=PoC0)](https://travis-ci.org/owlchain/owlchain-core)

Owlchain is a blockchain for trust contracts. owlchain aims to use the Web Ontology Language(OWL) and Timed Automata Language(TAL) to expand expressive power while retaining decidability to support secure and precise execution of contracts. These OWL based contracts on the owlchain are referred to as Trust Contracts. For more details, please refer to our [technical paper](https://docs.google.com/document/d/16Wm13pSvjb_izCB8QImMgHnt8VOlt0d5YSsPV6NDtaI/edit?usp=sharing)

![TrustContract](https://github.com/owlchain/owlchain-core/blob/PoC0/docs/images/TrustContract.png?raw=true)

### Prerequisite
Owlchain use [d programming language](http://dlang.org/) and [dub](https://code.dlang.org/) build toolkit.

### Build and run

```
$ git clone https://github.com/owlchain/owlchain-core
$ cd owlchain-core
$ dub -v
```

### Owlchain-core architecture & source directory

![architecture](https://github.com/owlchain/owlchain-core/blob/PoC0/docs/images/owlchain.png?raw=true)

owlchain-core
  + docs          - documentation of owlchain-core
  + source        - source directory
      + owlchain
        + consensus   - owlchain blockchain consensus protocol
        + p2p         - p2p network communication
        + reasoner    - Inference Engine for OWL 2.0 profile 
        + store       - data store using SQL and MessagePack
        + api         - rest api
        + transaction - transaction of vote, proposal and remittance
        + ui          - web application User interface for Owlchain
        + appmain.d   - boot up module 
  + dub.sdl       - project build file
  + readme.md     - this file
