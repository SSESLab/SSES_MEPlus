function [gas,elec]=EP_fitness(x)
%% modify the idf file
data=readIDF('test.idf',{});
data=TsetpointIDF(data,[x(1),x(2)]);
writeIDF(data)
%%run E+
system('energyplus -w weather_file.epw test.idf')
system('readvarseso myres.rvi')

%% read the output from csv files
m=csvread('eplusout.csv',1,1);
elec=sum(m(:,15));
gas=sum(m(:,16));
out=gas+elec;
hold on
plot(gas,elec,'r*')


end