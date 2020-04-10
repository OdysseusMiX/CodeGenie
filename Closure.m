classdef Closure
    
    properties
        type
        tokens
        statements      Statement
    end
    
    methods
        function obj = Closure(tokens, filename)
            obj.tokens = tokens;
            
            switch tokens(1).string
                case 'function'
                    obj.type = 'function';
                otherwise
                    obj.type = 'script';
            end
            
            nStatements = max([tokens.statementNumber]);
            for i = 1:nStatements
                ind = [tokens.statementNumber] == i;
                obj.statements(i) = Statement(tokens(ind), filename);
            end
        end
    end
end