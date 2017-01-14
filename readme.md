# owlchain 
owlchain is a blockchain for trust contracts. owlchain aims to use the Web Ontology Language(OWL) and Timed Automata Language(TAL) to expand expressive power while retaining decidability to support secure and precise execution of contracts. These OWL based contracts on the owlchain are referred to as Trust Contracts
![TrustContract](https://github.com/owlchain/owlchain-core/blob/PoC0/docs/images/TrustContract.png?raw=true)

### prerequisite
owlchain use [d programming language](http://dlang.org/) and [dub](https://code.dlang.org/) build toolkit.

### build 

```
$ git clone https://github.com/owlchain/owlchain-core
$ cd owlchain-core
$ dub -v
```

### owlchain-core architecture & source directory

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

## Schedule 

### poc0
    goal: money transfering poc and event/data flow PoC with FBA consensus
    term: 1월 말
    deliveries: poc0 코드, 전체 이벤트/데이타 흐름 설명서, 1회 데모 설명회
    participant : 1인(나? 혼자 ~~~)
  PoC0 - remittance event/data process diagram
  ![remittance event process diagram](https://github.com/owlchain/owlchain-core/blob/PoC0/docs/images/Remmitance%20Process.png?raw=true)

### poc1
    goal: UX통합, mFBA 컨센서스 모델 개념증명
    term: 2월 중순
    deliveries: 코드, 개념증명 설명서, 1회 데모 설명회
    participant : 3인


### alpha
    goal: 테스트 넷 가동, 네트워크 배포 프로세스 자동화 & 모니터 시스템 개념 증명
    term: 2월 말
    deliveries: 코드, 개념증명 설명서, 1회 데모 설명회
    participant : 5인

### beta
    goal: 네트워크 배포 프로세스 자동화 & 모니터링 시스템 개발 
    term: 3월 중순
    deliveries: 코드, 개념증명 설명서, 1회 데모 설명회
    participant : 5인

### release
    goal: 제네시스 블록 생성 & Production 네트워크 가동
    term: 3월 말
    deliveries: 코드, 개념증명 설명서, 1회 데모 설명회
    participant : 7인


