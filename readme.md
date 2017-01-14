# owlchain 
owlchain is a blockchain for trust contracts.

## prerequisite
owlchain use [d programming language](http://dlang.org/) and [dub](https://code.dlang.org/) build toolkit.

## build 

```
$ git clone https://github.com/owlchain/owlchain-core
$ cd owlchain-core
$ dub -v
```

## owlchain-core source directory

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

### 일정 
```
Schedule { 
  poc0
    목표: 블록체인의 송금예제를 통해 이벤트/데이타 흐름을 프로세스 개념증명, FBA 컨센서스 모델 개념증명
    기간: 1월 말
    산출물: poc0 코드, 전체 이벤트/데이타 흐름 설명서, 1회 데모 설명회
    참여 인원 : 1인(나? 혼자 ~~~)

  poc1
    목표: UX통합, mFBA 컨센서스 모델 개념증명
    기간: 2월 중순
    산출물: 코드, 개념증명 설명서, 1회 데모 설명회
    참여 인원 : 3인

  alpha
    목표: 테스트 넷 가동, 네트워크 배포 프로세스 자동화 & 모니터 시스템 개념 증명
    기간: 2월 말
    산출물: 코드, 개념증명 설명서, 1회 데모 설명회
    참여 인원 : 5인

  beta
    목표: 네트워크 배포 프로세스 자동화 & 모니터링 시스템 개발 
    기간: 3월 중순
    산출물: 코드, 개념증명 설명서, 1회 데모 설명회
    참여 인원 : 5인

  release
    목표: 제네시스 블록 생성 & Production 네트워크 가동
    기간: 3월 말
    산출물: 코드, 개념증명 설명서, 1회 데모 설명회
    참여 인원 : 7인
}

```
PoC 0 - Remittance event process diagram
  ![remittance event process diagram](https://github.com/owlchain/owlchain-core/blob/PoC0/docs/images/Remmitance%20Process.png?raw=true)
