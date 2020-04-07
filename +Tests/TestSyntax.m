classdef TestSyntax < matlab.unittest.TestCase
    
    properties
        oldpath
        startDir
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.oldpath = addpath(cd);
            testCase.startDir = cd;
            cd('+Tests/TestSyntaxFixture')
        end
    end
    methods (TestMethodTeardown)
        function tearDown(testCase)
            cd(testCase.startDir)
            path(testCase.oldpath)
        end
    end
    
    methods (Test)
        function testReadStatements(testCase)
            testFile = 'exampleScript.m';
            parser = Parser;
            
            tokens = parser.parse(readfile(testFile));
            statements = pa

            testCase.assertEqual(length(tokens), 28);
%             testCase.assertEqual(statements(1).string, '1');
%             testCase.assertEqual(statements(1).file, testFile);
%             testCase.assertEqual(statements(1).index, 2);
%             testCase.assertEqual(statements(2).index, 4);
%             testCase.assertEqual(statements(5).index, 11:13);
%             testCase.assertEqual(statements(5).line, 5);
%             testCase.assertEqual(statements(8).string, 'str = sprintf(''%s'',''something'')');
        end
    end
end