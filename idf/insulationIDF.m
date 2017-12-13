function data=insulationIDF(data,flag)
% material definition

mat.class='Material:NoMass';
mat.fields(1)={'Thermal Insulation'};
mat.fields(2)={'MediumRough'};
mat.fields(3)={25.000};
mat.fields(4)={0.9000}
mat.fields(5)={0.7000};
mat.fields(6)={0.8000};

%finding the index
j=0;
k=0;
l=0;
for i=1:length(data)
    if any(strfind(data(i).class,'Material:NoMass')) && j==0
        j=i; %adding a new material
    elseif strfind(data(i).class,'Construction')
        if (cellfun(@any,(strfind((data(i).fields(1)),'Ext Wall'))))
            k=i; %adding wall insulation
        elseif (cellfun(@any,(strfind((data(i).fields(1)),'Roof'))))
            l=i; %adding roof insulation
        end
    end
    
end
% reconstruction of the idf file
data_temp=struct;
data_temp=data(1:j);
data_temp(j+1)=mat;
data_temp(j+2:length(data)+1)=data(j+1:end);
if flag==1 % both wall and roof
    %wall
    temp=data_temp(k+1).fields;
    data_temp(k+1).fields(2)=mat.fields(1);
    data_temp(k+1).fields(3:length(temp)+1)=temp(2:end);
    
    %roof
    temp=data_temp(l+1).fields;
    data_temp(l+1).fields(2)=mat.fields(1);
    data_temp(l+1).fields(3:length(temp)+1)=temp(2:end);
else
    
    %only wall
    temp=data_temp(k+1).fields;
    data_temp(k+1).fields(2)=mat.fields(1);
    data_temp(k+1).fields(3:length(temp)+1)=temp(2:end);
    
end
data=data_temp;
end
