import std.stdio;
import owlchain.consensus.tests.quorumSetTest;
import owlchain.consensus.tests.cpUnitTests;
import owlchain.consensus.tests.arrayTest;
import owlchain.consensus.tests.cpTests;
import owlchain.xdr.tests.streamTest;
import std.experimental.logger;
import std.system;

static if ((os == OS.win32) || (os == OS.win64))
{

void main()
{
    QuorumSetTest quorumSetTest;
    quorumSetTest = new QuorumSetTest();
    quorumSetTest.prepare();
	quorumSetTest.test();

    /*
    ArrayTest arrayTest;
    arrayTest = new ArrayTest();
    arrayTest.prepare();
	arrayTest.test();

    CPUnitTest cpUnitTest;
    cpUnitTest = new CPUnitTest();
    cpUnitTest.prepare();
	cpUnitTest.test();
*/
    ConsensusProtocolTest cpTest;
    cpTest = new ConsensusProtocolTest();
    cpTest.prepare();
	cpTest.test();


//    StreamTest streamTest;
//    streamTest = new StreamTest();
//    streamTest.prepare();
//    streamTest.test();

}

}