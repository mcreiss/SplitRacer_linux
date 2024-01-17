function [ y ] = gft(x)

%FFT with sign change in exponential function in compliance with definition
%used in Numerical Recipes

% Copyright 2016 M.Reiss and G.Rümpker

N=length(x);
y=ifft(x);
y=y*N;
end