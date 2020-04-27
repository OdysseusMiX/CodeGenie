classdef TestFileManager < matlab.unittest.TestCase
    
   
    methods (Test)
        function testReadFile_simpleFunction(testCase)
            file = '+Tests/TestFixture/simpleFunction.m';
            txt = FileManager.readFile(file);
            testCase.assertEqual(txt, sprintf('function simpleFunction\n\nend'));
        end
        
        function testOverwriteFile(testCase)
            testFile = '+Tests/TestFixture/simpleFunction_test.m';
            copyfile('+Tests/TestFixture/simpleFunction.m', testFile);

            newText = 'Hello, World!';
            
            FileManager.overwriteFile(testFile, newText);
            
            txt = FileManager.readFile(testFile);
            testCase.assertEqual(txt, newText);
            
            delete(testFile)
        end
            
        function testGetMFiles(testCase)
            testFixtureDir = '+Tests/TestFixture';
            
            mfiles = FileManager.getMFiles(testFixtureDir);
            
            testCase.assertEqual({mfiles.name}', {
            'ClassWithLeadingCommentBlock.m'
            'ClassWithLeadingComments.m'
            'SimpleClass.m'
            'notAClass.m'
            'simpleFunction.m'
            'someScript.m'
            });
        end
    end
    
end