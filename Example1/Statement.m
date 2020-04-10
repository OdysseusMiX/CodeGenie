classdef Statement
    
    properties
        string
        file
        index
    end
    
    methods
        function obj = Statement(tokens, filename)
            obj.string = printString(tokens);
            obj.index = tokens(1).index(1):tokens(end).index(end);
            obj.file = filename;
        end
    end
end

function str = printString(tokens)
switch tokens(1).string
    case 'function'
        str = [tokens(1).string ' ' tokens(2:end).string];
    otherwise
        str = [tokens.string];
end
end