SATH_setup;

% *************************************************************************
% Load data 
% *************************************************************************
fload  = SATH_IO(case_name,'attribute',mem_id, PHA_version);
load(fload,'Para','BP_att');

D           = SATH_IO(case_name,'raw_data',mem_id,PHA_version);
sta_list    = 1:size(D.T,1); 

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
tic;
disp(repmat('#',1,100))
disp('4. Combine nearby breakpoints')
BP_comb = PHA_S4_combine_bps_NOAA(BP_att, D, sta_list, Para);
toc;

disp('save data...')
fsave  = SATH_IO(case_name,'combined',mem_id, PHA_version);
disp(fsave)
save(fsave,'BP_comb','Para','-v7.3');