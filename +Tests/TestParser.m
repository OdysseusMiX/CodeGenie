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
        function testParser_emptyInput(self)
            self.assertEqual(self.parser.parse([]), []);
        end
        function testParser_singleTokenStatement(self)
            statements = self.parser.parse('1');
            self.assertEqual({statements.string}, {'1'});
            self.assertEqual([statements.closureLevel], 1);
            self.assertEqual([statements.statementNumber], 1);
        end
        function testParser_twoStatement(self)
            statements = self.parser.parse('1;2;');
            self.assertEqual({statements.string}, {'1' ';' '2' ';'});
            self.assertEqual([statements.closureLevel], [1 1 1 1]);
            self.assertEqual([statements.statementNumber], [1 1 2 2]);
        end
        function testParser_functionClojure(self)
            txt = sprintf('function test\nx = 1;\nend');
            statements = self.parser.parse(txt);
            self.assertEqual({statements.string}, {'function' 'test' newline 'x' '=' '1' ';' newline 'end'});
            self.assertEqual([statements.closureLevel], [2 2 2 2 2 2 2 2 2]);
            self.assertEqual([statements.statementNumber], [1 1 1 2 2 2 2 3 4]);
        end
        function testParser_nestedFunctionClojure(self)
            txt = sprintf('function primary\nnested;\nfunction nested\nx = 1;\nend\nend');
            table = {
                'function'  2   1
                'primary'   2   1
                newline     2   1
                'nested'    2   2
                ';'         2   2
                newline     2   3
                'function'  3   1
                'nested'    3   1
                newline     3   1
                'x'         3   2
                '='         3   2
                '1'         3   2
                ';'         3   2
                newline     3   3
                'end'       3   4
                newline     2   4
                'end'       2   5
            };
            statements = self.parser.parse(txt);
            self.assertEqual({statements.string}, table(:,1)');
            self.assertEqual({statements.closureLevel}, table(:,2)');
            self.assertEqual({statements.statementNumber}, table(:,3)');
        end
    end
end