function data=TsetpointIDF(data,T_band)
j=0;
aa=cell(2,2);
for i=1:length(data)
    if strfind(data(i).class,'Schedule:Day:Interval')
        if (cellfun(@any,(strfind((data(i).fields(1)),'CLGSETP_SCH_NO_OPTIMUM Wkdy Day')))...
                ||cellfun(@any,(strfind((data(i).fields(1)),'HTGSETP_SCH_NO_OPTIMUM Wkdy Day'))))      
            j=j+1;
            aa{j,1}=i;
            aa{j,2}=cell2mat((data(i).fields(1)));
        end
    end
end
if cell2mat(strfind(aa(2,2),'HTGSETP_SCH'))
    data(aa{1,1}).fields(7)={num2str(T_band(1))};
    data(aa{2,1}).fields(7)={num2str(T_band(2))};
else
    
    data(aa{1,1}).fields(7)={num2str(T_band(1))};
    data(aa{2,1}).fields(7)={num2str(T_band(2))};
end


end