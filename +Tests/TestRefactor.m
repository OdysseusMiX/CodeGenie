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
            
            txtExpected = Parser.readFile('printOwing_step1.m');            
            txtActual = Parser.readFile(testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
            
            delete(testFile);
        end
        
%         function testExtractFunction_toNestedFunction(testCase)
%             testFile = 'testFile.m';
%             copyfile('printOwing_step2_before.m',testFile);
%             
%             Refactor.extractFunction(testFile);
%             
%             txtExpected = Parser.readFile('printOwing_step2_after.m');            
%             txtActual = Parser.readFile(testFile);
%             
%             testCase.assertEqual(txtActual, txtExpected);
%             
%             delete(testFile);
%         end
    end
    
end

