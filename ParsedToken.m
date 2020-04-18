classdef ParsedToken
    
    properties
        string
        index
        type
        closureLevel    % FIXME: I should use named scopes instead of closure levels
        statementNumber
        isLeftHandSide
    end
    methods
        function obj = ParsedToken(token, closureLevel, statementNumber)
            if nargin<1
                return;
            end
            
            obj.string = token.string;
            obj.index = token.index;
            obj.type = token.type;
            obj.closureLevel = closureLevel;
            obj.statementNumber = statementNumber;
        end
    end
end