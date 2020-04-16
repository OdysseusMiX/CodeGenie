function result = rating(aDriver)
if moreThanFiveLateDeliveries(aDriver) %<inline>
    result = 2;
else
    result = 1;
end
end

function result = moreThanFiveLateDeliveries(drv)
  result = drv.numberOfLateDeliveries > 5;
end
