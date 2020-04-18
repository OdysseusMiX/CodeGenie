classdef ExtractFunction < Refactoring
    
    methods (Static)
        
        function execute(tokens, index, filename)
            extractToEndOfFile(tokens, index, filename);
        end
        
    end
    
end

function extractToEndOfFile(tokens, index, filename)
fileLocation = fileparts(which(filename));

localNames = Parser.listProgramsIn(fileLocation);

functionCall = tokens(index(1)).string(11:end);

[inputs, outputs] = getArgumentsForExtractedCode(tokens, index, localNames);

functionCall = decorateFunctionCall(functionCall, inputs, outputs);

txt = getRefactoredText(tokens, index, functionCall);

overwriteFile(filename, txt);
end

function [inputs, outputs] = getArgumentsForExtractedCode(tokens, index, localNames)

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

function overwriteFile(filename, txt)
fid = fopen(filename,'w');
fprintf(fid,'%s', txt);
fclose(fid);
end
