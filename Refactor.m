classdef Refactor
    
    methods (Static)
        
        function extractFunction(filename)
            
            tokens = Parser.parseFile(filename);
            indStart = find(strncmp('%<extract>', {tokens.string}, 10));
            indStop = find(strcmp('%<\extract>', {tokens.string}));
            
            if isempty(indStart)
                indStart = find(strncmp('%<nest>', {tokens.string}, 7));
                indStop = find(strcmp('%<\nest>', {tokens.string}));
                
                if isempty(indStart)
                    return;
                else
                    index = indStart(1):indStop(1);
                    extractToNestedFunction(tokens, index, filename);
                end
            else
                index = indStart(1):indStop(1);
                extractToEndOfFile(tokens, index, filename);
            end
            
        end
    end
    
end

function extractToEndOfFile(tokens, index, filename)
functionCall = tokens(index(1)).string(11:end);
nTokens = length(tokens);

determineAssignmentTokens;

%<nest>determineComplexNames
indName = strcmp({tokens(index).type},'word');
i = length(index);
while i>1
   if indName(i)
      if i>1 && strcmp(tokens(index(i-1)).string,'.')
          indName(i) = false;
      end
   end
   i = i-1;
end
%<\nest>

% Find all referenced names
knownNames = {'fprintf'};
referencedNames = {};
for i=1:length(index)
    if ~indLHS(i) && indName(i)
        name = tokens(index(i)).string;
        if ~any(strcmp(referencedNames, name)) && ~any(strcmp(knownNames, name))
            referencedNames = [referencedNames; {name}];
        end
    end
end

% append referenced names to function call
if length(referencedNames)>1
functionCall = [functionCall '(' referencedNames{1} sprintf(', %s',referencedNames{2:end}) ')'];
elseif length(referencedNames)==1
functionCall = [functionCall '(' referencedNames{1} ')'];
end

txt_before = [tokens(1:(index(1)-1)).string];
txt_replacement = [functionCall ';'];
txt_after = [tokens((index(end)+1):nTokens).string];
txt_extracted = ['function ' functionCall tokens(index(2:end-1)).string 'end' newline];
txt = [txt_before, txt_replacement, txt_after, newline, txt_extracted ];

overwriteFile(filename, txt);

function determineAssignmentTokens
indLHS = false(size(index));
isLHS = false;
for i=length(index):-1:1
    indLHS(i) = isLHS;
    if strcmp(tokens(index(i)).string,'=')
        isLHS = ~isLHS;
    elseif isLHS && any(strcmp(tokens(index(i)).string, {newline, ';'}))
        isLHS = false;
    end
end
end
end

function extractToNestedFunction(tokens, index, filename)
functionCall = tokens(index(1)).string(8:end);
nTokens = length(tokens);

indInsert = findEndOfCurrentFunctionOrScript(tokens, index(1));
    
txt_before_extraction = [tokens(1:(index(1)-1)).string];
txt_replacement = [functionCall ';'];
txt_extracted = ['function ' functionCall tokens(index(2:end-1)).string 'end' newline];
txt_before_end = [tokens((index(end)+1):(indInsert-1)).string];
txt_after = [tokens(indInsert:nTokens).string];

txt = [txt_before_extraction, txt_replacement, txt_before_end, newline, txt_extracted, txt_after ];

overwriteFile(filename, txt);
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
        while i<length(tokens)
            i = i+1;
            if tokens(i).closureLevel == funcLevel && strcmp(tokens(i).string, 'end')
                indInsert = i;
                break
            end
        end
    end
end

function overwriteFile(filename, txt)
fid = fopen(filename,'w');
fprintf(fid,'%s', txt);
fclose(fid);
end
