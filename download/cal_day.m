function [year_out, month_out, days_out]=cal_day(year_in,days_in)

%function [year, month, days]=cal_day(year,days)
%Converts from julian day to calendrian date
% See also jul_day(year,month,day)

% Copyright A. Kaviani, 2015

for ii=1:length(year_in)
    year=year_in(ii);
    days=days_in(ii);
    daycount=[31,28,31,30,31,30,31,31,30,31,30,31];
    boolan=~mod(year,4) && ( (mod(year,100)) || (~mod(year,400)));
	if(boolan) daycount(2)=29;end
    days=min(days,sum(daycount));
    month=1;
	while days>daycount(month)
        days=days-daycount(month);
        month=mod((month+1),13);
    end
    year_out(ii)=year;
    month_out(ii)=month;
    days_out(ii)=days;
end
    
