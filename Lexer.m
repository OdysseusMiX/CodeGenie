classdef Lexer
    
    properties (Constant)
        exprNumericLiteral = '^ *([0-9]+)'
        exprSymbol = '^ *([a-zA-Z]\w*)'
        exprComment = '^ *(%.*?)(?:\n|$)'
        exprBlankLine = '^( *\n)'
        exprOperator = '^ *([;,=\+\-\(\)\\\*&|~!@^{}\[\]:\<\>]+)'
        exprString = '^ *(''.*?'')'
        exprCommentBlock = '^(%{ *\n.*?\n%} *)(?:\n|$)'
    end
    
    properties
        tokens
    end
    
    methods
        function tokens = tokenize(obj, txt)
            
            obj.tokens = [];
            index = 1;
            while ~isempty(txt)
                
                extents = regexp(txt, Lexer.exprCommentBlock,'tokenExtents','once');
                if ~isempty(extents)
                    txt = txt(extents(2)+1:end);
                    index = index+extents(2);
                    continue;
                end
                
                extents = regexp(txt, Lexer.exprComment,'tokenExtents','once');
                if ~isempty(extents)
                    txt = txt(extents(2)+1:end);
                    index = index+extents(2);
                    continue;
                end
                
                extents = regexp(txt, Lexer.exprBlankLine,'tokenExtents','once');
                if ~isempty(extents)
                    txt = txt(extents(2)+1:end);
                    index = index+extents(2);
                    continue;
                end
                
                extents = regexp(txt, Lexer.exprNumericLiteral,'tokenExtents','once');
                if ~isempty(extents)
                    [obj, txt] = obj.addToken(txt, extents, index);
                    index = index+extents(2);
                    continue;
                end
                
                extents = regexp(txt, Lexer.exprSymbol,'tokenExtents','once');
                if ~isempty(extents)
                    [obj, txt] = obj.addToken(txt, extents, index);
                    index = index+extents(2);
                    continue;
                end
                
                extents = regexp(txt, Lexer.exprOperator,'tokenExtents','once');
                if ~isempty(extents)
                    [obj, txt] = obj.addToken(txt, extents, index);
                    index = index+extents(2);
                    continue;
                end
                
                extents = regexp(txt, Lexer.exprString,'tokenExtents','once');
                if ~isempty(extents)
                    [obj, txt] = obj.addToken(txt, extents, index);
                    index = index+extents(2);
                    continue;
                end
                
                
                if isempty(extents)
                    break
                end
            end
            
            tokens = obj.tokens;
            
        end
        function [obj, txt] = addToken(obj, txt, extents, index)
            str = txt(extents(1):extents(2));
            token = Token(str);
            token.index = (1:length(str)) + index+extents(1)-2;
            obj.tokens = [obj.tokens, token];
            txt = txt(extents(2)+1:end);
        end
    end
end

