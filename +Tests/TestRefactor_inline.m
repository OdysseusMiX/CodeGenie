classdef TestRefactor_inline < matlab.unittest.TestCase
    
    properties
        oldpath
        testFile = 'testFile.m'
        startDir
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.oldpath = addpath(cd);
            testCase.startDir = cd;
            cd('Example2')
        end
    end
    methods (TestMethodTeardown)
        function tearDown(testCase)
            if exist(testCase.testFile,'file')
                delete(testCase.testFile);
            end
            cd(testCase.startDir)
            path(testCase.oldpath)
        end
    end
    
    methods (Test)
        function testFile_unknownFunction_error(testCase)
            copyfile('usesUnknownFunction.m',testCase.testFile);
                        
            action = @() Refactor.file(testCase.testFile);
            
            testCase.assertError(action, 'Refactor:CannotInline:UnknownFunction');
        end
        
        function testFile_recursion_error(testCase)
            copyfile('recursiveFunction.m',testCase.testFile);
            
            action = @() Refactor.file(testCase.testFile);
            
            testCase.assertWarning(action, 'Refactor:CannotInline:Recursive')
        end
        
        function testFile_multipleReturnPoints_error(testCase)
            copyfile('returnsInTwoPlaces.m',testCase.testFile);
            
            action = @() Refactor.file(testCase.testFile);
            
            testCase.assertWarning(action, 'Refactor:CannotInline:MultipleReturnPoints')
        end
%         
%         function testFile_intoMethodWithNoAccessors_error(testCase)
%             testCase.assertFail;
%         end
%         
%         function testFile_otherComplexities_error(testCase)
%             testCase.assertFail;
%         end
%         
%         
%         function testFile_Inline_simplest(testCase)
%             copyfile('rating_step1_before.m',testCase.testFile);
%                         
%             Refactor.file(testCase.testFile);
%             
%             txtExpected = Parser.readFile('rating_step1_after.m');            
%             txtActual = Parser.readFile(testCase.testFile);
%             
%             testCase.assertEqual(txtActual, txtExpected);
%         end
%         function testFile_Inline_renamedVariables(testCase)
%             copyfile('rating_step2_before.m',testCase.testFile);
%                         
%             Refactor.file(testCase.testFile);
%             
%             txtExpected = Parser.readFile('rating_step2_after.m');            
%             txtActual = Parser.readFile(testCase.testFile);
%             
%             testCase.assertEqual(txtActual, txtExpected);
%         end
%         function testFile_Inline_handleReferenceAssignment(testCase)
%             copyfile('reportLines_step1_before.m',testCase.testFile);
%                         
%             Refactor.file(testCase.testFile);
%             
%             txtExpected = Parser.readFile('reportLines_step1_after.m');            
%             txtActual = Parser.readFile(testCase.testFile);
%             
%             testCase.assertEqual(txtActual, txtExpected);
%         end
    end
end

