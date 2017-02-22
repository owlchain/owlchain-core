# Timed Automata Language(TAL) RFP

## TAL 요구사항 목차
    - TAL 요구사항
    - TAL 실행환경(Runtime Environment) 요구사항
    - TAL 개발환경(Development Environment) 요구사항
    - 개념 증명 프로젝트 방향

## TAL 요구사항 정의
    - 작성된 코드가 time automata modeling 검사/에러등을 알려 줄것
    - 실행 안정성을 제공하면서 네이티브 코드의 가까운 성능을 끌어낼 것  
    - 기존 프로젝트 개발언어(D 언어)의 개발자 친숙성을 기반으로 Timed Automata 제약사항을 추가하여 개발 (D언어 기반 Domain Specific Language - DSL)
    - 코드 예제
```
    @timedautomaton ITransaction execute(scope IOntology ontology, scope IBlockchain blockchain) pure
    {
        ... code ...
    }
```

## TAL Runtime environment

### 0.원칙
    - 실행 안정성과 성능의 균형
    - 각 기능 요구 사항간 레이어링 원칙 적용
    - 언어 요구 사항과 실행 환경(runtime) 요구사항 분리 구현

### 1.고려사항
    - 동일 온톨로지의 개체(individual)간에는 수직 의존성, 온톨로지가 다른 경우 동시에 여러개의 TAL 객체가 실행될 수 있음 -> 온톨로지별 트랜잭션 관리가 분리될 필요가 있음(1개의 블록체인에 온톨로지 고유번호를 부여하여 처리?)
    - 멀티프로세스 또는 멀티스레드 실행환경 제공

### 2.기존 기술 검토
    - javascript JIT compiler runtime : 실시간 파일 기술사용, 실행시에 자바스크립트 컴파일 수행 네이티브 코드에 가까운 성능 제공
    - java vm runtime: VM단에서 JIT 기술 사용
    - chrome browser NaCL/PNaCL : 네이티브 코드를 샌드박스 보안모델 내에서 실행, 특수 실행 환경 + 특수 컴파일러를 이용해서 구현

## 개념 증명 방향
    - TAL 운영환경 개념검증 후 언어 모델 추가 정의

## 참고문헌
    - https://developer.chrome.com/native-client/nacl-and-pnacl

