classdef Book < handle
    properties
        title
        author
        reservations_ Array
    end
    
    methods
        function addReservation(this, customer) %<addInput>isPriority::false
            this.reservations_.push(customer);
        end
    end
end
