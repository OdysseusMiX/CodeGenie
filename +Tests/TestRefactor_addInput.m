classdef TestRefactor_addInput < matlab.unittest.TestCase
    
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
            copyfile('Book_before.m','Book.m');
            copyfile('LibraryUseCase_before.m','LibraryUseCase.m');
                        
            Refactor.file('Book.m');
            
            txtExpected = Parser.readFile('Book_after.m');
            txtActual = Parser.readFile('Book.m');
            testCase.assertEqual(txtActual, txtExpected);
            
            txtExpected = Parser.readFile('LibraryUseCase_after.m');
            txtActual = Parser.readFile('LibraryUseCase.m');
            testCase.assertEqual(txtActual, txtExpected);
        end
    end
end