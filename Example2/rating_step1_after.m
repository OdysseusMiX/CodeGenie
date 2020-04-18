function result = rating(aDriver)
if aDriver.numberOfLateDeliveries > 5
    result = 2;
else
    result = 1;
end
end

