import std.stdio;
import owlchain.consensus.tests.quorumSetTest;
import owlchain.consensus.tests.cpUnitTests;
import owlchain.consensus.tests.arrayTest;
import owlchain.xdr.tests.streamTest;

void main()
{
    QuorumSetTest quorumSetTest;
    quorumSetTest = new QuorumSetTest();
    quorumSetTest.prepare();
	quorumSetTest.test();

    ArrayTest arrayTest;
    arrayTest = new ArrayTest();
    arrayTest.prepare();
	arrayTest.test();

    CPUnitTest cpUnitTest;
    cpUnitTest = new CPUnitTest();
    cpUnitTest.prepare();
	cpUnitTest.test();

/*
    StreamTest streamTest;
    streamTest = new StreamTest();
    streamTest.prepare();
    streamTest.test();
*/
}
