classdef Book < handle
    properties
        title
        author
        reservations_ Array
    end
    
    methods
        function addReservation(this, customer, isPriority)
            this.reservations_.push(customer);
        end
    end
end
