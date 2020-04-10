classdef Clock
    
    properties
        date = clock
    end
    
    methods (Static)
        function obj = today
            obj = Clock();
        end
    end
    
    methods
        function obj = Clock
        end
        function result = getFullYear(obj)
            result = obj.date(1);
        end
        function result = getMonth(obj)
            result = obj.date(2);
        end
        function result = getDate(obj)
            result = obj.date(3);
        end
    end
    
end