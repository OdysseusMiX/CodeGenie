classdef Lexer
    
    properties (Constant)
        exprNonTokens = {
            '^([ \t\r\b]*)'                             % whitespace
            '^(%{ *\n.*?\n%} *)(?:\n|$)'                % commment block
            '^(%.*?)(?:\n|$)'                           % comment
            }
        exprTokens = {
            '^(\n)'                                     % newline
            '^([;,=\+\-\(\)\\\*&|~!@^{}\[\]:\<\>]+)'    % operator
            '^([0-9]+)'                                 % numeric literal
            '^(''.*?'')'                                % string literal
            '^([a-zA-Z]\w*)'                            % identifier
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
                for i=1:length(Lexer.exprNonTokens)
                    extents = regexp(txt, Lexer.exprNonTokens{i},'tokenExtents','once');
                    if ~isempty(extents)
                        [obj, txt] = obj.skip(txt, extents);
                        matched = true;
                        break;
                    end
                end
                for i=1:length(Lexer.exprTokens)
                    extents = regexp(txt, Lexer.exprTokens{i},'tokenExtents','once');
                    if ~isempty(extents)
                        [obj, txt] = obj.addToken(txt, extents);
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
        function [obj, txt] = addToken(obj, txt, extents)
            str = txt(extents(1):extents(2));
            token = Token(str);
            token.index = (1:length(str)) + obj.index+extents(1)-2;
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

