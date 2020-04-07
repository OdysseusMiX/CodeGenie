classdef Statement
    
    properties
        string
        file
        index
    end
    
    methods
        function obj = Statement(tokens, filename)
            obj.string = [tokens.string];
            obj.index = tokens(1).index(1):tokens(end).index(end);
            obj.file = filename;
        end
    end
end