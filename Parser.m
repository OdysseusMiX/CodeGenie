classdef Parser
    
    methods (Static)
        function tokens = parseFile(file)
            txt = Parser.readFile(file);
            tokens = Parser.parse(txt);
        end
        
        function txt = readFile(file)
            fid = fopen(file);
            if fid<3
                txt = '';
            else
                txt = fread(fid,'*char');
                fclose(fid);
                txt = txt';
            end
        end
        
        function result = parse(txt)
            lexer = Lexer();
            tokens = lexer.tokenize(txt);
            
            result = [];
            closureLevel = 1;
            statementCount(closureLevel) = 1;
            i = 0;
            while i<length(tokens)
                i = i+1;
                switch tokens(i).type
                    case 'whitespace'
                        result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                    case 'blockComment'
                        result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                    case 'comment'
                        result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                    case 'word'
                        switch tokens(i).string
                            case {'function' 'for' 'while' 'if' 'try'}
                                closureLevel = closureLevel+1;
                                statementCount(closureLevel) = 1;
                                result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                            case 'end'
                                result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                                closureLevel = closureLevel-1;
                            otherwise
                                result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                        end
                    case 'newline'
                        result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                        statementCount(closureLevel) = statementCount(closureLevel)+1;
                    case 'operator'
                        switch tokens(i).string
                            case ';'
                                result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                                statementCount(closureLevel) = statementCount(closureLevel)+1;
                            otherwise
                                result = appendToken(result, tokens(i), closureLevel, statementCount(closureLevel));
                        end
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
