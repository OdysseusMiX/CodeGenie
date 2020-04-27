classdef TestRefactor_addInput < matlab.unittest.TestCase
    
    properties
        oldpath
        startDir
    end
    
    methods (TestClassSetup)
        function goToFixtureDir(testCase)
            testCase.oldpath = addpath(cd);
            testCase.startDir = cd;
            cd('Example3')
            testDir = 'Test';
            if ~exist(testDir,'dir')
                mkdir('Test')
            end
            cd('Test')
        end
    end
    methods (TestClassTeardown)
        function goBackToStartDir(testCase)
            cd(testCase.startDir)
            path(testCase.oldpath)
        end
    end
    
    methods (Test)
        function testFile_usesOnlySubfieldOfInput(testCase)
            copyfile('../Array.m','Array.m');
            copyfile('../Book_before.m','Book.m');
            copyfile('../LibraryUseCase_before.m','LibraryUseCase.m');
                        
            Refactor.file('Book.m');
            
            txtExpected = Parser.readFile('../Book_after.m');
            txtActual = Parser.readFile('Book.m');
            testCase.assertEqual(txtActual, txtExpected);
            
            txtExpected = Parser.readFile('../LibraryUseCase_after.m');
            txtActual = Parser.readFile('LibraryUseCase.m');
            testCase.assertEqual(txtActual, txtExpected);
            
            delete('Book.m');
            delete('LibraryUseCase.m');
        end
    end
end