% ICOADS_NC_Step_04_Buddy_check(yr,mon,redo)
%
% Finally, individual records are compared to the winsorized mean of individual pentad,
% and points that are three neighbor-wise standard deviations away
% from the winsorized mean do not pass buddy check. For points that grids
% that only have one measurements, the script spans out and search for neighbors
% in neighboring grids. The search spans out gradually from 1 up to 3 grids or pentads
% and the neighbors is the mean of all grids that have values.
% Measurement without a valid neighbor passes the quality control.
%
%
% Last update: 2024-04-10

function ICOADS_NC_Step_04_Buddy_check(yr,mon,redo)

    % *********************************************************************
    % Set direcotry of files
    % *********************************************************************
    dir_load_wm   = ICOADS_NC_OI('WM');
    dir_save_qc   = ICOADS_NC_OI('QCed');
    dir_buddy_std = ICOADS_NC_OI('Mis');
    
    file_load_std_sst  = [dir_buddy_std,'Buddy_std_SST.mat'];
    file_load_std_nmat = [dir_buddy_std,'Buddy_std_NMAT.mat'];
    reso_s = 1;
    reso_t = 5;
    std_key = 3;

    % *********************************************************************
    % Assign the file named to be used in this function
    % *********************************************************************
    if (mon == 1)
        clear('cmon');        cmon = '12';
        file_load_wm(1,:) = [dir_load_wm,'ICOADS_R3.0.0_',num2str(yr-1),'-',cmon,'_WM.mat'];
    else
        clear('cmon');        cmon = '00';        cmon(end-size(num2str(mon-1),2)+1:end) = num2str(mon-1);
        file_load_wm(1,:) = [dir_load_wm,'ICOADS_R3.0.0_',num2str(yr),'-',cmon,'_WM.mat'];
    end

    clear('cmon');    cmon = '00';    cmon(end-size(num2str(mon),2)+1:end) = num2str(mon);
    file_load_wm(2,:) = [dir_load_wm,'ICOADS_R3.0.0_',num2str(yr),'-',cmon,'_WM.mat'];

    if (mon == 12)
        clear('cmon');        cmon = '01';
        file_load_wm(3,:) = [dir_load_wm,'ICOADS_R3.0.0_',num2str(yr+1),'-',cmon,'_WM.mat'];
    else
        clear('cmon');        cmon = '00';        cmon(end-size(num2str(mon+1),2)+1:end) = num2str(mon+1);
        file_load_wm(3,:) = [dir_load_wm,'ICOADS_R3.0.0_',num2str(yr),'-',cmon,'_WM.mat'];
    end
    
    % *********************************************************************
    % File to be saved
    % *********************************************************************   
    clear('cmon');    cmon = '00';    cmon(end-size(num2str(mon),2)+1:end) = num2str(mon);
    file_save_qc = [dir_save_qc,'ICOADS_R',ICOADS_NC_version(yr),'_',num2str(yr),'-',cmon,'_QCed.nc'];

    if ~isfile(file_save_qc) || redo == 1
        % *********************************************************************
        % Read SST data to be quality controlled 
        % *********************************************************************
        C0_YR       = ICOADS_NC_function_read(yr,mon,'YR');
        C0_MO       = ICOADS_NC_function_read(yr,mon,'MO');
        C0_DY       = ICOADS_NC_function_read(yr,mon,'DY');
        C0_LON      = ICOADS_NC_function_read(yr,mon,'lon');
        C0_LAT      = ICOADS_NC_function_read(yr,mon,'lat');
        
        C0_SST      = ICOADS_NC_function_read(yr,mon,'SST');
        C0_OI_CLIM  = ICOADS_NC_function_read(yr,mon,'OI_CLIM');
        QC_NON_SST  = ICOADS_NC_function_read(yr,mon,'QC_NON_SST');
        C1_SNC      = ICOADS_NC_function_read(yr,mon,'SNC');
        C1_ZNC      = ICOADS_NC_function_read(yr,mon,'ZNC');
        
        C0_AT       = ICOADS_NC_function_read(yr,mon,'AT');
        C0_ERA_CLIM = ICOADS_NC_function_read(yr,mon,'ERA_CLIM');
        QC_NON_AT   = ICOADS_NC_function_read(yr,mon,'QC_NON_AT');
        C1_ANC      = ICOADS_NC_function_read(yr,mon,'ANC');
        C1_ND       = ICOADS_NC_function_read(yr,mon,'ND');
        C1_DCK      = ICOADS_NC_function_read(yr,mon,'DCK');
        C1_PT       = ICOADS_NC_function_read(yr,mon,'PT');
    
        % #####################################################################
        % For SST
        % #####################################################################
        % Read SST variance ---------------------------------------------------
        SST_std = load(file_load_std_sst,'STD_save');
    
        % Find Neighbours -----------------------------------------------------
        C0_NB = ICOADS_NC_function_get_all_neighbors(file_load_wm,...
                                    'SST',C0_LON,C0_LAT,C0_DY,reso_s,reso_t);
    
        % Compute the anomalies -----------------------------------------------
        temp_sst = C0_SST - C0_OI_CLIM;
    
        % Read the standard deviation -----------------------------------------
        clear('std_qc')
        std_qc = re_function_general_grd2pnt(C0_LON,C0_LAT,C0_MO,SST_std.STD_save,1,1,1);
        std_qc(isnan(std_qc)) = 10;
        STD_SST_NB = std_qc;
    
        % Do the buddy check ==================================================
        clear('C0_QC_ME_2','C0_QC_ME_1');
        C0_QC_ME_2 = abs((temp_sst - C0_NB)./std_qc) <= std_key;
        C0_QC_ME_2(isnan(C0_NB)) = 1;
    
        C0_QC_ME_1 = QC_NON_SST == 1 & (C0_SST > C0_OI_CLIM-10 & C0_SST < C0_OI_CLIM +10);
        C0_QC_ME_1(C0_SST > 37 | C0_SST < -5) = 0;
        C0_QC_ME_1(C1_SNC > 5) = 0;
        C0_QC_ME_1(C1_ZNC > 5 & C0_YR > 1859) = 0;
    
        QC_FINAL = C0_QC_ME_2 & C0_QC_ME_1;
    
        clear('temp_sst','std_qc_LV','std_qc','sp','nei_1','nei_2','nei_3','nei_0','nei_0_num','n','logic','k','i','j')
        clear('in_dy','file_load_sst','file_load_std_sst','fid','ans','a','WM_temp','STD_save','NUM_temp','file_save')
        clear('b','c','cmon','ct','dir_load_sst','dir_save_qc','file_save_pqc')
        clear('nei_temp','std_LV')
    
        % #####################################################################
        % For NMAT
        % #####################################################################
        % Read NMAT variance --------------------------------------------------
        NMAT_std = load(file_load_std_nmat,'STD_save');
        disp('Read Data Finish!')
        
        % Find Neighbours -----------------------------------------------------
        C0_NB_NMAT = ICOADS_NC_function_get_all_neighbors(file_load_wm,...
                                    'NMAT',C0_LON,C0_LAT,C0_DY,reso_s,reso_t);
    
        % Compute the anomalies -------------------------------------------
        temp_sst = C0_AT - C0_ERA_CLIM;
    
        % Read the standard deviation -------------------------------------
        clear('std_qc')
        std_qc = re_function_general_grd2pnt(C0_LON,C0_LAT,C0_MO,NMAT_std.STD_save,1,1,1);
        std_qc(isnan(std_qc)) = 10;
        STD_NMAT_NB = std_qc;
    
        % Do the buddy check ==================================================
        clear('C0_QC_ME_2_NMAT','C0_QC_ME_1_NMAT');
    
        C0_QC_ME_2_NMAT = abs((temp_sst - C0_NB_NMAT)./std_qc) <= std_key;
        C0_QC_ME_2_NMAT(isnan(C0_NB_NMAT)) = 1;
        
        C0_QC_ME_1_NMAT = QC_NON_AT == 1 & ((C0_AT > (C0_ERA_CLIM-10)) & (C0_AT < (C0_ERA_CLIM+10)));
        C0_QC_ME_1_NMAT(C1_ANC > 5) = 0;
        C0_QC_ME_1_NMAT(C1_ZNC > 5 & C0_YR > 1859) = 0;
        [C0_QC_ME_1_NMAT,NMAT] = ICOADS_NC_function_get_NMAT(yr,mon,...
                            C0_LON,C0_LAT,C0_AT,C0_QC_ME_1_NMAT,C1_DCK,C1_PT,C1_ND);
    
        QC_FINAL_NMAT = C0_QC_ME_2_NMAT & C0_QC_ME_1_NMAT;
    
        clear('temp_sst','std_qc_LV','std_qc','std_key','sp','nei_1','nei_2','nei_3','nei_0','nei_0_num','n','logic','k','i','j')
        clear('in_dy','file_load_sst','file_load_std_sst','file_load_std_nmat','fid','ans','a','WM_temp','STD_save','NUM_temp','file_save')
        clear('b','c','cmon','ct','dir_load_sst','dir_load_wm','dir_save_qc','file_load_wm','file_save_pqc')
        clear('nei_temp','reso_s','reso_t','std_LV','dir_buddy_std','dir_load','dir_save','ff','file_load_std_LV')
    
        % *********************************************************************
        % save data
        % *********************************************************************
        disp(['Saving ', file_save_qc,' ...'])
        disp('Saving data...')
        ICOADS_NC_function_ncsave(file_save_qc,'NMAT',NMAT,'single');
        ICOADS_NC_function_ncsave(file_save_qc,'STD_SST_NB',STD_SST_NB,'single');
        ICOADS_NC_function_ncsave(file_save_qc,'QC_ME_1_SST',int16(C0_QC_ME_1),'int16');
        ICOADS_NC_function_ncsave(file_save_qc,'QC_ME_2_SST',int16(C0_QC_ME_2),'int16');
        ICOADS_NC_function_ncsave(file_save_qc,'QC_FINAL_SST',int16(QC_FINAL),'int16');
        ICOADS_NC_function_ncsave(file_save_qc,'NB_SST',C0_NB,'single');
        ICOADS_NC_function_ncsave(file_save_qc,'STD_NMAT_NB',STD_NMAT_NB,'single');
        ICOADS_NC_function_ncsave(file_save_qc,'QC_ME_1_NMAT',int16(C0_QC_ME_1_NMAT),'int16');
        ICOADS_NC_function_ncsave(file_save_qc,'QC_ME_2_NMAT',int16(C0_QC_ME_2_NMAT),'int16');
        ICOADS_NC_function_ncsave(file_save_qc,'QC_FINAL_NMAT',int16(QC_FINAL_NMAT),'int16');
        ICOADS_NC_function_ncsave(file_save_qc,'NB_NMAT',C0_NB_NMAT,'single');
    
        disp([file_save_qc ,' is finished!']);
        disp([' ']);
    else
        disp('Target File exist, skip...');
    end
end
