
global J_h_to_MWh
global kg_to_lbs
global Natural_Gas_Cf
global MWh_to_mmBtu
global PV_SD_07_17_MWh_Sml
global PV_SD_07_17_MWh_Large
global PV_SD_01_09_MWh_Large
global PV_SD_01_09_MWh_Med
global PV_SD_07_17_MWh_Med
global PV_SD_01_09_MWh_Sml
global Location_CF_EPA
global Week
global data_Med
global data_Lrg
global data_Sml
global LMP
global Natural_Gas_Cf
global MWh_to_mmBtu
global sml_Elec_07_17
global sml_Elec_01_09

Natural_Gas_Cf=53.06;%kgCO2/mmBtu
MWh_to_mmBtu=3.412;
J_h_to_MWh=1e-6/3600;    
kg_to_lbs=2.20462;
load('PV_SD_07_17_MWh_Sml.mat')
load('PV_SD_07_17_MWh_Large')
load('PV_SD_01_09_MWh_Large')
load('PV_SD_01_09_MWh_Sml.mat')
load('PV_SD_01_09_MWh_Med')
load('PV_SD_07_17_MWh_Med')
load('Location_CF_EPA.mat')
load('Week')
load('LMP')
load('sml_Elec_05_18.mat')
load('sml_Elec_01_10.mat')
data_Med=readIDF('Med_Off_default.idf',{});
data_Lrg=readIDF('Lrg_off_Def.idf',{});
data_Sml=readIDF('sms_off_def.idf',{});

options = optimoptions('gamultiobj','PlotFcn',@gaplotpareto);
options.CreationFcn=@gacreationuniform_zahra;
options.CrossoverFcn=@crossoverintermediate_zahra;
options.FunctionTolerance=0.1;
% options.UseParalle=true;

rng default
nvars=12;
% for week later we iterate by days and weeks.
fitnessfcn=@EP_fitness
[x_lrg,fval_lrg,exitflag_lrg,output_lrg,population_lrg,scores_lrg] = gamultiobj(fitnessfcn,nvars,[],[],[],[],[21.11;21.11;8;12;21.11;21.11;8;12;21.11;21.11;8;12],[26,27,14,17,26,27,14,17,26,27,14,17],options)
