classdef TestLexer < matlab.unittest.TestCase
    
    properties
        lexer
    end
    
    methods (TestMethodSetup)
        function setup(self)
            self.lexer = Lexer();
        end
    end
    
    methods (Test)
        function testTokenize_empty(self)
            txt = '';
            tokens = [];
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
        function testTokenize_whitespace(self)
            txt = '  ';
            tokens = [];
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
        function testTokenize_1(self)
            txt = '1';
            tokens = Token('1');
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
        function testTokenize_10(self)
            txt = '10';
            tokens = Token('10');
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
        function testTokenize_x(self)
            txt = 'x';
            tokens = Token('x');
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
        function testTokenize_complexSymbol(self)
            txt = 'xYz_10';
            tokens = Token('xYz_10');
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
        function testTokenize_comment(self)
            txt = '% comment';
            tokens = [];
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
        function testTokenize_commentThenValue(self)
            txt = sprintf('%% comment\nx');
            tokens = Token('x');
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
    end
end