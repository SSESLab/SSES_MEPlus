% this function, handle the optimization for day ahead simple DR controls.
% The file calculates the INDIRECT emission using EPA emission factors.
%single building
function y=EP_fitness(x)
global J_h_to_MWh
global kg_to_lbs
global Natural_Gas_Cf
global MWh_to_mmBtu
global PV_SD_01_09_MWh_Sml
global PV_SD_07_17_MWh_Sml
global PV_SD_07_17_MWh_Large
global PV_SD_01_09_MWh_Large
global PV_SD_01_09_MWh_Med
global PV_SD_07_17_MWh_Med
global Location_CF_EPA
global Week
global data_Med
global data_Lrg
global data_Sml
global LMP
global sml_Elec_07_17



% modify the idf file
[data_mod_lrg]=DR_IDF_lrg(data_Lrg,Week(2),x(1),x(2),x(3),x(4),6);
[data_mod_Med]=DR_IDF_med(data_Med,Week(2),x(5),x(6),x(7),x(8),6);
writeIDF(data_mod_lrg,'Lrg_test')
writeIDF(data_mod_Med,'Med_test')
[data_mod_Sml]=DR_IDF_sml(data_Sml,Week(2),x(9),x(10),x(11),x(12),6);
 writeIDF(data_mod_Sml,'Sml_test')
%% run E+ for SML office
if system('energyplus -w SD_TMY3.epw Sml_test.idf')==0
    system('readvarseso myres.rvi')

    % Energy and Emission Calculation ( CO2 for now) for Med Office
    m=csvread('eplusout.csv',1,1); % read the electricity use from E+ output
    reg=6; % this value is determined by eGrid region of the building location. Look at the emission data for more details
    purch_sml=(sum(reshape(m(:,21),6,24)))'.*J_h_to_MWh-PV_SD_01_09_MWh_Sml;
    Excess_sml=-purch_sml;
    purch_sml(purch_sml<0)=0;
    Excess_sml(Excess_sml<0)=0;
    Emission_gas_sml=sum((sum(reshape(m(:,22),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*Natural_Gas_Cf);
    Cost_gas_sml=sum((sum(reshape(m(:,22),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*Natural_Gas_Cf.*8.57);%https://www.eia.gov/dnav/ng/NG_PRI_SUM_DCU_SCA_M.htm [Made an average for last 6 months]
%     Cost_gas_med=sum((sum(reshape(m(:,58),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*10.0023877.*33); %mmbtu is 10.0023877 therms and each therm is 33 dolors in sandiego [https://www.chooseenergy.com/shop/residential/naturalgas/CA/92101/sdge-ca-naturalgas/]
    Emission_elec_sml=sum(Location_CF_EPA(reg).CO2Emission_factor_hourly(Week(2).MonthStart).hour.*purch_sml); %lbs
    Cost_elec_sml=sum(LMP(:,1).*purch_sml); % LMP values from http://oasis.caiso.com/mrioasis/logon.do
    % ashrae 55 discomfort for sml Office
    k=1;
    penalty_sml=0;
    for z=15:20  % large office output
        zone_55_sml(:,k)=m(48:108,z);
        count=0;
        if any(nonzeros(zone_55_sml(:,k)))
            for s=1:length(zone_55_sml(:,k))
                if zone_55_sml(s,k)==0
                    count=0;
                else
                    count=count+1;
                    penalty_sml=count.*zone_55_sml(s,k)+penalty_sml;
                end
            end
        end
        k=k+1;
    end
else
    penalty_sml=1000000000;
    Emission_elec_sml=1000000000;
    Emission_gas_sml=100000000000;
    Cost_elec_sml=100000000000;
    Cost_gas_sml=100000000000;
    Excess_sml=zeros(24,1);
end
clear m
%% run E+ for Med office
if system('energyplus -w SD_TMY3.epw Med_test.idf')==0
    system('readvarseso myres.rvi')

    % Energy and Emission Calculation ( CO2 for now) for Med Office
    m=csvread('eplusout.csv',1,1); % read the electricity use from E+ output
    reg=6; % this value is determined by eGrid region of the building location. Look at the emission data for more details
    purch_med=(sum(reshape(m(:,57),6,24)))'.*J_h_to_MWh-PV_SD_01_09_MWh_Med;
    Excess_med=-purch_med;
    purch_med(purch_med<0)=0;
    Excess_med(Excess_med<0)=0;
    Emission_gas_med=sum((sum(reshape(m(:,58),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*Natural_Gas_Cf);
    Cost_gas_med=sum((sum(reshape(m(:,58),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*Natural_Gas_Cf.*8.57);%https://www.eia.gov/dnav/ng/NG_PRI_SUM_DCU_SCA_M.htm [Made an average for last 6 months]
%     Cost_gas_med=sum((sum(reshape(m(:,58),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*10.0023877.*33); %mmbtu is 10.0023877 therms and each therm is 33 dolors in sandiego [https://www.chooseenergy.com/shop/residential/naturalgas/CA/92101/sdge-ca-naturalgas/]
    Emission_elec_med=sum(Location_CF_EPA(reg).CO2Emission_factor_hourly(Week(2).MonthStart).hour.*purch_med); %lbs
    Cost_elec_med=sum(LMP(:,1).*purch_med); % LMP values from http://oasis.caiso.com/mrioasis/logon.do
    % ashrae 55 discomfort for Med Office
    k=1;
    penalty_Med=0;
    for z=39:56  % large office output
        zone_55_Med(:,k)=m(48:108,z);
        count=0;
        if any(nonzeros(zone_55_Med(:,k)))
            for s=1:length(zone_55_Med(:,k))
                if zone_55_Med(s,k)==0
                    count=0;
                else
                    count=count+1;
                    penalty_Med=count.*zone_55_Med(s,k)+penalty_Med;
                end
            end
        end
        k=k+1;
    end
else
    penalty_Med=1000000000;
    Emission_elec_med=1000000000;
    Emission_gas_med=100000000000;
    Cost_elec_med=100000000000;
    Cost_gas_med=100000000000;
    Excess_med=zeros(24,1);
end
% Cooling and heating Loads
%  Cooling_elec_med=sum((sum(reshape(m(:,59),6,24)))'.*J_h_to_MWh);
%  Heating_gas_med=sum((sum(reshape(m(:,61),6,24)))'.*J_h_to_MWh);
%  Heating_elec_med=sum((sum(reshape(m(:,50),6,24)))'.*J_h_to_MWh);

clear m
%% run E+ for Lrg office
if system('energyplus -w SD_TMY3.epw Lrg_test.idf')==0
    system('readvarseso myres.rvi')
    
    % Energy and Emission Calculation ( CO2 for now) for Med Office
    m=csvread('eplusout.csv',1,1); % read the electricity use from E+ output
    reg=6; % this value is determined by eGrid region of the building location. Look at the emission data for more details
%     Excess_sml=25.*(PV_SD_01_09_MWh_Sml-sml_Elec_07_17.*J_h_to_MWh).*((PV_SD_01_09_MWh_Sml-sml_Elec_07_17.*J_h_to_MWh)>0); %campus
    purch_Lrg=(sum(reshape(m(:,73),6,24)))'.*J_h_to_MWh-25.*Excess_sml-PV_SD_01_09_MWh_Large-10*Excess_med; %Campus
%     purch_Lrg=(sum(reshape(m(:,73),6,24)))'.*J_h_to_MWh-PV_SD_01_09_MWh_Large;
    purch_Lrg(purch_Lrg<0)=0;
    Emission_gas_Lrg=sum((sum(reshape(m(:,74),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*Natural_Gas_Cf);
    Cost_gas_Lrg=sum((sum(reshape(m(:,74),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*Natural_Gas_Cf.*8.57);%https://www.eia.gov/dnav/ng/NG_PRI_SUM_DCU_SCA_M.htm
    %     Cost_gas_Lrg=sum((sum(reshape(m(:,74),6,24)))'.*J_h_to_MWh.*MWh_to_mmBtu.*10.0023877.*33); %mmbtu is 10.0023877 therms and each therm is 33 dolors in sandiego [https://www.chooseenergy.com/shop/residential/naturalgas/CA/92101/sdge-ca-naturalgas/]
    Emission_elec_Lrg=sum(Location_CF_EPA(reg).CO2Emission_factor_hourly(Week(2).MonthStart).hour.*purch_Lrg); %lbs
    Cost_elec_Lrg=sum(LMP(:,1).*purch_Lrg);
    % ashrae 55 discomfort for Med Office
    k=1;
    penalty_Lrg=0;
    for z=49:71 % large office output
        zone_55_Lrg(:,k)=m(48:108,z);
        count=0;
        if any(nonzeros(zone_55_Lrg(:,k)))
            for s=1:length(zone_55_Lrg(:,k))
                if zone_55_Lrg(s,k)==0
                    count=0;
                else
                    count=count+1;
                    penalty_Lrg=count.*zone_55_Lrg(s,k)+penalty_Lrg;
                end
            end
        end
        k=k+1;
    end
else
    
    penalty_Lrg=1000000000;
    Emission_elec_Lrg=1000000000;
    Emission_gas_Lrg=100000000000;
    Cost_elec_Lrg=100000000000;
    Cost_gas_Lrg=100000000000;
end
% 
% Cooling_elec_Lrg=sum((sum(reshape(m(:,72),6,24)))'.*J_h_to_MWh);
% Heating_gas_Lrg=sum((sum(reshape(m(:,76),6,24)))'.*J_h_to_MWh);
% Heating_elec_Lrg=sum((sum(reshape(m(:,75),6,24)))'.*J_h_to_MWh);

%% objectives
y(1)=Emission_elec_Lrg+Emission_gas_Lrg+10.*Emission_elec_med+10.*Emission_gas_med+25.*Emission_gas_sml+25.*Emission_elec_sml;
y(2)=Cost_elec_Lrg+Cost_gas_Lrg+penalty_Lrg+10.*Cost_elec_med+10.*Cost_gas_med+10*penalty_Med+Cost_gas_sml.*25+Cost_elec_sml.*25+penalty_sml.*25;
% 
% Cost_elec_sml=1.9967;
% Cost_gas_sml=0;
% Emission_elec_sml=28.8044;
% Emission_gas_sml=0;
% penalty_sml=0;
% 
% %% post process
% 
% Emission_elec_Lrg_post(pop)=Emission_elec_Lrg;
% Emission_elec_med_post(pop)=Emission_elec_med;
% Emission_elec_sml_post(pop)=Emission_elec_sml;
% Emission_gas_Lrg_post(pop)=Emission_gas_Lrg;
% Emission_gas_med_post(pop)=Emission_gas_med;
% Emission_gas_sml_post(pop)=Emission_gas_sml;
% 
% Cost_elec_Lrg_post(pop)=Cost_elec_Lrg;
% Cost_elec_med_post(pop)=Cost_elec_med;
% Cost_elec_sml_post(pop)=Cost_elec_sml;
% 
% Cost_gas_Lrg_post(pop)=Cost_gas_Lrg;
% Cost_gas_med_post(pop)=Cost_gas_med;
% Cost_gas_sml_post(pop)=Cost_gas_sml;
% 
% penalty_Lrg_post(pop)=penalty_Lrg;
% penalty_med_post(pop)=penalty_Med;
% penalty_sml_post(pop)=penalty_sml;
% 
% Cost_gas_post=Cost_gas_Lrg_post+10.*Cost_gas_med_post+25.*Cost_gas_sml_post;
% Cost_elec_post=Cost_elec_Lrg_post+10.*Cost_elec_med_post+25.*Cost_elec_sml_post;
% 
% Emission_gas_post=Emission_gas_Lrg_post+10.*Emission_gas_med_post+25.*Emission_gas_sml_post;
% Emission_elec_post=Emission_elec_Lrg_post+10.*Emission_elec_med_post+25.*Emission_elec_sml_post;

% penalty_post=penalty_Lrg_post+10.*penalty_med_post+25.*penalty_sml_post;



end