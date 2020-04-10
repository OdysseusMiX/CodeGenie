classdef Token
    properties
        string
        index
        type
    end
    methods
        function obj = Token(str)
            obj.string = str;
        end
    end
end