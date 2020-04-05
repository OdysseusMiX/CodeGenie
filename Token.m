classdef Token
    properties
        string
        index
    end
    methods
        function obj = Token(str)
            obj.string = str;
        end
    end
end