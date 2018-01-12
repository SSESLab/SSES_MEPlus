function [data]=DR_IDF(data,Week,T_low,T_high)

% DR=struct;
default_weekstart={'OfficeSmall CLGSETP_SCH_NO_OPTIMUM Default'};
default_weekend={'OfficeSmall CLGSETP_SCH_NO_OPTIMUM Default', 'OfficeSmall CLGSETP_SCH_NO_OPTIMUM Default',...
    'OfficeSmall CLGSETP_SCH_NO_OPTIMUM Summer Design Day',...
    'OfficeSmall CLGSETP_SCH_NO_OPTIMUM Winter Design Day','OfficeSmall CLGSETP_SCH_NO_OPTIMUM Default',...
    'OfficeSmall CLGSETP_SCH_NO_OPTIMUM Default'};

% skip=1;
k=1;
flag_end=0; %flag end =1 if the new schedule ends in the last week of the year.,
flag_end=0; %flag end =1 if the new schedule starts in first week  of the year.,
date_det={'OfficeSmall CLGSETP_SCH_NO_OPTIMUM','Temperature'};
Def_Tsetpoint='29.44';
Tsetpoint='23.89';

for i=1:length(Week)
    m=0;
    check=0;
    week_det={sprintf('Schedule:Week:Daily {Choghondar%d}',i)};% the problem is when we have a week with less days . need fixing.
    week_det=[week_det,default_weekstart];
    for j=1:length(Week(i).day)
        if ~(j+1==Week(i).day(j).Order)&m==0
            m=m+1;
            check=1;
            j=j-1;
        elseif j+m+1==Week(i).day(j).Order & m~=0
            check=0;
            m=m+1;
        end
        if ~strcmpi(Week(i).day(j).start,Week(i).day(j).end)& ~check
            sch_name=sprintf('OfficeSmall CLGSETP_SCH_NO_OPTIMUM Wkdy Day %d',k);
            sch_det={sch_name,'Temperature',' No','06:00',Def_Tsetpoint,num2str(Week(i).day(j).start(:,1:5)),...
                num2str(Tsetpoint),num2str(Week(i).day(j).end(:,1:5)),num2str(T_low),...
                [num2str(str2double(Week(i).day(j).end(:,1:2))+3),':00'],num2str(T_high),'24:00',Def_Tsetpoint};
            sch.class='Schedule:Day:Interval';
            sch.fields=sch_det;
            if j==1
                sch_chunk=sch;
            else
                sch_chunk=[sch_chunk;sch];
            end
            
            
            
        end
        if check
            sch_name={sprintf('  OfficeSmall CLGSETP_SCH_NO_OPTIMUM Wkdy Day')};
        end
        week_det=[week_det,sch_name];
        k=k+1;
    end
    week_det=[week_det,default_weekend];
    week.class='Schedule:Week:Daily';
    week.fields=week_det;
    if i==1
        week_chunk=week;
    else
        week_chunk=[week_chunk;week];
    end
    if (Week(i).DayStart>=2) & (Week(i).MonthEnd>=1)&i==1
        date_det=[date_det,'Schedule:Week:Daily {fe5d0827-d874-4791-bafe-4f1ed5e15184}'];
        date_det=[date_det,'1','1',num2str(Week(i).MonthStart),num2str(Week(i).DayStart-1)];
    end
    
    if (Week(i).DayEnd>=26) & (Week(i).MonthEnd==12)
        date_det=[date_det,sprintf('Schedule:Week:Daily {Choghondar%d}',i)];
        date_det=[date_det,num2str(Week(i).MonthStart),num2str(Week(i).DayStart),'12','31'];
        flag_end=1;
        
    else
        date_det=[date_det,sprintf('Schedule:Week:Daily {Choghondar%d}',i)];
        date_det=[date_det,num2str(Week(i).MonthStart),num2str(Week(i).DayStart),num2str(Week(i).MonthEnd),num2str(Week(i).DayEnd)];
    end
    
end
if flag_end~=1
    date_det=[date_det,'Schedule:Week:Daily {fe5d0827-d874-4791-bafe-4f1ed5e15184}'];
    date_det=[date_det,num2str(Week(i).MonthStart),num2str(Week(i).DayEnd+1),'12','31'];
    
end
date_chunk.class='Schedule:Year';
date_chunk.fields=date_det;

for i=1:length(data)
    if strfind(data(i).class,'Schedule:Year')
        if (cellfun(@any,(strfind((data(i).fields(1)),'OfficeSmall CLGSETP_SCH_NO_OPTIMUM'))))
            aa=i;
            break
        end
    end
end

data(aa).fields=date_chunk.fields;
for i=1:length(sch_chunk)
    data=[data,sch_chunk(i)];
end
for i=1:length(week_chunk)
    data=[data,week_chunk(i)];
end

end