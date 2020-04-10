classdef ExampleData
    
    methods (Static)
        function result = invoice
            o.amount = 1.01;
            result.customer = "John Doe";
            result.orders = [o o o];
        end
    end
end