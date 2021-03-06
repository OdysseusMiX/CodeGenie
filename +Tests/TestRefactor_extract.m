classdef TestRefactor_extract < matlab.unittest.TestCase
    
    properties
        oldpath
        startDir
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.oldpath = addpath(cd);
            testCase.startDir = cd;
            cd('Example1')
        end
    end
    methods (TestMethodTeardown)
        function tearDown(testCase)
            cd(testCase.startDir)
            path(testCase.oldpath)
        end
    end
    
    methods (Test)
%         function testFile_implicitFunction(testCase)
%             testCase.assertFail;
%         end
%         function testFile_tempIsReassignedBeforeuse(testCase)
%             testCase.assertFail;
%         end
        
        function testFile_explicitFunction_noParameters(testCase)
            testFile = 'testFile.m';
            copyfile('printOwing_step1_before.m',testFile);
                        
            Refactor.file(testFile);
            
            txtExpected = FileManager.readFile('printOwing_step1_after.m');            
            txtActual = FileManager.readFile(testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
            
            delete(testFile);
        end
        
        function testFile_toNestedFunction(testCase)
            testFile = 'testFile.m';
            copyfile('printOwing_step2_before.m',testFile);
            
            Refactor.file(testFile);
            
            txtExpected = FileManager.readFile('printOwing_step2_after.m');            
            txtActual = FileManager.readFile(testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
            
            delete(testFile);
        end
        
        function testFile_withReferencedParameters(testCase)
            testFile = 'testFile.m';
            copyfile('printOwing_step3_before.m',testFile);
            
            Refactor.file(testFile);
            
            txtExpected = FileManager.readFile('printOwing_step3_after.m');            
            txtActual = FileManager.readFile(testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
            
            delete(testFile);
        end
        
        function testFile_withReassignedLocalVar(testCase)
            testFile = 'testFile.m';
            copyfile('printOwing_step4_before.m',testFile);
            
            Refactor.file(testFile);
            
            txtExpected = FileManager.readFile('printOwing_step4_after.m');
            txtActual = FileManager.readFile(testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
            
            delete(testFile);
        end
        
        function testFile_withReassignedParameter(testCase)
            testFile = 'testFile.m';
            copyfile('printOwing_step5_before.m',testFile);
            
            Refactor.file(testFile);
            
            txtExpected = FileManager.readFile('printOwing_step5_after.m');
            txtActual = FileManager.readFile(testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
            
            delete(testFile);
        end
        
    end
end

