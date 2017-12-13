function writeIDF(data)

%Zahra Fallahi (May 2016) this function helps to write the idf data in the
%format of IDF file.

%Input: data is modified IDF information

name='test';

%% Writing data in text format
fileID=fopen(sprintf('%s.idf',name),'w');
for i=1:length(data)
    fprintf(fileID,sprintf('\n%s,\n',data(i).class));
    for j=1:length(data(i).fields)-1
        fprintf(fileID,sprintf('\n%s,',data(i).fields{j}));
    end
    fprintf(fileID,sprintf('\n%s;\n',data(i).fields{length(data(i).fields)}));
end
fclose(fileID);

end