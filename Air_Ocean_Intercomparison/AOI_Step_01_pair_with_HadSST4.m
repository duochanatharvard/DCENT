% Pair Coastal Station data with HadSST4 median estimate
function AOI_Step_01_pair_with_HadSST4(num,Para_AOI)
    
    % *********************************************************************
    % Load GHCNmV4
    % *********************************************************************
    SATH_GHCN_post_setup;
    % fin        = [SATH_IO('mat_GHCN_processed',P),'Homogenized_T.mat'];  
    % load(fin,'D');
    fin          = SATH_IO(case_name,'result_R3',mem_id, PHA_version);
    D            = load(fin,'T','T_comb','T_final','lon','lat','N_nb');
    D0           = SATH_IO(case_name,'raw_data',mem_id,PHA_version);
    D.Sta        = D0.Sta;
    clear('D0')
    fin          = [SATH_IO(case_name,'dir_raw_data',mem_id, PHA_version),'Coastal_station_list_qcu_',GHCN_IO('date'),'.mat'];
    load(fin,'ID_coastal_station');
    ID_cst     = ID_coastal_station;
    l_cst      = ismember(char(D.Sta),ID_cst,'rows');
    l_yr       = [Para_AOI.yr_sub_st:Para_AOI.yr_sub_ed]-Para_AOI.yr_st+1;
    Data       = CDC_subset2(D,l_cst,1);

    if Para_AOI.do_round == 1
        temp   = reshape(Data.T,size(Data.T,1),12,size(Data.T,2)/12);
    elseif Para_AOI.do_round == 2
        temp   = reshape(Data.T_comb,size(Data.T_comb,1),12,size(Data.T_comb,2)/12);
    elseif Para_AOI.do_round == 3
        temp   = reshape(Data.T_final,size(Data.T_final,1),12,size(Data.T_final,2)/12);
    end

    Data.T     = temp(:,:,l_yr);
    temp       = reshape(Data.N_nb,size(Data.N_nb,1),12,size(Data.N_nb,2)/12);
    Data.N_nb  = temp(:,:,l_yr);
    Data.Lon   = Data.lon;
    Data.Lat   = Data.lat;
    clear('temp','ID_coastal_station','ID_cst')

    % Split segments into different stations
    SEG        = PHA_func_assign_setments(Data.T(:,:),Data.N_nb(:,:),P.MIN_STNS,120);
    [Data.T,Data.Lon,Data.Lat,I]   = PHA_func_augment_stations(Data.T(:,:),SEG,Data.Lon,Data.Lat);
    Data.T     = reshape(Data.T,size(Data.T,1),12,size(Data.T,2)/12);
    Data       = rmfield(Data,{'lon','lat','T_final','N_nb'});
    Data.Sta   = Data.Sta(I,:);
    clear('SEG','I')

    % *********************************************************************
    % Pair HadSST4
    % *********************************************************************
    Data.HadSST4_anm  = AOI_func_pair_HadSST4(Data.Lon,Data.Lat,Para_AOI,0);

    % *********************************************************************
    % Save data
    % *********************************************************************
    % Subset stations that have HadSST4 paired ----------------------------
    %                         and at least 120 months of observational data
    l_use_1 = ~all(isnan(Data.HadSST4_anm(:,:)),2) & (nansum(~isnan(Data.T(:,:)),2)>=120);
    
    % Subset only high quality tations in further analysis
    l_use_2 = AOI_func_high_quality_stations(Data.T,Data.HadSST4_anm,Para_AOI);
    
    Data    = CDC_subset2(Data,l_use_1 & l_use_2,1);
    clear('l_use_1','l_use_2')

    % save data -----------------------------------------------------------
    raw_SAT_full  = Data.T;
    raw_SST_anm   = Data.HadSST4_anm;
    lon           = Data.Lon;     lon(lon<0) = lon(lon<0) + 360;
    lat           = Data.Lat;
    stations      = Data.Sta;

    % Calculate SAT anomalies
    [raw_SAT_anm,Tier] = AOI_func_connect_stations(raw_SAT_full,lon,lat,Para_AOI);

    file_save = [AOI_IO('data',P),'AOI_paired_coastal_SAT_SST_anomalies_',P.PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat'];
    save(file_save,'raw_SAT_full','raw_SST_anm','lon','lat',...
                   'stations','raw_SAT_anm','Tier','-v7.3');
end
