classdef Refactor
    
    methods (Static)
        
        function file(filename)
            
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
            
            indStart = find(strncmp('%<inline>', {tokens.string}, 7));
            if ~isempty(indStart)
                index = indStart(1);
                inlineFunction(tokens, index, filename);
            end
        end
    end
end

function extractToEndOfFile(tokens, index, filename)
fileLocation = fileparts(which(filename));

localNames = Parser.listProgramsIn(fileLocation);

functionCall = tokens(index(1)).string(11:end);

[inputs, outputs] = getArguments(tokens, index, localNames);

functionCall = decorateFunctionCall(functionCall, inputs, outputs);

txt = getRefactoredText(tokens, index, functionCall);

overwriteFile(filename, txt);


    function [inputs, outputs] = getArguments(tokens, index, localNames)
        
        [inputs, outputs] = Parser.getArguments(tokens(index), localNames);
        
        % Add inputs for outputs that are reassignments of known variables
        [usedBefore_inputs, usedBefore_outputs] = Parser.getArguments(tokens(1:(index(1)-1)));
        usedBefore = [usedBefore_inputs; usedBefore_outputs];
        for i=1:length(outputs)
            if any(strcmp(outputs{i}, usedBefore))
                inputs = [outputs(i); inputs];
            end
        end
        
        % Remove outputs that are not used later (i.e. local variable)
        indAfter = index(end)+1:length(tokens);
        usedLater = Parser.getArguments(tokens(indAfter));
        for i=length(outputs):-1:1
            if ~any(strcmp(outputs{i}, usedLater))
                outputs(i) = [];
            end
        end
    end

    function functionCall = decorateFunctionCall(functionCall, inputs, outputs)
        if length(outputs)>1
            functionCall = ['[' outputs{1} sprintf(', %s',outputs{2:end}) '] = ' functionCall];
        elseif length(outputs)==1
            functionCall = [outputs{1} ' = ' functionCall];
        end
        
        if length(inputs)>1
            functionCall = [functionCall '(' inputs{1} sprintf(', %s',inputs{2:end}) ')'];
        elseif length(inputs)==1
            functionCall = [functionCall '(' inputs{1} ')'];
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

function inlineFunction(tokens, index, filename)

functionName = tokens(index).string(10:end);

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
        funcTokens = tokens(indBeginOfFunction:indEndOfFunction);
        
    else
        % Cannot find function def
        error('Refactor:CannotInline:UnknownFunction','Cannot find definition of %s',functionName)
    end
else
    funcTokens = Parser.parseFile(funcFile);
end

% Find end of function signature
ii = 1;
while ii<length(funcTokens)
    ii = ii+1;
    if strcmp(funcTokens(ii).type,'newline')
        break;
    end
end

if any(strcmp({funcTokens(ii:end).string},functionName))
    warning('Refactor:CannotInline:Recursive','Cannot inline %s because it is recursive',functionName);
end

warning('Refactor:CannotInline:MultipleReturnPoints','Cannot inline %s because it has multiple return points',functionName)

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
