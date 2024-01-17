function [xn]=coswin(x)

% cosine window to smooth cut windows
% usage: x: time series

% Copyright 2016 M.Reiss and G.Rümpker

if ~isrow(x)
    x = x';
end

N = length(x);

n = 1:1:N;

n((n-1)./(N-1) < 0.1) = ...
    (n((n-1)./(N-1) < 0.1)-1)./(N-1) / 0.1;
n( ((n-1)./(N-1) >= 0.1) & ((n-1)./(N-1) <= 0.9) ) = 1;
n( (n-1)/(N-1) > 0.9 ) = ...
    1-((n( (n-1)/(N-1) > 0.9 )-1)/(N-1) - 0.9)/ 0.1;

xn = x.*n;


end