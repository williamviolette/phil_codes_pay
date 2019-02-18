function tests = num2sepstrTest
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testCase.TestData.orig_path = path();
% On my install, the perl script called in restoredefaultpath.m finds the
% stateflow folder twice. I don't know why but it throws an annoying
% warning.
state = warning('off','MATLAB:dispatcher:pathWarning');
restoredefaultpath()
warning(state)
end
function teardownOnce(testCase)
path(testCase.TestData.orig_path)
end

function testGeneric(testCase)
verifyEqual(testCase,num2sepstr(1000),'1,000')
verifyEqual(testCase,num2sepstr(1234.5),'1,234.5') % trims trailing zeros with auto format
verifyEqual(testCase,num2sepstr(1234.5,'%f'),'1,234.500000') % but not when format is specified
verifyEqual(testCase,num2sepstr(1234.5,'%.2f'),'1,234.50')
verifyEqual(testCase,num2sepstr(1234.5,'%.4f'),'1,234.5000')
verifyEqual(testCase,num2sepstr(123456789.5,'%.0f'),'123,456,790')
end
function testSep(testCase)
verifyEqual(testCase,num2sepstr(1234.5,'%f',':'),'1:234.500000')
verifyEqual(testCase,num2sepstr(1234.5,'%.2f','#'),'1#234.50')
verifyEqual(testCase,num2sepstr(1234.5,'%.4f','separator!'),'1separator!234.5000')
verifyEqual(testCase,num2sepstr(123456789.5,'%.0f','_'),'123_456_790')
end
function testZero(testCase)
verifyEqual(testCase,num2sepstr(0),'0')
end
function testInteger(testCase)
verifyEqual(testCase,num2sepstr(1),'1')
verifyEqual(testCase,num2sepstr(-1),'-1')
verifyEqual(testCase,num2sepstr(100),'100')
verifyEqual(testCase,num2sepstr(-100),'-100')
end
function testNoCommas(testCase)
verifyEqual(testCase,num2sepstr(0),num2str(0))
verifyEqual(testCase,num2sepstr(1),num2str(1))
verifyEqual(testCase,num2sepstr(1.5),num2str(1.5))
verifyEqual(testCase,num2sepstr(pi),num2str(pi))
verifyEqual(testCase,num2sepstr(pi,'%.4f'),num2str(pi,'%.4f'))
verifyEqual(testCase,num2sepstr(pi,'%.8f'),num2str(pi,'%.8f'))
verifyEqual(testCase,num2sepstr(999),num2str(999))
verifyEqual(testCase,num2sepstr(999.99),num2str(999.99))
end
function testTrimZeros(testCase)
verifyEqual(testCase,num2sepstr(1),'1')
verifyEqual(testCase,num2sepstr(1234),'1,234')
verifyEqual(testCase,num2sepstr(1234.00001),'1,234')
verifyEqual(testCase,num2sepstr(1234.0100),'1,234.01')
verifyEqual(testCase,num2sepstr(1234.01001),'1,234.01')
end
function testFormatSpecfiers(testCase)
verifyEqual(testCase,num2sepstr(1234.6,'%.4f'),'1,234.6000')
verifyEqual(testCase,num2sepstr(1234.6,'%.0f'),'1,235')
verifyEqual(testCase,num2sepstr(1234.6,'%+.4f'),'+1,234.6000')
end
function testLongNumbers(testCase)
verifyEqual(testCase,num2sepstr(1234567890123456),'1,234,567,890,123,456')
verifyEqual(testCase,num2sepstr(1234567890123456,'%.0f'),'1,234,567,890,123,456')
verifyEqual(testCase,num2sepstr(12345678901234567890),'12,345,678,901,234,567,168')
verifyEqual(testCase,num2sepstr(12345678901234,'%.0f'),'12,345,678,901,234')
end
function testScientificNotation(testCase)
verifyEqual(testCase,num2sepstr(126,'%.0g'),num2str(126,'%.0g'))
verifyEqual(testCase,num2sepstr(126,'%.5g'),num2str(126,'%.5g'))
verifyEqual(testCase,num2sepstr(126,'%.0e'),num2str(126,'%.0e'))
verifyEqual(testCase,num2sepstr(126,'%.5e'),num2str(126,'%.5e'))
verifyEqual(testCase,num2sepstr(1235674786,'%.0g'),num2str(1235674786,'%.0g'))
end
function testComplexNumbers(testCase)
verifyEqual(testCase,num2sepstr(sqrt(-1e9),'%.2f'),'0.00+31,622.78i')
verifyEqual(testCase,num2sepstr(1e3*(-pi + exp(1)*1i)),'-3,141.5927+2,718.2818i')
verifyEqual(testCase,num2sepstr(1e3*(-pi + exp(1)*1i),'%.2f'),'-3,141.59+2,718.28i')
end
function testCellOutput(testCase)
verifyEqual(testCase,num2sepstr(magic(2)*1e6),{'1,000,000','3,000,000';'4,000,000','2,000,000'})
x = ones(1,2,3,4,5);
verifyEqual(testCase,size(num2sepstr(x)),size(x))
end
