classdef Array < handle
% Handle object to represent a Java Array with push() method
    properties
        data = {}
    end
    
    methods
        function push(obj, newElement)
            obj.data = [obj.data, {newElement}];
        end        
    end
end