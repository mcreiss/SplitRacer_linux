function [y,dtfac]=reduce(N,x)

%reduce number of data points by interpolation to desired number N

% usage: 
% N: new number of sample points
% x: time series

% Copyright 2016 M.Reiss and G.Rümpker

NX=length(x);
t=linspace(0,NX-1,NX);
dtfac=(NX-1)/(N-1);
y=zeros(N,1);

for k=1:N
    
    ti=(k-1)*dtfac;
    y(k) = interp1(t,x,ti);
    
end
