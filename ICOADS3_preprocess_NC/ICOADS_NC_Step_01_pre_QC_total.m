% sbatch --account=huybers_lab  -J ICOADS_nc_preprocess  -t 10080 -p huce_intel,huce_cascade -n 1  --mem-per-cpu=20000  --array=1-172  -o err --wrap='matlab -nosplash -nodesktop -nodisplay -r "yr=$SLURM_ARRAY_TASK_ID+1849;  for mon = 1:12,  ICOADS_NC_Step_01_pre_QC(yr,mon); end;quit;">>log'
% 
% ICOADS_NC_Step_01_pre_QC(yr, mon)
%  This script pre-process ICOADS data from NCEP processed NC files
%  It also save variables as NC files
%
%  This function takes in the converted Matlab mat files, and do the following step:
%
%  a. Convert Country from number into 2 letter abbreviation
%     also convert nations according to Callsigns, and from ID of 705-707
%
%  b. Assign Country name according to deck information,
%  a list can be found in Table.1 in __Chan and Huybers (2019)__.
%
%  c. Convert WMO47 SST measurement method into
%  ICOADS IMMA SST measurement method (SI) format.
%
%  d. Assign SST measurement method to records (optional)
%  with missing values following __Kennedy et. al. (2011)__.
%  
%  e. Assign 1982-2014 climatology from OI-SST (__Reynolds, 1993__),
%  local time (starting from 0:30am - 1:30am), universal time (hours since 0001-01-01).
%
%  f. Flag records that have valid year, month, day, longitude, latitude, and SST.
%
%  Note that this function only flags but do not throw away any measurements.
%
%
% Last update: 2021-06-14

% historical comments: It worth notice that in this version II that are 6 and 7 are treated as
% ship measurements. The local time is 0.51 - 1.5 saved as 1, and 1.51 -
% 2.5 saved as 2, and so on ...

% Debug: ICOADS_NC_Step_01_pre_QC(1970,6)

function ICOADS_NC_Step_01_pre_QC(yr,mon)

    % Set direcotry of files  ---------------------------------------------
    dir_load  = ICOADS_NC_OI('nc_files');
    dir_save  = ICOADS_NC_OI('pre_QC');
    dir_OI    = ICOADS_NC_OI('Mis');
    cmon = '00';  cmon(end-size(num2str(mon),2)+1:end) = num2str(mon);
    file_load_pqc = [dir_load,'ICOADS_R',ICOADS_NC_version(yr),'T_',...
                                               num2str(yr),'-',cmon,'.nc'];
    file_save_pqc = [dir_save,'ICOADS_R',ICOADS_NC_version(yr),'T_',...
                                        num2str(yr),'-',cmon,'_preQC.nc'];
                                    
    % Process the data   --------------------------------------------------
    if ~isfile(file_load_pqc)
        disp([file_load_pqc, ' does not exit!'])
        return
    end
    
    date = ncread(file_load_pqc,'date')';
    YR   = str2num(date(:,1:4));
    MO   = str2num(date(:,5:6));
    DY   = str2num(date(:,7:8));    DY(DY == 99) = nan;  DY(DY == 0) = nan;
    HR   = double(ncread(file_load_pqc,'HR'));
    LON  = double(ncread(file_load_pqc,'lon'));
    LAT  = double(ncread(file_load_pqc,'lat'));
    SST  = double(ncread(file_load_pqc,'SST'));
    AT   = double(ncread(file_load_pqc,'AT'));
    N_meas = numel(LON);
    
    try SI = double(ncread(file_load_pqc,'SI')); catch SI = nan(N_meas,1); end
    try C1  = ncread(file_load_pqc,'C1')';  catch  C1  = char(ones(N_meas,2)*32); end
    try 
        C2  = ncread(file_load_pqc,'C2');  
        if size(C2,1) == 1
            C2 = num2str(C2);  
            if size(C2,2) == 3,    C2 = C2(:,2:3);    end
            C2(ismember(C2,'aN','rows'),:) = ' ';
        end
    catch
        C2  = char(ones(size(C1))*32);
    end
    try C1M = ncread(file_load_pqc,'C1M')'; catch  C1M = char(ones(size(C1))*32); end

    try SIM = ncread(file_load_pqc,'SIM')'; catch  SIM = char(ones(N_meas,3)*32); end
    PT = double(ncread(file_load_pqc,'PT'));
    DCK = double(ncread(file_load_pqc,'DCK'));
    SID = double(ncread(file_load_pqc,'SID'));
    II = double(ncread(file_load_pqc,'II'));
    ID = ncread(file_load_pqc,'ID')';                     
    UID = ncread(file_load_pqc,'UID')';
    
    ID(ID == 0)   = 32;
    C1(C1 == 0)   = 32;
    C2(C2 == 0)   = 32;
    C1M(C1M == 0) = 32;
    SIM(SIM == 0) = 32;
    
    % *********************************************************************
    % process country information
    % *********************************************************************
    % Convert Country # into 2 letter abbreviation ------------------------
    ID_CTY = ICOADS_NC_function_callsign2nation(ID,II);

    % For deck 705--707 (US merchant), use the first two letters of ID ----
    USM_CTY = char(ones(size(C1))*32);
    l_usm = ismember(DCK,[705 706 707]);
    USM_CTY(l_usm,1:2) = ID(l_usm,1:2);
    
    % Combine C1, C1M, and C2 ---------------------------------------------
    CTY_RAW = ICOADS_NC_function_CTY_from_indicators(C1,C2,C1M);
        
    % Further combine with ID_CTY and USM_CTY -----------------------------
    CTY_MID = CTY_RAW;   l = all(CTY_MID == 32,2);  CTY_MID(l,:) = ID_CTY(l,:);
    CTY = CTY_MID;       l = all(CTY == 32,2);      CTY(l,:) = USM_CTY(l,:);

    % Assign Country name according to deck ---------------------------
    CTY_CRT = ICOADS_NC_function_CTY_from_deck(CTY,DCK);

    % *********************************************************************
    % process SST method information
    % *********************************************************************
    % Convert WMO47 into Measurement Method code --------------------------
    SIWMO = ICOADS_NC_function_SI_from_WMO47(SIM);

    % Assign SST method following Kennedy 2011 ----------------------------
    [~,SI_1,SI_2,SI_3,SI_4] = ICOADS_NC_function_SI_from_indicators_and_inference(SI,YR,DCK,SID,II,SIWMO,CTY_CRT,PT);

    % *********************************************************************
    % assign climatology, local time, universial time, and nan flag
    % *********************************************************************
    % Assign UTC and Local Time -------------------------------------------
    LCL = rem(HR + LON./15, 24);
    LCL (LCL < 0)  = LCL (LCL < 0)  + 24;
    LCL (LCL > 24) = LCL (LCL > 24) - 24;
    LCL_int = round(LCL);  LCL_int(LCL_int == 0) = 24;

    % UTC -----------------------------------------------------------------
    UTC = (datenum([YR, MO, DY])-1)*24 + HR;
    
    % SST climatology -----------------------------------------------------
    [OI_CLIM,QC_NON_SST] = ICOADS_NC_function_find_SST_clim(YR,MO,DY,SST,LON,LAT,dir_OI);

    % AT climatology -----------------------------------------------------
    [ERA_CLIM,QC_NON_AT] = ICOADS_NC_function_find_AT_clim(YR,MO,DY,AT,LON,LAT,dir_OI);

    clear('dir_OI','fid','file_load','file_load_pqc','file_save');
    % *********************************************************************
    % Process UID into a number
    % *********************************************************************
    UID = UID - '0';
    UID(UID>9) = UID(UID>9)-7;
    UID = UID(:,1)*36^5 + UID(:,2)*36^4 + UID(:,3)*36^3 + UID(:,4)*36^2 + UID(:,5)*36 + UID(:,6);
    
    % *********************************************************************
    % save data
    % *********************************************************************
    disp(['Saving ', file_save_pqc,' ...'])
    disp('Saving data...')
    ICOADS_NC_function_ncsave(file_save_pqc,'ID_CTY',ID_CTY,'char');
    ICOADS_NC_function_ncsave(file_save_pqc,'USM_CTY',USM_CTY,'char');   
    ICOADS_NC_function_ncsave(file_save_pqc,'CTY_CRT',CTY_CRT,'char'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'SI1',SI_1,'int16'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'SIWMO',SIWMO,'int16'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'SI_Std',SI_2,'int16'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'SI_K12',SI_4,'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'OI_CLIM',OI_CLIM,'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'QC_NON_SST',int16(QC_NON_SST),'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'ERA_CLIM',ERA_CLIM,'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'QC_NON_AT',int16(QC_NON_AT),'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'UID',UID,'double'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'LCL',LCL,'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'LCL_int',LCL_int,'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'UTC',UTC,'double'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'YR',YR,'int16'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'MO',MO,'int16'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'DY',DY,'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'HR',HR,'single'); 
    ICOADS_NC_function_ncsave(file_save_pqc,'ID',ID,'char'); 
    
end
