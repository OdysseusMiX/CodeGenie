classdef Array < handle
% Handle object to represent a Java Array with push() method
    properties
        data = {}
    end
    
    methods
        function obj = Array(varargin)
            if nargin<1
                return;
            end
            for i=1:length(varargin)
                obj.push(varargin{i});
            end
        end
        function push(obj, newElement)
            obj.data = [obj.data, {newElement}];
        end        
        function result = includes(obj, element)
            result = false;
            if ischar(element)
                compare = @(a,b) strcmp(a,b);
            else
                compare = @(a,b) a == b;
            end
            for i=1:length(obj.data)
                try 
                    if compare(obj.data{i}, element)
                        result = true;
                        return;
                    end
                end
            end
        end
        function obj = filter(obj, isValid)
            ind = false(size(obj.data));
            for i=1:numel(obj.data)
                ind(i) = isValid(obj.data{i});
            end
            obj.data(~ind) = [];     
        end
    end
end