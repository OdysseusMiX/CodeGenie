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
            
            if isempty(tokens)
                result = [];
                return;
            end
            
            result = repmat(ParsedToken,1,length(tokens));
            closureLevel = 1;
            statementCount(closureLevel) = 1;
            parenCount = 0;
            i = 0;
            while i<length(tokens)
                i = i+1;
                appendToken(tokens(i));
                switch tokens(i).type
                    case 'whitespace'
                    case 'blockComment'
                    case 'comment'
                    case 'word'
                        switch tokens(i).string
                            case {'function' 'for' 'while' 'if' 'switch' 'try' 'classdef' 'properties' 'methods'}
                                closureLevel = closureLevel+1;
                                statementCount(closureLevel) = 1;
                                result(i).closureLevel = closureLevel;
                                result(i).statementNumber = statementCount(closureLevel);
                            case 'end'
                                if parenCount==0
                                    closureLevel = closureLevel-1;
                                end
                            otherwise
                        end
                    case 'newline'
                        statementCount(closureLevel) = statementCount(closureLevel)+1;
                    case 'operator'
                        switch tokens(i).string
                            case ';'
                                statementCount(closureLevel) = statementCount(closureLevel)+1;
                            case '('
                                parenCount = parenCount+1;
                            case ')'
                                parenCount = parenCount-1;
                            otherwise
                        end
                    otherwise
                end
                
            end
            
            function appendToken(token)
                result(i) = ParsedToken(token, closureLevel, statementCount(closureLevel));
            end
        end
    end
end

