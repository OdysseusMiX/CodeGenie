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
                result(i) = ParsedToken(tokens(i), closureLevel, statementCount(closureLevel));
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
                            case {'(' '[' '{'}
                                parenCount = parenCount+1;
                            case {')' ']' '}'}
                                parenCount = parenCount-1;
                            otherwise
                        end
                    otherwise
                end
                
            end
        end
        
        function referencedNames = findAllReferencedNames(tokens)
            indLHS = Parser.determineAssignmentTokens(tokens);
            indName = Parser.determineComplexNames(tokens);
            
            knownNames = {'fprintf'};
            referencedNames = {};
            for i=1:length(tokens)
                if ~indLHS(i) && indName(i)
                    name = tokens(i).string;
                    if ~iskeyword(name) && ...
                            ~any(strcmp(referencedNames, name)) && ...
                            ~any(strcmp(knownNames, name))
                        referencedNames = [referencedNames; {name}];
                    end
                end
            end
        end
        
        function indLHS = determineAssignmentTokens(tokens)
            indLHS = false(size(tokens));
            isLHS = false;
            for i=length(tokens):-1:1
                indLHS(i) = isLHS;
                if strcmp(tokens(i).string,'=')
                    isLHS = ~isLHS;
                elseif isLHS && any(strcmp(tokens(i).string, {newline, ';'}))
                    isLHS = false;
                end
            end
        end
        
        function indName = determineComplexNames(tokens)
            indName = strcmp({tokens.type},'word');
            i = length(tokens);
            while i>1
                if indName(i)
                    if i>1 && strcmp(tokens(i-1).string,'.')
                        indName(i) = false;
                    end
                end
                i = i-1;
            end
        end
        
    end
end

