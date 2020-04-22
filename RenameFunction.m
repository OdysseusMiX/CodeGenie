classdef RenameFunction < Refactoring
    
    methods (Static)
        
        function execute(tokens, index, filename)
            renameFunction(tokens, index, filename);
        end
        
    end
    
end

function renameFunction(tokens, index, filename)

tagString = tokens(index).string(14:end);
oldName = 'circum';
newName = 'circumference';

indOldName = find(strcmp({tokens.string}, oldName));

refactoredTokens = tokens;
for i=1:length(indOldName)
    refactoredTokens(indOldName(i)).string = newName;
end

indexEnd = index;
if strcmp(tokens(index-1).type, 'whitespace')
    index = index-1;
end
refactoredTokens(index:indexEnd) = [];

txt = [refactoredTokens.string];

overwriteFile(filename, txt);
end

function overwriteFile(filename, txt)
fid = fopen(filename,'w');
fprintf(fid,'%s', txt);
fclose(fid);
end