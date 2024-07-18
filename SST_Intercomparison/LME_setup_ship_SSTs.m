P.case_name    = 'nation_deck_method';

% Parameters for reading ICOADS data  -------------------------------------
P.ref          = 'SST';        % Use this variable's QC to read ICOADS data
P.do_connect   = 1;                          % used since step 2 of pairing
P.connect_Kobe = 1;                          % used since step 2 of pairing

P.var = {'C0_LON','C0_LAT','C0_UTC','SI_Std','C1_DCK','C0_CTY_CRT',...
         'C1_PT','C0_SST','C0_OI_CLIM','C98_UID','QC_FINAL_SST','C1_ND',...
         'C0_YR','C0_MO'};

% Parameters for paring  --------------------------------------------------
% change the below together, can choose from: 
% "Bucket_vs_Bucket" or "Ship_vs_Ship"
% simply to be consistent with, respectively, Chan&Huybers 2019 and 2021.
P.type           = 'Ship_vs_Ship';           % used since step 2 of pairing
P.pick_day_night = 0;                       % 0: day+night  1: night  2:day
P.buoy_diurnal   = 1;  % use climatological diurnal cycle in SST comparison

a = datevec(date);
P.yr_list        = [1850:a(1)];    % The analysis uses all years and months
P.subset_yr_list = [1850:a(1)];    % The analysis uses all years and months
% P.yr_list        = [1850:1870];    % The analysis uses all years and months
% P.subset_yr_list = [1850:1870];    % The analysis uses all years and months

% LME analysis  -----------------------------------------------------------
P.do_combined_analysis = 0;
P.key                  = 5000; % threshold of pairs the group to be included
P.yr_start             = 1850; % Assign yearly effects
P.yr_interval          = 5;    % This function is turned off
P.do_sampling          = 200;                                   
P.do_season            = 0;    % Whether to use do season in SAT scaling
                               % Because this is an SST only run, this parameter
                               % does not effectively matter at all.
P.pattern_sens         = 1;
% P.correct_buoy_clim    = 0;

% The parameters below are required for error model
P.varname = 'SST';    
P.method  = 'Ship';  

% Correction --------------------------------------------------------------
P.reso_x = 5;
P.reso_y = P.reso_x;
