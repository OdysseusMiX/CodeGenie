classdef Date
    properties
        date    double
    end
    
    methods
        function obj = Date(Y,M,D)
            obj.date = datenum(Y,M,D);
        end
        function result = toLocaleDateString(obj)
            result = datestr(obj.date);
        end
    end
end