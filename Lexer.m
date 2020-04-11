classdef Lexer
    
    properties (Constant)
        exprTokens = {
            'whitespace'    '^([ \t\r\b]*)'
            'blockComment'  '^(%{ *\n.*?\n%} *)(?:\n|$)'
            'comment'       '^(%.*?)(?:\n|$)'
            'newline'       '^(\n)'
            'operator'      '^(\.\*)'
            'operator'      '^(\.\^)'
            'operator'      '^(\.\\)'
            'operator'      '^(\./)'
            'operator'      '^(==)'
            'operator'      '^(~=)'
            'operator'      '^(<=)'
            'operator'      '^(>=)'
            'operator'      '^(&&)'
            'operator'      '^(\|\|)'
            'operator'      '^(\.\.)'
            'operator'      '^(\.\.\.)'
            'operator'      '^(\.'')'
            'operator'      '^(\.\()'
            'operator'      '^([\.;,=\+\-\(\)\\\*&|~!@^{}\[\]:\<\>\?])'
            'integer'       '^([0-9]+)'
            'string'        '^(''.*?'')'
            'word'          '^([a-zA-Z]\w*)'
            }
    end
    
    properties
        tokens
        index
    end
    
    methods
        function tokens = tokenize(obj, txt)
            
            obj.tokens = [];
            obj.index = 1;
            while ~isempty(txt)
                matched = false;
                for i=1:length(Lexer.exprTokens)
                    extents = regexp(txt, Lexer.exprTokens{i,2},'tokenExtents','once');
                    if ~isempty(extents)
                        [obj, txt] = obj.addToken(txt, extents, Lexer.exprTokens{i,1});
                        matched = true;
                        break;
                    end
                end
                if matched
                    continue
                else
                    break
                end
            end
            
            tokens = obj.tokens;
            
        end
        function [obj, txt] = addToken(obj, txt, extents, tokenType)
            str = txt(extents(1):extents(2));
            token = Token(str);
            token.index = (1:length(str)) + obj.index+extents(1)-2;
            token.type = tokenType;
            
            obj.tokens = [obj.tokens, token];
            txt = txt(extents(2)+1:end);
            obj.index = obj.index+extents(2);
        end
        function [obj, txt] = skip(obj, txt, extents)
            txt = txt(extents(2)+1:end);
            obj.index = obj.index+extents(2);
        end
    end
end

