classdef ParsedToken
    
    properties
        string
        index
        closureLevel
        statementNumber
    end
    methods
        function obj = ParsedToken(token, closureLevel, statementNumber)
            obj.string = token.string;
            obj.index = token.index;
            obj.closureLevel = closureLevel;
            obj.statementNumber = statementNumber;
        end
    end
end