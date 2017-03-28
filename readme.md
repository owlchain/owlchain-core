# OWLchain - Protocol for Trust and Interconnected Knowledge

[![Build Status](https://travis-ci.org/owlchain/owlchain-core.svg?branch=PoC0)](https://travis-ci.org/owlchain/owlchain-core)
[![owlchain](https://img.shields.io/badge/irc-%23owlchain-brightgreen.svg)](https://webchat.freenode.net/?channels=owlchain)

## Table of Contents

  - [Overview](#overview)
    - [Quick Summary](#quick-summary)
    - [Specs](https://github.com/owlchain/specs)
    - [Dependency](#dependency)
    - [Installation](#installation)
  - [How OWLchain Works](#how-owlchain-works)
    - [OWLchain papers](#owlchain-papers)
    - [OWLchain Talks](#owlchain-talks)
  - [Project and Community](#project-and-community)
  - [Project Links](#project-links)
    - [Protocol Implementations](#protocol-implementations)
    - [API Client Libraries](#api-client-libraries)
    - [Project Directory](#project-directory)
    - [Other Community Resources](#other-community-resources)
  - [License](#license)

## Overview

### Quick Summary

OWLchain is a blockchain for trust contracts. OWLchain aims to use the Web Ontology Language(OWL) and Timed Automata Language(TAL) to expand expressive power while retaining decidability to support secure and precise execution of Smart Contracts. 

![TrustContract](https://github.com/owlchain/owlchain-core/blob/PoC0/docs/images/TrustContract.png?raw=true)

### Specs

The structure of OWLchain protocol looks briefly as follows : 
+ owlchain
  + consensus   - owlchain blockchain consensus protocol
  + p2p         - p2p network communication
  + reasoner    - Inference Engine for OWL 2.0 profile 
  + store       - data store using SQL and MessagePack
  + api         - rest api
  + transaction - transaction of vote, proposal and remittance
  + ui          - web application User interface for Owlchain
  + appmain.d   - boot up module 

To learn more about the specs of OWLchain's parts, please refer to the [Specs](https://github.com/owlchain/specs) repository.

### Dependency

Owlchain Protocol currently uses [d programming language](http://dlang.org/) and [dub](https://code.dlang.org/) build toolkit.

### Installation

To build and run OWLchain, please proceed as follows:
```
$ git clone https://github.com/owlchain/owlchain-core
$ cd owlchain-core
$ dub -v
```

## How OWLchain Works

To learn more about how OWLchain works take a look at the [Papers](#owlchain-papers) or [Talks](#owlchain-talks). You can also explore the [Specs](https://github.com/owlchain/specs) in writing.

### OWLchain Papers

- [OWLchain Technical Whitepaper(Comments are always welcomed!)](https://docs.google.com/document/d/19gfV6d1n3Ut0r72dDstplrbXhEpitXxhTlm-SQ3wcRY/edit?usp=sharing)
- [Repository for Related papers](https://github.com/owlchain/papers)

### OWLchain talks

- 2017-03-16 [@Blockchain Meetup Berlin](https://www.youtube.com/watch?v=PcQw1_yjQVc)

## Project and Community

The OWLchain is a open source project in need of contributions from various technophiles. You are invited and appriciated to join it! Create issues, contribute codes, translating documents, every single contribution will be appricated and respected here. 

Wondering on where to start? Check out our [waffle](https://waffle.io/owlchain) to check the current development status, progress, and milestones.

Also here are some links to our communication channels:

- IRC: [#owlchain on chat.freenode.net](http://webchat.freenode.net/?channels=owlchain) for live help and some dev discussions.
- Google Group: [dev-owlchain@groups.google.com](https://groups.google.com/forum/#!forum/dev-owlchain/)


## License

GPL-3.0
