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
            tokens = self.lexer.tokenize(txt);
            self.assertEqual({'1'}, {tokens.string});
        end
        function testTokenize_10(self)
            txt = '10';
            tokens = self.lexer.tokenize(txt);
            self.assertEqual({'10'}, {tokens.string});
        end
        function testTokenize_x(self)
            txt = 'x';
            tokens = self.lexer.tokenize(txt);
            self.assertEqual({'x'}, {tokens.string});
        end
        function testTokenize_complexSymbol(self)
            txt = 'xYz_10';
            tokens = self.lexer.tokenize(txt);
            self.assertEqual({'xYz_10'}, {tokens.string});
        end
        function testTokenize_comment(self)
            txt = '% comment';
            tokens = [];
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
        function testTokenize_commentThenValue(self)
            txt = sprintf('%% comment\nx');
            tokens = self.lexer.tokenize(txt);
            self.assertEqual({'x'}, {tokens.string});
        end
        function testTokenize_OneAssignment(self)
            txt = sprintf('x = 1');
            tokens = self.lexer.tokenize(txt);
            strings = {'x' '=' '1'};
            self.assertEqual(strings, {tokens.string});
        end
        function testTokenize_StringLiteral(self)
            tokens = self.lexer.tokenize('''a''');
            self.assertEqual('''a''', tokens.string);
        end
        function testTokenize_sprintf(self)
            txt = 'str = sprintf(''%s'',''something'')';
            tokens = self.lexer.tokenize(txt);
            strings = {'str' '=' 'sprintf' '(' '''%s''' ',' '''something''' ')'};
            self.assertEqual(strings, {tokens.string});
        end
        function testTokenize_CommentBlock(self)
            txt = sprintf('%%{\nComment Block\n%%} \n');
            self.assertEqual([], self.lexer.tokenize(txt));
        end
        
        function testTokenize_tokenHasIndex(self)
            txt = sprintf('%% comment\nx');
            tokens = Token('x');
            tokens.index = 11;
            self.assertEqual(tokens, self.lexer.tokenize(txt));
        end
    end
end