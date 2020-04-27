classdef TestFileManager < matlab.unittest.TestCase
    
   
    methods (Test)
        function testReadFile_simpleFunction(testCase)
            file = '+Tests/TestFixture/simpleFunction.m';
            txt = FileManager.readFile(file);
            testCase.assertEqual(txt, sprintf('function simpleFunction\n\nend'));
        end
    end
    
end