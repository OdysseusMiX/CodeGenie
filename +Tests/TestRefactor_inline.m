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
            
            testCase.assertError(action, 'Refactor:CannotInline:Recursive')
        end
        
        function testFile_multipleReturnPoints_error(testCase)
            copyfile('returnsInTwoPlaces.m',testCase.testFile);
            
            action = @() Refactor.file(testCase.testFile);
            
            testCase.assertError(action, 'Refactor:CannotInline:MultipleReturnPoints')
        end
        
%         function testFile_noFunctionNameAfterTag(testCase)
%             testCase.assertFail;
%         end
%         function testFile_invalidFunctionNameAfterTag(testCase)
%             testCase.assertFail;
%         end
%         function testFile_invalidTextAfterTag(testCase)
%             testCase.assertFail;
%         end

%         function testFile_statementsAreNotAValidMatlabInlineExpression_error(testCase)
%             testCase.assertFail;
%         end

%         function testFile_usesReturnButHasOneReturnPoint_okay(testCase)
%             copyfile('returnsInTwoPlaces.m',testCase.testFile);
%             
%             action = @() Refactor.file(testCase.testFile);
%             
%             testCase.assertError(action, 'Refactor:CannotInline:MultipleReturnPoints')
%         end
%         
%         function testFile_intoMethodWithNoAccessors_error(testCase)
%             testCase.assertFail;
%         end
%         
%         function testFile_methodIsPolymorphic_error(testCase)
%             testCase.assertFail;
%         end
%         
%         function testFile_isWithinParens_error(testCase)
%             testCase.assertFail;
%         end
%         
%         function testFile_isWithinBraces_error(testCase)
%             testCase.assertFail;
%         end
%         
%         function testFile_isWithinBrackets_error(testCase)
%             testCase.assertFail;
%         end
%         
%         function testFile_otherComplexities_error(testCase)
%             testCase.assertFail;
%         end
%         
%         
        function testFile_Inline_simplest(testCase)
            copyfile('rating_step1_before.m',testCase.testFile);

            Refactor.file(testCase.testFile);

            txtExpected = FileManager.readFile('rating_step1_after.m');
            txtActual = FileManager.readFile(testCase.testFile);

            testCase.assertEqual(txtActual, txtExpected);
        end
        function testFile_Inline_renamedVariables(testCase)
            copyfile('rating_step2_before.m',testCase.testFile);
                        
            Refactor.file(testCase.testFile);
            
            txtExpected = FileManager.readFile('rating_step1_after.m');            
            txtActual = FileManager.readFile(testCase.testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
        end
        function testFile_Inline_handleReferenceAssignment(testCase)
            copyfile('reportLines_step1_before.m',testCase.testFile);
                        
            Refactor.file(testCase.testFile);
            
            txtExpected = FileManager.readFile('reportLines_step1_after.m');            
            txtActual = FileManager.readFile(testCase.testFile);
            
            testCase.assertEqual(txtActual, txtExpected);
        end
    end
end

