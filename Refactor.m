classdef Refactor
    
    methods (Static)
        
        function extractFunction(filename)
            
            tokens = Parser.parseFile(filename);
            
            indStart = find(strncmp('%<extract>', {tokens.string}, 10));
            indStop = find(strcmp('%</extract>', {tokens.string}));
            if ~isempty(indStart)
                index = indStart(1):indStop(1);
                extractToEndOfFile(tokens, index, filename);
                return;
            end
            
            indStart = find(strncmp('%<nest>', {tokens.string}, 7));
            indStop = find(strcmp('%</nest>', {tokens.string}));
            if ~isempty(indStart)
                index = indStart(1):indStop(1);
                extractToNestedFunction(tokens, index, filename);
            end
        end
    end
end

function extractToEndOfFile(tokens, index, filename)

functionCall = tokens(index(1)).string(11:end);

referencedNames = Parser.findAllReferencedNames(tokens(index));

functionCall = decorateFunctionCall(functionCall, referencedNames);

txt = getRefactoredText(tokens, index, functionCall);

overwriteFile(filename, txt);

    function functionCall = decorateFunctionCall(functionCall, referencedNames)
        if length(referencedNames)>1
            functionCall = [functionCall '(' referencedNames{1} sprintf(', %s',referencedNames{2:end}) ')'];
        elseif length(referencedNames)==1
            functionCall = [functionCall '(' referencedNames{1} ')'];
        end
    end

    function txt = getRefactoredText(tokens, index, functionCall)
        nTokens = length(tokens);
        txt_before = [tokens(1:(index(1)-1)).string];
        txt_replacement = [functionCall ';'];
        txt_after = [tokens((index(end)+1):nTokens).string];
        txt_extracted = ['function ' functionCall tokens(index(2:end-1)).string 'end' newline];
        txt = [txt_before, txt_replacement, txt_after, newline, txt_extracted ];
    end
end

function extractToNestedFunction(tokens, index, filename)

functionCall = tokens(index(1)).string(8:end);
        
indInsert = findEndOfCurrentFunctionOrScript(tokens, index(1));

txt = getRefactoredText(tokens, index, indInsert, functionCall);

overwriteFile(filename, txt);

    function txt = getRefactoredText(tokens, index, indInsert, functionCall)
        nTokens = length(tokens);
        txt_before_extraction = [tokens(1:(index(1)-1)).string];
        txt_replacement = [functionCall ';'];
        txt_before_end = [tokens((index(end)+1):(indInsert-1)).string];
        txt_extracted = ['function ' functionCall tokens(index(2:end-1)).string 'end' newline];
        txt_after = [tokens(indInsert:nTokens).string];
        txt = [txt_before_extraction, txt_replacement, txt_before_end, newline, txt_extracted, txt_after ];
    end
end

function indInsert = findEndOfCurrentFunctionOrScript(tokens, startIndex)

funcLevel = findTopLevel(tokens, startIndex);
indInsert = findBottomOfLevel(tokens, funcLevel, startIndex);

    function funcLevel = findTopLevel(tokens, startIndex)
        funcLevel = tokens(1).closureLevel; % default
        i = startIndex;
        while i>1
            i = i-1;
            if strcmp(tokens(i).string, 'function')
                funcLevel = tokens(i).closureLevel;
                break
            end
        end
    end
    function indInsert = findBottomOfLevel(tokens, funcLevel, startIndex)
        i = startIndex;
        parenCount = 0;
        while i<length(tokens)
            i = i+1;
            if tokens(i).closureLevel == funcLevel
                if parenCount==0 && strcmp(tokens(i).string, 'end')
                    indInsert = i;
                    break
                elseif any(strcmp(tokens(i).string, {'(','[','{'}))
                    parenCount = parenCount+1;
                elseif any(strcmp(tokens(i).string, {')',']','}'}))
                    parenCount = parenCount-1;
                end
            end
        end
    end
end

function overwriteFile(filename, txt)
fid = fopen(filename,'w');
fprintf(fid,'%s', txt);
fclose(fid);
end
