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
            tokens = self.lexer.tokenize(txt);
            self.assertEqual(length(tokens), 1);
            self.assertEqual(tokens.type, 'whitespace');
        end
        function testTokenize_1(self)
            txt = '1';
            tokens = self.lexer.tokenize(txt);
            self.assertEqual({'1'}, {tokens.string});
            self.assertEqual(tokens.type, 'integer');
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
            self.assertEqual(tokens.type, 'word');
        end
        function testTokenize_complexSymbol(self)
            txt = 'xYz_10';
            tokens = self.lexer.tokenize(txt);
            self.assertEqual({'xYz_10'}, {tokens.string});
            self.assertEqual(tokens.type, 'word');
        end
        function testTokenize_comment(self)
            txt = '% comment';
            tokens = self.lexer.tokenize(txt);
            self.assertEqual(length(tokens), 1);
            self.assertEqual(tokens.type, 'comment');
        end
        function testTokenize_newLine(self)
            txt = newline;
            tokens = self.lexer.tokenize(txt);
            self.assertEqual(length(tokens), 1);
            self.assertEqual(tokens.type, 'newline');
        end
        function testTokenize_commentThenValue(self)
            txt = sprintf('%% comment\nx');
            tokens = self.lexer.tokenize(txt);
            self.assertEqual({tokens.type}, {'comment' 'newline' 'word'});
        end
        function testTokenize_OneAssignment(self)
            txt = sprintf('x = 1');
            tokens = self.lexer.tokenize(txt);
            strings = {'x' ' ' '=' ' ' '1'};
            self.assertEqual(strings, {tokens.string});
            self.assertEqual({tokens.type}, {'word' 'whitespace' 'operator' 'whitespace' 'integer'});
        end
        function testTokenize_StringLiteral(self)
            tokens = self.lexer.tokenize('''a''');
            self.assertEqual('''a''', tokens.string);
            self.assertEqual(tokens.type, 'string');
        end
        function testTokenize_sprintf(self)
            txt = 'str = sprintf(''%s'',''something'')';
            tokens = self.lexer.tokenize(txt);
            strings = {'str' ' ' '=' ' ' 'sprintf' '(' '''%s''' ',' '''something''' ')'};
            self.assertEqual(strings, {tokens.string});
        end
        function testTokenize_CommentBlock(self)
            txt = sprintf('%%{\nComment Block\n%%} ');
            tokens = self.lexer.tokenize(txt);
            self.assertEqual(length(tokens), 1);
            self.assertEqual(tokens.type, 'blockComment');
        end
        function testTokenize_Operators(self)
            tokens = self.lexer.tokenize('.');
            self.assertEqual('.', tokens.string);
            self.assertEqual(tokens.type, 'operator');
        end

        function testTokenize_tokenHasIndex(self)
            txt = sprintf('\nx');
            tokens = self.lexer.tokenize(txt);
            self.assertEqual([1 2], [tokens.index]);
        end
        
    end
end