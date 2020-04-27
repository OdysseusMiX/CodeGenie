classdef RenameFunction < Refactoring
    
    methods (Static)
        
        function execute(tokens, index, filename)
            renameFunction(tokens, index, filename);
        end
        
    end
    
end

function renameFunction(tokens, index, filename)

[oldName, newName] = Refactor.getTagData(tokens, index);

tokensWithoutTag = Refactor.removeTag(tokens, index);

refactoredTokens = replaceNames(tokensWithoutTag, oldName, newName);

txt = [refactoredTokens.string];

FileManager.overwriteFile(filename, txt);
end

function result = replaceNames(tokens, oldName, newName)
indOldName = find(strcmp({tokens.string}, oldName));

result = tokens;
for i=1:length(indOldName)
    result(indOldName(i)).string = newName;
end
end
