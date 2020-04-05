classdef TestInspector < matlab.unittest.TestCase
    
    properties
        inspector
        oldpath
        startDir
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.inspector = Inspector;
            testCase.oldpath = addpath(cd);
            testCase.startDir = cd;
            cd('+Tests/TestFixture')
        end
    end
    methods (TestMethodTeardown)
        function tearDown(testCase)
            cd(testCase.startDir)
            path(testCase.oldpath)
        end
    end
    
    methods (Test)
        function testFindWorkspaceVariables(testCase)
            testCase.assertEqual(testCase.inspector.currentWorkspaceVariables, {'testCase'});
        end
        function testFindGlobalVariables(testCase)
            clearvars -global
            global X
            X=10;
            testCase.assertEqual(testCase.inspector.currentGlobalVariables, {'X'});
            clearvars -global
        end
        
        function testFindClassesInCurrentScope(testCase)
            classList = {
                'ClassWithLeadingCommentBlock'
                'ClassWithLeadingComments'
                'SimpleClass'
                };
            testCase.assertEqual(testCase.inspector.classesInScope, classList);
        end
        
        function testFindFunctionsInCurrentScope(testCase)
            functionList = {
                'notAClass'
                'simpleFunction'
                };
            testCase.assertEqual(testCase.inspector.functionsInScope, functionList);
        end
        
        function testFindScriptsInCurrentScope(testCase)
            list = {
                'someScript'
                };
            testCase.assertEqual(testCase.inspector.scriptsInScope, list);
        end
        
        function testFindCallers(testCase)
            callers = {'someScript.m', 4};
            testCase.assertEqual(testCase.inspector.findCallsTo('simpleFunction'), callers);
        end
    end
    
end