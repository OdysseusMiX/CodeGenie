classdef AddInputToFunction < Refactoring
    
    methods (Static)
        
        function execute(tokens, index, filename)
            addInput(tokens, index, filename);
        end
        
    end
    
end

function addInput(tokens, index, filename)

[newInputName, defaultValue] = Refactor.getTagData(tokens, index);

tempTokens = removeTag(tokens, index);

% get function name and index
closures = tokens(index).closureID;
cursor = index;
while cursor>1 && tokens(cursor-1).closureID == closures
    cursor = cursor-1;
end
assert(strcmp(tokens(cursor).string, 'function'));

cursor = cursor+1;
while tokens(cursor).isLeftHandSide || strcmp(tokens(cursor).type, 'whitespace')
    cursor = cursor+1;
end
funcName = tokens(cursor).string;
indFuncDef = cursor;

tempTokens = addInputToArgumentList(tempTokens, indFuncDef, newInputName);

% add default value to all callers
% all callers in current file
indCallers = find(strcmp({tempTokens.string},funcName));
indCallers(indCallers==indFuncDef) = [];
for iCaller=1:length(indCallers)
    tempTokens = addInputToArgumentList(tempTokens, indCallers(iCaller), defaultValue);
end

% rewrite current file
refactoredTokens = tempTokens;
txt = [refactoredTokens.string];
FileManager.overwriteFile(filename, txt);

% all callers in other files (current folder)
mfiles = FileManager.getMFiles(cd);
for iFile = length(mfiles)
    if strcmp(mfiles(iFile).name, filename)
        continue;
    end
    
    txt = FileManager.readFile(mfiles(iFile).name);
    expr = sprintf('%s', funcName);
    matches = regexp(txt, expr, 'once');
    if ~isempty(matches)
        tempTokens = Parser.parse(txt);
        indCallers = find(strcmp({tempTokens.string},funcName));
        for iCaller=1:length(indCallers)
            tempTokens = addInputToArgumentList(tempTokens, indCallers(iCaller), defaultValue);
            FileManager.overwriteFile(mfiles(iFile).name, [tempTokens.string]);
        end
    end
end

end

function result = removeTag(tokens, index)
indexEnd = index;
if strcmp(tokens(index-1).type, 'whitespace')
    index = index-1;
end
result = tokens;
result(index:indexEnd) = [];
end

function tempTokens = addInputToArgumentList(tempTokens, indexCaller, string)
    if strcmp(tempTokens(indexCaller+1).string,'(')
        % go to end of input list
        cursor = indexCaller+1;
        parenCount = 1;
        while ~(strcmp(tempTokens(cursor+1).string,')') && parenCount==1)
            cursor = cursor+1;
        end
        
        % add default value to last token
        tempTokens(cursor).string = [tempTokens(cursor).string ', ' string];
    else
        tempTokens(indexCaller).string = [tempTokens(indexCaller).string '(' string ')'];
    end
end
