function data=lightingIDF(data,intensity)
j=0;
aa=zeros(20,1);
for i=1:length(data)
    if strfind(data(i).class,'Lights')
        j=j+1;
        aa(j)=i;
    end
end
ind=nonzeros(aa);
for i=1:length(ind)
    data(ind(i)).fields(6)={num2str(intensity)};
end

end