function [ series ] = recursiveFunction( n )
if n>0
    series = [n recursiveFunction( n-1 )]; %<inline>recursiveFunction
else
    series = 0;
end
end

