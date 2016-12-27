# owlchain 
owlchain is a congressional decentralized blokchain for trust contracts.

#owlchain-core source directory

owlchain-core
  + docs          - documentation of owlchain-core
  + source        - source directory
      +owlchain
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
