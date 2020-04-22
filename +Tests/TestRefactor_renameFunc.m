classdef TestRefactor_renameFunc < matlab.unittest.TestCase
    
    properties
        oldpath
        startDir
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.oldpath = addpath(cd);
            testCase.startDir = cd;
            cd('Example3')
        end
    end
    methods (TestMethodTeardown)
        function tearDown(testCase)
            cd(testCase.startDir)
            path(testCase.oldpath)
        end
    end
    
    methods (Test)
        function testFile_usesOnlySubfieldOfInput(testCase)
            copyfile('geometry_before.m','geometry.m');
                        
            Refactor.file('geometry.m');
            
            txtExpected = Parser.readFile('geometry_after.m');
            txtActual = Parser.readFile('geometry.m');
            testCase.assertEqual(txtActual, txtExpected);
            
            delete('geometry.m');
        end
    end
end