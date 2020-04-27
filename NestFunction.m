classdef NestFunction < Refactoring
    
    methods (Static)
        
        function execute(tokens, index, filename)
            extractToNestedFunction(tokens, index, filename);
        end
        
    end
    
end

function extractToNestedFunction(tokens, index, filename)

functionCall = tokens(index(1)).string(8:end);

indInsert = findEndOfCurrentFunctionOrScript(tokens, index(1));

txt = getRefactoredText(tokens, index, indInsert, functionCall);

FileManager.overwriteFile(filename, txt);
end

function indInsert = findEndOfCurrentFunctionOrScript(tokens, startIndex)

funcLevel = findTopLevel(tokens, startIndex);
indInsert = findBottomOfLevel(tokens, funcLevel, startIndex);
end

function funcLevel = findTopLevel(tokens, startIndex)
funcLevel = tokens(1).closureID; % default
i = startIndex;
while i>1
    i = i-1;
    if strcmp(tokens(i).string, 'function')
        funcLevel = tokens(i).closureID;
        break
    end
end
end
function indInsert = findBottomOfLevel(tokens, funcLevel, startIndex)
i = startIndex;
parenCount = 0;
while i<length(tokens)
    i = i+1;
    if tokens(i).closureID == funcLevel
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

function txt = getRefactoredText(tokens, index, indInsert, functionCall)
nTokens = length(tokens);
txt_before_extraction = [tokens(1:(index(1)-1)).string];
txt_replacement = [functionCall ';'];
txt_before_end = [tokens((index(end)+1):(indInsert-1)).string];
txt_extracted = ['function ' functionCall tokens(index(2:end-1)).string 'end' newline];
txt_after = [tokens(indInsert:nTokens).string];
txt = [txt_before_extraction, txt_replacement, txt_before_end, newline, txt_extracted, txt_after ];
end
