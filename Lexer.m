classdef Lexer
    
    methods
        function tokens = tokenize(obj, txt)
            
            tokens = [];
            while ~isempty(txt)
            
            extents = regexp(txt, '^ *([0-9]+)','tokenExtents','once');
            if ~isempty(extents)
                [tokens, txt] = addToken(txt, extents, tokens);
            end
            
            extents = regexp(txt, '^ *([a-zA-Z]\w*)','tokenExtents','once');
            if ~isempty(extents)
                [tokens, txt] = addToken(txt, extents, tokens);
            end
            
            extents = regexp(txt, '^ *(%.*?)(?:\n|$)','tokenExtents','once');
            if ~isempty(extents)
                txt = txt(extents(2)+1:end);
            end
            
            extents = regexp(txt, '^( *\n)','tokenExtents','once');
            if ~isempty(extents)
                txt = txt(extents(2)+1:end);
            end
             
            if isempty(extents)
                break
            end
            end
            
        end
    end
end

function [tokens, txt] = addToken(txt, extents, tokens)
str = txt(extents(1):extents(2));
tokens = [tokens, Token(str)];
txt = txt(extents(2)+1:end);
end