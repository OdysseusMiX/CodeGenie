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

inputArgNames = getInputArgumentNames( tokens(indCallerTokens) );

[funcTokens, indFuncTokens] = Parser.parseFunction(functionName, filename, tokens);

verifyCanInlineFunction(funcTokens, functionName);

statementTokens = getInlineStatementTokens(funcTokens, inputArgNames);

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

function [statementTokens] = getInlineStatementTokens(funcTokens, inputArgNames)

indStatements = true(size(funcTokens));

% indEndOfSig = findEndOfFunctionSignature(funcTokens);
[~, indInputArgs, indOutputArgs, indEndOfSig] = findFunctionSignatureIndices(funcTokens);
indStatements(1:indEndOfSig) = false;

assert(length(indInputArgs)==length(inputArgNames))
assert(length(indOutputArgs) < 2)
% TODO: handle case where input arguments are less than defined number
% TODO: handle varargin case
% TODO: handle varargout case

% Rename inputs to match called names
renamedTokens = funcTokens;
definedInputNames = {funcTokens(indInputArgs).string};
for iInput = 1:length(inputArgNames)
    if ~strcmp(inputArgNames{iInput}, definedInputNames{iInput})
        indName = find(strcmp(definedInputNames{iInput}, {funcTokens.string}));
        for iRename = 1:length(indName)
            renamedTokens(indName(iRename)).string = inputArgNames{iInput};
        end
    end
end

indEndOfStatments = findEndOfStatementsIndex(renamedTokens, indEndOfSig);
indStatements(indEndOfStatments+1:end) = false;

if ~isempty(indOutputArgs)
indReturnAssignment = findReturnAssignmentIndices(renamedTokens);
indStatements(indReturnAssignment) = false;
end

statementTokens = renamedTokens(indStatements);
end

function [indFuncName, indInputArgs, indOutputArgs, indEndOfSig] = findFunctionSignatureIndices(funcTokens)
% Find argument and function name tokens
indOutputArgs = [];
indInputArgs = [];
indFuncName = [];
indEndOfSig = [];
cursor = 1;
parenCount = 0;
assert(strcmp(funcTokens(cursor).string, 'function'));
while cursor<length(funcTokens)
    cursor=cursor+1;
    switch funcTokens(cursor).type
        case 'operator'
            if any(strcmp(funcTokens(cursor).string, {'[','(','{'}))
                parenCount = parenCount+1;
            elseif any(strcmp(funcTokens(cursor).string, {']',')','}'}))
                parenCount = parenCount-1;
            elseif strcmp(funcTokens(cursor).string, '=') && ~isempty(indFuncName)
                indOutputArgs = indFuncName;
                indFuncName = [];
            end
        case 'word'
            if parenCount==0
                indFuncName = cursor;
            elseif parenCount == 1
                if isempty(indFuncName)
                    indOutputArgs = [indOutputArgs cursor];
                else
                    indInputArgs = [indInputArgs cursor];
                end
            end
    end
    % Break out if at end of signature
   if parenCount == 0 && strcmp(funcTokens(cursor).type, 'newline')
       while cursor<length(funcTokens) && any(strcmp(funcTokens(cursor+1).type, {'whitespace','newline'}))
           cursor = cursor+1;
       end
       indEndOfSig = cursor;
       break;
   end
end
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

function inputArgNames = getInputArgumentNames(callerTokens)
% Find indices of input arguments
inputArgNames = repmat({''},10,1);
parenCount = 0;
cursor = 1;
iArg = 0;
while cursor<length(callerTokens)
    cursor = cursor+1;
    
    switch callerTokens(cursor).string
        case {'[','(','{'}
            parenCount = parenCount+1;
            continue;
        case {']',')','}'}
            parenCount = parenCount-1;
            continue;
    end
    
    switch parenCount
        case 0
            break;
        case 1
            if strcmp(callerTokens(cursor).string, ',')
                iArg = iArg+1;
                continue;
            end
    end
    
    if ~strcmp(callerTokens(cursor).type,'whitespace')
        if iArg==0
            iArg = 1;
        end
        inputArgNames{iArg} = [inputArgNames{iArg} callerTokens(cursor).string];
    end
end

inputArgNames(iArg+1:end) = [];
end
