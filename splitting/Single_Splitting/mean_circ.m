function mean_ang = mean_circ(angles,fa_area)

% usage:
% angles in degree as column vector
%fa_area: phi range

% Copyright 2016 M.Reiss and G.Rümpker

sin_ang = sum(sind(angles))/length(angles);
cos_ang = sum(cosd(angles))/length(angles);

if sin_ang > 0 && cos_ang>0
    
    mean_ang = atand(sin_ang/cos_ang);
    
elseif cos_ang < 0
    
    mean_ang = atand(sin_ang/cos_ang)+180;
    
elseif sin_ang < 0 && cos_ang > 0
    
    mean_ang = atand(sin_ang/cos_ang)+360;
    
end

mean_ang = mod(mean_ang,180);

if mean_ang > 90 && fa_area == 90
    mean_ang = mean_ang - 180;
elseif mean_ang < 0 && fa_area == 0
    mean_ang = mean_ang+180;
end


end