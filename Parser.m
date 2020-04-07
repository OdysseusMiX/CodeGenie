classdef Parser
    
    methods
        function result = parse(obj, txt)
            lexer = Lexer();
            tokens = lexer.tokenize(txt);
            
            result = [];
            closureLevel = 1;
            statementCount(closureLevel) = 1;
            i = 0;
            while i<length(tokens)
                i = i+1;
                switch tokens(i).string
                    case 'function'
                        closureLevel = closureLevel+1;
                        statementCount(closureLevel) = 1;
                        result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                    case 'end'
                        result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                        closureLevel = closureLevel-1;
                    case {';' newline}
                        result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                        statementCount(closureLevel) = statementCount(closureLevel)+1;
                    otherwise
                        result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                end
                
            end
            
        end
    end
end

function statement = appendToken(statement, token, closureLevel, statementCount)
statement = [statement ParsedToken(token, closureLevel, statementCount)];
end
