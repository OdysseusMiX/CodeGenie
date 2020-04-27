classdef RenameFunction < Refactoring
    
    methods (Static)
        
        function execute(tokens, index, filename)
            renameFunction(tokens, index, filename);
        end
        
    end
    
end

function renameFunction(tokens, index, filename)

[oldName, newName] = getTagData(tokens, index);

tokensWithoutTag = removeTag(tokens, index);

refactoredTokens = replaceNames(tokensWithoutTag, oldName, newName);

txt = [refactoredTokens.string];

FileManager.overwriteFile(filename, txt);
end

function [oldName, newName] = getTagData(tokens, index)
tagString = tokens(index).string(14:end);
tags = regexp(tagString,'(\w+)::(\w+)','tokens');
oldName = tags{1}{1};
newName = tags{1}{2};
end

function result = replaceNames(tokens, oldName, newName)
indOldName = find(strcmp({tokens.string}, oldName));

result = tokens;
for i=1:length(indOldName)
    result(indOldName(i)).string = newName;
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
