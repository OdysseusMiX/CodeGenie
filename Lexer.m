classdef Lexer
    
    properties (Constant)
        exprNumericLiteral = '^ *([0-9]+)'
        exprSymbol = '^ *([a-zA-Z]\w*)'
        exprComment = '^ *(%.*?)(?:\n|$)'
        exprBlankLine = '^( *\n)'
    end
    
    properties
        tokens
    end
    
    methods
        function tokens = tokenize(obj, txt)
            
            obj.tokens = [];
            while ~isempty(txt)
            
            extents = regexp(txt, Lexer.exprNumericLiteral,'tokenExtents','once');
            if ~isempty(extents)
                [obj, txt] = obj.addToken(txt, extents);
            end
            
            extents = regexp(txt, Lexer.exprSymbol,'tokenExtents','once');
            if ~isempty(extents)
                [obj, txt] = obj.addToken(txt, extents);
            end
            
            extents = regexp(txt, Lexer.exprComment,'tokenExtents','once');
            if ~isempty(extents)
                txt = txt(extents(2)+1:end);
            end
            
            extents = regexp(txt, Lexer.exprBlankLine,'tokenExtents','once');
            if ~isempty(extents)
                txt = txt(extents(2)+1:end);
            end
             
            if isempty(extents)
                break
            end
            end
            
            tokens = obj.tokens;
            
        end
        function [obj, txt] = addToken(obj, txt, extents)
            str = txt(extents(1):extents(2));
            obj.tokens = [obj.tokens, Token(str)];
            txt = txt(extents(2)+1:end);
        end
    end
end

