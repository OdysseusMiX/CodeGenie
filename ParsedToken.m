classdef ParsedToken
    
    properties
        string
        index
        type
        closureID
        statementNumber
        isLeftHandSide
        isName
    end
    methods
        function obj = ParsedToken(token, closureID, statementNumber)
            if nargin<1
                return;
            end
            
            obj.string = token.string;
            obj.index = token.index;
            obj.type = token.type;
            obj.closureID = closureID;
            obj.statementNumber = statementNumber;
        end
    end
end