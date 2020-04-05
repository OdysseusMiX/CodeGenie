classdef TestRefactor < matlab.unittest.TestCase
    
    properties
        oldpath
        startDir
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.oldpath = addpath(cd);
            testCase.startDir = cd;
            cd('+Tests/TestRefactorFixture')
        end
    end
    methods (TestMethodTeardown)
        function tearDown(testCase)
            cd(testCase.startDir)
            path(testCase.oldpath)
        end
    end
    
    methods (Test)
        function testExtractFunction_explicitFunction_noParameters(testCase)
            testFile = 'testFile.m';
            copyfile('printOwing_initial.m',testFile);
                        
            Refactor.extractFunction(testFile);
            
            txtExpected = readfile('printOwing_step1.m');            
            txtActual = readfile(testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
            
            delete(testFile);
        end
        
        function testExtractFunction_toNestedFunction(testCase)
            testFile = 'testFile.m';
            copyfile('printOwing_step2_before.m',testFile);
            
            Refactor.extractFunction(testFile);
            
            txtExpected = readfile('printOwing_step2_after.m');            
            txtActual = readfile(testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
            
            delete(testFile);
        end
    end
    
end

