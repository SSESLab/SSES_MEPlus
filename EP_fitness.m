% this function, handle the optimization for day ahead simple DR controls.
% The file calculates the INDIRECT emission using EPA emission factors.
%single building
function [gas,elec]=EP_fitness(x)
J_h_to_MWh=1e-6/3600;
kg_to_lbs=2.20462;
Natural_Gas_Cf=53.06;%kgCO2/mmBtu
MWh_to_mmBtu=3.412;

% modify the idf file
data=readIDF('sms_off.idf',{});
[data]=DR_IDF(data,Week(20),23,24);
writeIDF(data)
% run E+
system('energyplus -w weather_file.epw sms_off.idf')
system('readvarseso myres.rvi')

%% Energy and Emission Calculation ( CO2 for now)
m=csvread('eplusout.csv',1,1); % read the electricity use from E+ output
load('Location_CF_EPA.mat')
reg=1; % this value is determined by eGrid region of the building location. Look at the emission data for more details

Emission_elec=sum(Location_CF_EPA(reg).CO2Emission_factor_hourly(Week(20).MonthStart).hour.*m(:,15).*J_h_to_MWh); %lbs
Cost=sum(0.15*m(:,15).*J_h_to_MWh);


%% read the output from csv files

elec=sum(m(:,15));
gas=sum(m(:,16));
out=gas+elec;
hold on
plot(gas,elec,'r*')


end