classdef TestParser < matlab.unittest.TestCase
    
    properties
        parser
    end
    
    methods (TestMethodSetup)
        function setup(self)
            self.parser = Parser();
        end
    end
    
    methods (Test)
        function testParse_emptyInput(self)
            self.assertEqual(Parser.parse([]), []);
        end
        function testParse_singleTokenStatement(self)
            tokens = Parser.parse('1');
            self.assertEqual(length(tokens), 1);
            self.assertEqual(tokens.string, '1');
            self.assertEqual(tokens.type, 'integer');
            self.assertEqual(tokens.index, 1);
            self.assertEqual(tokens.closureLevel, 1);
            self.assertEqual(tokens.statementNumber, 1);
        end
        function testParse_twoStatement(self)
            tokens = Parser.parse('1;2;');
            self.assertEqual(length(tokens), 4);
            self.assertEqual({tokens.string}, {'1' ';' '2' ';'});
            self.assertEqual({tokens.type}, {'integer' 'operator' 'integer' 'operator'});
            self.assertEqual([tokens.index], 1:4);
            self.assertEqual([tokens.closureLevel], [1 1 1 1]);
            self.assertEqual([tokens.statementNumber], [1 1 2 2]);
        end
        function testParse_dotNotation(self)
            txt = sprintf('s.f=2');
            tokens = Parser.parse(txt);
            self.assertEqual({tokens.string}, {'s' '.' 'f' '=' '2'});
            self.assertEqual([tokens.closureLevel], [1 1 1 1 1]);
            self.assertEqual([tokens.statementNumber], [1 1 1 1 1]);
        end
        function testParse_includesSpaces(self)
            txt = sprintf('s.f = 2');
            tokens = Parser.parse(txt);
            self.assertEqual({tokens.string}, {'s','.','f',' ','=',' ','2'});
            self.assertEqual([tokens.closureLevel], [1 1 1 1 1 1 1]);
            self.assertEqual([tokens.statementNumber], [1 1 1 1 1 1 1]);
        end
        function testParse_endInsideArrayIndexIsNotClosureEnd(self)
            txt = sprintf('s(1:end)');
            tokens = Parser.parse(txt);
            self.assertEqual({tokens.string}, {'s' '(' '1' ':' 'end' ')'});
            self.assertEqual([tokens.closureLevel], [1 1 1 1 1 1]);
            self.assertEqual([tokens.statementNumber], [1 1 1 1 1 1]);
        end
        function testParse_functionClojure(self)
            txt = sprintf('function test\nx=1;\nend');
            tokens = Parser.parse(txt);
            self.assertEqual({tokens.string}, {'function',' ','test' newline 'x' '=' '1' ';' newline 'end'});
            self.assertEqual([tokens.closureLevel], [2 2 2 2 2 2 2 2 2 2]);
            self.assertEqual([tokens.statementNumber], [1 1 1 1 2 2 2 2 3 4]);
        end
        function testParse_classdefClojure(self)
            txt = sprintf('classdef test\nproperties\nend\nend');
            tokens = Parser.parse(txt);
            self.assertEqual({tokens.string}, {'classdef',' ','test' newline 'properties' newline 'end' newline 'end'});
            self.assertEqual([tokens.closureLevel], [2 2 2 2 3 3 3 2 2]);
            self.assertEqual([tokens.statementNumber], [1 1 1 1 1 1 2 2 3]);
        end
        function testParse_propertiesClojure(self)
            txt = sprintf('classdef test\nproperties\nend\nend');
            tokens = Parser.parse(txt);
            self.assertEqual({tokens.string}, {'classdef',' ','test' newline 'properties' newline 'end' newline 'end'});
            self.assertEqual([tokens.closureLevel], [2 2 2 2 3 3 3 2 2]);
            self.assertEqual([tokens.statementNumber], [1 1 1 1 1 1 2 2 3]);
        end
        function testParse_methodsClojure(self)
            txt = sprintf('classdef test\nmethods\nend\nend');
            tokens = Parser.parse(txt);
            self.assertEqual({tokens.string}, {'classdef',' ','test' newline 'methods' newline 'end' newline 'end'});
            self.assertEqual([tokens.closureLevel], [2 2 2 2 3 3 3 2 2]);
            self.assertEqual([tokens.statementNumber], [1 1 1 1 1 1 2 2 3]);
        end
        function testParse_nestedFunctionClojure(self)
            txt = sprintf('function primary\nnested;\nfunction nested\nx = 1;\nend\nend');
            table = {
                'function'  2   1
                ' '         2   1
                'primary'   2   1
                newline     2   1
                'nested'    2   2
                ';'         2   2
                newline     2   3
                'function'  3   1
                ' '         3   1
                'nested'    3   1
                newline     3   1
                'x'         3   2
                ' '         3   2
                '='         3   2
                ' '         3   2
                '1'         3   2
                ';'         3   2
                newline     3   3
                'end'       3   4
                newline     2   4
                'end'       2   5
            };
            statements = Parser.parse(txt);
            self.assertEqual({statements.string}, table(:,1)');
            self.assertEqual({statements.closureLevel}, table(:,2)');
            self.assertEqual({statements.statementNumber}, table(:,3)');
        end
        
        function testReadFile_simpleFunction(testCase)
            file = '+Tests/TestFixture/simpleFunction.m';
            txt = Parser.readFile(file);
            testCase.assertEqual(txt, sprintf('function simpleFunction\n\nend'));
        end

        function testParseFile_simpleFunction(testCase)
            file = '+Tests/TestFixture/simpleFunction.m';
            tokens = Parser.parseFile(file);
            testCase.assertEqual({tokens.string}, {'function',' ','simpleFunction',newline,newline,'end'});
        end
    end
end