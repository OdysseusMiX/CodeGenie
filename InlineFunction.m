classdef InlineFunction < Refactoring
    
    methods (Static)
        
        function execute(tokens, index, filename)
            inlineFunction(tokens, index, filename);
        end
        
    end
    
end

function inlineFunction(tokens, index, filename)

functionName = tokens(index).string(10:end);

indCallerTokens = findIndexOfCallerToken(index, tokens, functionName);

[funcTokens, indFuncTokens] = parseFunction(functionName, filename, tokens); % TODO: Move to Parser

verifyCanInlineFunction(funcTokens, functionName);

statementTokens = getInlineStatementTokens(funcTokens); % TODO: Move finding statement tokens to Parser

trimmedTokens = trimTokens(tokens, index, indFuncTokens, indCallerTokens);

txt = getRefactoredText_Inline(trimmedTokens, indCallerTokens, statementTokens);

overwriteFile(filename, txt);
end

function result = trimTokens(tokens, index, indFuncTokens, indCallerTokens)
% Remove tag and function definition from file
% TODO: Maybe this shouldn't remove the def, or checks that all uses have
% been inlined
indKeep = true(size(tokens));

cursor = indFuncTokens(end)+1;
while cursor<=length(tokens) && any(strcmp(tokens(cursor).type, {'newline', 'whitespace'}))
    cursor = cursor+1;
end
indFuncTokensExtended = indFuncTokens(1):cursor;
indKeep(indFuncTokensExtended) = false;

indKeep(index) = false;
if strcmp(tokens(index-1).type, 'whitespace')
    indKeep(index-1) = false;
end

if indCallerTokens(end)<find(~indKeep,1)
    % All tokens to delete are after caller tokens to replace
    result = tokens(indKeep);
else
    % Adjust indKeep to account for replacement of caller tokens
    error('not yet implemented');
end
end

function overwriteFile(filename, txt)
fid = fopen(filename,'w');
fprintf(fid,'%s', txt);
fclose(fid);
end

function result = findEndOfFunctionSignature(funcTokens)
assert(strcmp(funcTokens(1).string,'function'));

result = 1;
while result<length(funcTokens)
    result = result+1;
    if strcmp(funcTokens(result).type,'newline')
        break;
    end
end
while any(strcmp(funcTokens(result+1).type, {'whitespace','newline'}))
    result = result+1;
end
end

function [funcTokens, index] = parseFunction(functionName, filename, tokens)
index = [];
funcFile = which(functionName);
if isempty(funcFile)
    [results] = Parser.listProgramsInFile(filename);
    if any(strcmp(functionName, results))
        % Function def is in file
        indFunc = find(strcmp({tokens.string},'function'));
        indNewline = find(strcmp({tokens.type},'newline'));
        indEndOfFunction = [];
        for i=1:length(indFunc)
            indBeginOfFunction = indFunc(i);
            indNewlinesAfterFuncDef = indNewline(indBeginOfFunction<indNewline);
            ii = indNewlinesAfterFuncDef(1);
            parenCount = 0;
            while ii>indFunc(i)
                ii = ii-1;
                if strcmp(tokens(ii).string,'(')
                    parenCount = parenCount-1;
                    continue;
                elseif strcmp(tokens(ii).string,')')
                    parenCount = parenCount+1;
                    continue;
                elseif parenCount == 0 && strcmp(tokens(ii).type,'word')
                    temp = tokens(ii).string;
                    break;
                end
            end
            if strcmp(temp, functionName)
                % Found function def
                closureCount = 1;
                while ii<length(tokens)
                    ii = ii+1;
                    switch tokens(ii).string
                        case {'function','if','switch','while','for','try'}
                            closureCount = closureCount+1;
                        case 'end'
                            closureCount = closureCount-1;
                            if closureCount == 0
                                indEndOfFunction = ii;
                                break;
                            end
                    end
                end
            end
            if ~isempty(indEndOfFunction)
                break;
            end
        end
        index = indBeginOfFunction:indEndOfFunction;
        funcTokens = tokens(index);
        
    else
        % Cannot find function def
        error('Refactor:CannotInline:UnknownFunction','Cannot find definition of %s',functionName)
    end
else
    funcTokens = Parser.parseFile(funcFile);
end
end

function indLastAssignment = findLastAssignmentToOutputIndex(funcTokens, outputs)
indOutput = find(strcmp({funcTokens.string},outputs{1}));

% Last use of output might not be an assignment (ex. result = result+1)
indEquals = find(strcmp({funcTokens.string},'='));
iOutputToken = length(indOutput);
indLastAssignment = indOutput(iOutputToken);
while indLastAssignment>indEquals(end)
    iOutputToken = iOutputToken-1;
    indLastAssignment = indOutput(iOutputToken);
end
end

function indCallerTokens = findIndexOfCallerToken(index, tokens, functionName)
indCaller = index;
while indCaller>1
    indCaller = indCaller-1;
    if strcmp(tokens(indCaller).string, functionName)
        break;
    end
end
if strcmp(tokens(indCaller+1).string, '(')
    cursor2 = indCaller+1;
    parenCount = 0;
    while cursor2<index
        cursor2 = cursor2+1;
        if parenCount == 0 && strcmp(tokens(cursor2).string, ')')
            break;
        elseif strcmp(tokens(cursor2).string, '(')
            parenCount = parenCount+1;
        elseif strcmp(tokens(cursor2).string, ')')
            parenCount = parenCount-1;
        end
    end
    assert(cursor2<index)
    indCallerTokens = indCaller:cursor2;
else
    indCallerTokens = indCaller;
end
assert(strcmp(tokens(indCallerTokens(1)).string, functionName),'Failed to find caller to %s', functionName);
end

function indEndOfStatments = findEndOfStatementsIndex(funcTokens, indEndOfSig)
indEndOfStatments = length(funcTokens);
while indEndOfStatments>indEndOfSig
    indEndOfStatments = indEndOfStatments-1;
    if strcmp(funcTokens(indEndOfStatments+1).string, 'end')
        while any(strcmp(funcTokens(indEndOfStatments).type, {'whitespace','newline'}))
            indEndOfStatments = indEndOfStatments-1;
        end
        if strcmp(funcTokens(indEndOfStatments).string, ';')
            indEndOfStatments = indEndOfStatments-1;
        end
        break;
    end
end
end

function indReturnAssignment = findReturnAssignmentIndices(funcTokens)
indReturnAssignment = [];
[~,outputs] = Parser.getArguments(funcTokens);
if length(outputs)>1
    error('multiple arguments returned'); % TODO: Add test for multiple return arguments
elseif length(outputs)==1
    % Remove 'result = '
    indLastAssignment = findLastAssignmentToOutputIndex(funcTokens, outputs);
    
    nTokensToRemove = 1;
    while ~strcmp(funcTokens(indLastAssignment+nTokensToRemove).string, '=')
        nTokensToRemove = nTokensToRemove+1;
    end
    while any(strcmp(funcTokens(indLastAssignment+nTokensToRemove+1).type, {'whitespace','newline'}))
        nTokensToRemove = nTokensToRemove+1;
    end
    indReturnAssignment = indLastAssignment:(indLastAssignment+nTokensToRemove);
end
end

function [statementTokens] = getInlineStatementTokens(funcTokens)
indStatements = true(size(funcTokens));

indEndOfSig = findEndOfFunctionSignature(funcTokens);
indStatements(1:indEndOfSig) = false;

indEndOfStatments = findEndOfStatementsIndex(funcTokens, indEndOfSig);
indStatements(indEndOfStatments+1:end) = false;

indReturnAssignment = findReturnAssignmentIndices(funcTokens);
indStatements(indReturnAssignment) = false;

statementTokens = funcTokens(indStatements);
end

function verifyCanInlineFunction(funcTokens, functionName)
if sum(strcmp({funcTokens.string},functionName))>1
    error('Refactor:CannotInline:Recursive','Cannot inline %s because it is recursive',functionName);
end

if sum(strcmp({funcTokens.string},'return'))>0
    error('Refactor:CannotInline:MultipleReturnPoints','Cannot inline %s because it has multiple return points',functionName)
end
end

function txt = getRefactoredText_Inline(trimmedTokens, indCallerTokens, statementTokens)
refactored = [...
    trimmedTokens(1:indCallerTokens(1)-1),...
    statementTokens,...
    trimmedTokens(indCallerTokens(end)+1:end)...
    ];
txt = [refactored.string];
end