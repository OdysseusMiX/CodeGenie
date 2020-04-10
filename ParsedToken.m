classdef ParsedToken
    
    properties
        string
        index
        type
        closureLevel
        statementNumber
    end
    methods
        function obj = ParsedToken(token, closureLevel, statementNumber)
            obj.string = token.string;
            obj.index = token.index;
            obj.type = token.type;
            obj.closureLevel = closureLevel;
            obj.statementNumber = statementNumber;
        end
    end
end