classdef Interpreter
    
    properties
        filename
        newlines
    end
    
    methods
        function statements = read(obj, filename)
            obj.filename = filename;
            txt = readfile(filename);
            obj.newlines = regexp(txt,'\n');
            statements = obj.parseStatements(txt);
        end
        
        function statements = parseStatements(obj, txt)
            index = 1;
            statements = [];
            while ~isempty(txt)
                [fragment, txt] = getNextFragment(txt);
                [code, comment] = parseFragment(fragment);
                if ~isempty(code)
                    statements = [statements; obj.Statement(code, index)]; %#ok<AGROW>
                    index = index + length(fragment) + 1;
                else
                    index = index + 1;
                end
            end
        end
        
        function statement = Statement(obj, txt, index)
            if isempty(txt)
                statement = [];
            else
                statement.string = txt;
                statement.file = obj.filename;
                statement.index = (1:length(txt)) + index - 1;
                statement.line = lineNumber(index, obj.newlines);
            end
        end
        
    end
end

function line = lineNumber(index, newlines)
line = find(index<newlines,1,'first');
if isempty(line)
    line = length(newlines);
end
end

function [fragment, txt] = getNextFragment(txt)
result = regexp(txt, '[\n;]', 'split','once');
if ~isempty(result)
    fragment = result{1};
    if length(result)==2
        txt = result{2};
    else
        txt = '';
    end
else
    fragment = '';
    txt = '';
end
end

function [code, comment] = parseFragment(txt)
result = regexp(txt, ' *%', 'split','once');
code = txt;
comment = '';
if ~isempty(result)
    code = result{1};
    if length(result)==2
        comment = result{2};
    else
        comment = '';
    end
else
    code = '';
    comment = '';
end
end