function days=jul_day(year,month,day)

%function days=jul_day(year,month,day)
%Counts number of days from the beginning of the year.
%See also cal_day(year,days)

% Copyright A. Kaviani, 2015

    daycount=[31,28,31,30,31,30,31,31,30,31,30,31];
    [II JJ]=size(year);

    for i=1:II
        for j=1:JJ
            boolan=~mod(year(i,j),4) && ( (mod(year(i,j),100)) || (~mod(year(i,j),400)));
            if(boolan) daycount(2)=29;end
            days(i,j)=min(day(i,j),daycount(month(i,j)));
            for month1=2:month(i,j)
                days(i,j)=days(i,j)+daycount(month1-1);
            end
            daycount(2)=28;
        end
    end
