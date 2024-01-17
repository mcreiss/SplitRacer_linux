function [phases]=get_tt(eq_dist,eq_depth)

% table look up of travel times
% usage:
% eq_dist: distance earthquake - station
% eq_depth: event depth

% Copyright 2016 M.Reiss and G.Rümpker

% load travel time files
load('P.mat')
load('Pdiff.mat')
load('PKS.mat')
load('PKIKS.mat')
load('S.mat')
load('Sdiff.mat')
load('ScS.mat')
load('SKS.mat')
load('SKKS.mat')
load('SKIKS.mat')

% table look up with interpolation
[t.P]=interp_tt(P,eq_dist,eq_depth);
[t.Pdiff]=interp_tt(Pdiff,eq_dist,eq_depth);
[t.PKS]=interp_tt(PKS,eq_dist,eq_depth);
[t.PKIKS]=interp_tt(PKIKS,eq_dist,eq_depth);

[t.S]=interp_tt(S,eq_dist,eq_depth);
[t.Sdiff]=interp_tt(Sdiff,eq_dist,eq_depth);
[t.SKS]=interp_tt(SKS,eq_dist,eq_depth);
[t.SKKS]=interp_tt(SKKS,eq_dist,eq_depth);
[t.SKIKS]=interp_tt(SKIKS,eq_dist,eq_depth);
[t.ScS]=interp_tt(ScS,eq_dist,eq_depth);

fn = fieldnames(t);

% remove non existent phases
for iF = 1:length(fn)
    af = fn{iF};
    if isnan(t.(af))
        t = rmfield(t,af);
    end
end


fn2 = fieldnames(t);
% rewrite fields
for iF2 = 1:length(fn2)
    af = fn2{iF2};
    phases(iF2).name = af;
    phases(iF2).tt = t.(af);
end 

if exist('phases','var') == 0
    phases = 0;
end

end