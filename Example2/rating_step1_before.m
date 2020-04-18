function result = rating(aDriver)
if moreThanFiveLateDeliveries(aDriver) %<inline>moreThanFiveLateDeliveries
    result = 2;
else
    result = 1;
end
end

function result = moreThanFiveLateDeliveries(aDriver)
  result = aDriver.numberOfLateDeliveries > 5;
end
