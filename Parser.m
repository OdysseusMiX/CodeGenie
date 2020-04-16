classdef Parser
    properties (Constant)
        namesInPath = Parser.listProgramsInPath
    end
    
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
        
        function [inputs, outputs] = getArguments(tokens, knownNames)
            if nargin<2
                knownNames = {};
            end
            indLHS = Parser.determineAssignmentTokens(tokens);
            indName = Parser.determineComplexNames(tokens);
            
            knownNames = [
                knownNames
                Parser.namesInPath
                ];
            varsRead = {};
            varsSet = {};
            for i=1:length(tokens)
                name = tokens(i).string;
                if indName(i) && ~iskeyword(name)
                    if indLHS(i)
                        if ~any(strcmp(varsSet, name))
                            varsSet = [varsSet; {name}];
                        end
                        if ~any(strcmp(knownNames, name))
                            knownNames = [knownNames; {name}];
                        end
                    else
                        if ~any(strcmp(varsRead, name)) && ...
                                ~any(strcmp(knownNames, name))
                            varsRead = [varsRead; {name}];
                        end
                    end
                end
            end
            
            inputs = varsRead;
            outputs = varsSet;
        end
        
        function [results, levels] = listProgramsInFile(filename)
            % FIXME: I should use named scopes instead of closure levels
            [~, name] = fileparts(filename);
            results = {name};
            levels = 1;
            
            tokens = Parser.parseFile(filename);
            maybeScript = true;
            i = 0;
            while i<length(tokens)
                i = i+1;
                if strcmp(tokens(i).type, 'word')
                    switch tokens(i).string
                        case 'function'
                            if maybeScript
                                maybeScript = false;
                                continue;
                            else
                                levels = [levels; tokens(i).closureLevel - 1];
                                [subfunction, i] = findSubfunctionName(tokens, i);
                                results = [results; {subfunction}];
                            end
                        case 'classdef'
                            maybeScript = false;
                    end
                end
            end
            
            function [subfunction, i] = findSubfunctionName(tokens, start)
                parenCount = 0;
                i = start;
                hasAssignment = false;
                while i<length(tokens)
                    i = i+1;
                    if strcmp(tokens(i).string, '=')
                        hasAssignment = true;
                    elseif strcmp(tokens(i).string, newline) || strcmp(tokens(i).string, ';')
                        break;
                    end
                end
                
                i = start;
                waitForSecondWord = hasAssignment;
                while i<length(tokens)
                    i = i+1;
                    switch tokens(i).type
                        case 'word'
                            if parenCount==0 && ~waitForSecondWord
                                subfunction = tokens(i).string;
                                return;
                            end
                        case 'operator'
                            switch tokens(i).string
                                case {'(' '['}
                                    parenCount = parenCount+1;
                                case {')' ']'}
                                    parenCount = parenCount-1;
                                case '='
                                    waitForSecondWord = false;
                            end
                        case 'newline'
                            break
                    end
                end
            end
        end
        
        function result = listProgramsInPath
            p = path;
            pathDirectories = textscan(p,'%s','Delimiter',':');
            pathDirectories = pathDirectories{1};
            result = {};
            for i=1:length(pathDirectories)
                W = what(pathDirectories{i});
                if length(W)>1
                    W = W(end);
                end
                result = [result; W.m; W.mlapp; W.mlx; W.mat; W.mex; W.classes; W.packages];
            end
            for i=1:length(result)
                [~,result{i}] = fileparts(result{i});
            end
        end
        function result = listProgramsInCurrentDir
            result = Parser.listProgramsIn(cd);
        end
        function result = listProgramsIn(directory)
            W = what(directory);
            if length(W)>1
                W = W(end);
            end
            result = [W.m; W.mlapp; W.mlx; W.mat; W.mex; W.classes; W.packages];
            for i=1:length(result)
                [~,result{i}] = fileparts(result{i});
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

