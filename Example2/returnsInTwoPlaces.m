function returnsInTwoPlaces(x)

subFunction(x); %<inline>subFunction
end

function subFunction(x)
if isnumeric(x)
    fprintf('you entered: %f\n', x);
    return;
else
    fprintf('you entered: %s\n', x);
end
end