classdef Inspector
    methods
        function list = currentWorkspaceVariables(obj)
            list = evalin('caller','who');
        end
        function list = currentGlobalVariables(obj)
            list = evalin('caller','who(''global'')');
        end
        
        function list = classesInScope(obj)
            list = mfilesInCurrentDirectoryOrBelow;
            for i=length(list):-1:1
                if ~isclass(list{i})
                    list(i)=[];
                end
            end
            list = strrep(list, '.m', '');
        end
        
        function list = functionsInScope(obj)
            list = mfilesInCurrentDirectoryOrBelow;
            for i=length(list):-1:1
                if ~isfunction(list{i})
                    list(i)=[];
                end
            end
            list = strrep(list, '.m', '');
        end
        
        function list = scriptsInScope(obj)
            list = mfilesInCurrentDirectoryOrBelow;
            for i=length(list):-1:1
                if isfunction(list{i}) || isclass(list{i})
                    list(i)=[];
                end
            end
            list = strrep(list, '.m', '');
        end
        
        function results = findCallsTo(obj, fname)
            results = {};
            list = mfilesInCurrentDirectoryOrBelow;
            for i=1:length(list)
                lineNumbers = callsTo(fname,list{i});
                if ~isempty(lineNumbers)
                    results = [results; {list{i}, lineNumbers}];
                end
            end
        end
    end
end

function list = mfilesInCurrentDirectoryOrBelow
s = dir('**/*.m');
list = {s.name}';
end

function tf = isclass(filename)
tf = strcmp('class',mFileType(filename));
end


function tf = isfunction(filename)
tf = strcmp('function',mFileType(filename));
end

function type = mFileType(filename)
type = 'invalid';
fid = fopen(filename,'r');
if fid<3 % could not open file
    return;
end

type = 'script';
withinCommentBlock = false;
while ~feof(fid)
    line = fgetl(fid);
    switch firstWord(line)
        case ''
            % blank line
        case '%{'
            withinCommentBlock = true;
        case '%}'
            withinCommentBlock = false;
        case 'function'
            if ~withinCommentBlock
                type = 'function';
                break;
            end
        case 'classdef'
            if ~withinCommentBlock
                type = 'class';
                break;
            end
    end
end
fclose(fid);
end

function lineNumbers = callsTo(fname,filename)
lineNumbers = [];
fid = fopen(filename,'r');
if fid<3 % could not open file
    return;
end

withinCommentBlock = false;
expression = ['\<' fname '\>'];
lineCount = 0;
while ~feof(fid)
    line = fgetl(fid);
    lineCount = lineCount+1;
    switch firstWord(line)
        case ''
            % blank line
            continue;
        case '%{'
            withinCommentBlock = true;
            continue;
        case '%}'
            withinCommentBlock = false;
            continue;
        case 'function'
            continue;
    end
    
    if ~withinCommentBlock
        column = regexp(line, expression, 'once');
        if ~isempty(column)
            lineNumbers = [lineNumbers; lineCount];
        end
    end
end
fclose(fid);
end

function word = firstWord(line)
word = regexp(line,'^ *([^ ]+)','tokens');
if isempty(word)
    word = '';
else
    word = word{1}{1};
end
end

