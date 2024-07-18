SATH_setup;
% addpath('/n/home10/dchan/Matlab_Tool_Box/CD_Computation/')
% addpath('/n/home10/dchan/Matlab_Tool_Box/CD_Figures/')
% addpath('/n/home10/dchan/Matlab_Tool_Box/m_map')

% case_name = 'GHCN';

% Load data  ---------------------------------------------------------------
disp('Load data')
f_load  = SATH_IO(case_name,'result_R3',mem_id, PHA_version);
load(f_load,'T','T_comb','T_final')

f_load  = SATH_IO(case_name,'result',mem_id, PHA_version);
load(f_load,'NET')

% Segment data if data sparse periods have long nan intervals in between ---
Para    = PHA_assign_parameters(PHA_version,mem_id);
N_nb    = PHA_func_count_neighbor(T, NET.adj);
SEG     = PHA_func_assign_setments(T,N_nb,Para.MIN_STNS,120);

% Load raw data for lon-lat information ------------------------------------
D       = SATH_IO(case_name,'raw_data',mem_id,PHA_version);

Ns      = size(T,1);
Nt      = size(T,2);
Nr      = 3;
Ny      = Nt / 12;

% Calculate temperature anomalies relative to 1982--2014 -------------------
disp('Calculate anomalies')
Para_AOI.yr_sub_st = 1700;
Para_AOI.distance  = 300;
for ct = 1:Nr
    switch ct
        case 1, T_corr = T;
        case 2, T_corr = T_comb;
        case 3, T_corr = T_final;
    end
    [T_out,Lon_out,Lat_out]   = PHA_func_augment_stations(T_corr,SEG,D.Lon,D.Lat);
    T_corr                    = reshape(T_out,size(T_out,1),12,Ny);
    [SAT_all_anm(:,:,:,ct),~] = SATH_func_connect_stations(T_corr,Lon_out,Lat_out,Para_AOI);
end

lon                = Lon_out;
lat                = Lat_out;
file_save = [SATH_IO(case_name,'dir_member',mem_id),'Y_corrected_SAT_anm_station_level_',PHA_version,'.mat'];
save(file_save,'SAT_all_anm','lon','lat','-v7.3');

% Grid data ------------------------------------------------------------------------
disp('Gridding monthly data')
reso_x    = 5; 
reso_y    = 5; 
SAT_grid  = nan(360/reso_x,180/reso_y,12,Ny,3);
SAT_N     = nan(360/reso_x,180/reso_y,12,Ny,3);
for id = 1:3
for ct_yr = 1:size(SAT_all_anm,3)
    if rem(ct_yr,20) == 0,  disp(ct_yr);  end
    for ct_mon = 1:12
        temp = SAT_all_anm(:,ct_mon,ct_yr,id);
        l    = ~isnan(temp);
        if nnz(l) > 0
            [SAT_grid(:,:,ct_mon,ct_yr,id),SAT_N(:,:,ct_mon,ct_yr,id)] ...
                = CDC_pnt2grd(Lon_out(l),Lat_out(l),[],temp(l),reso_x,reso_y,[]);
        end
    end
end
end

SAT_GL = CDC_mask_mean(SAT_grid,[reso_y/2:reso_y:180]-90,ones(360/reso_x,180/reso_y));

% Calculate regional LAT
mask_land = CDF_region_mask(5,2);
for ct = 1:size(mask_land,3)
    SAT_REG(:,:,:,ct) = CDC_mask_mean(SAT_grid,[reso_y/2:reso_y:180]-90,mask_land(:,:,ct));
end

file_save = [SATH_IO(case_name,'dir_member',mem_id),'Y_corrected_SAT_anm_gridded_',PHA_version,'.mat'];
save(file_save,'SAT_GL','SAT_REG','SAT_grid','SAT_N','-v7.3'); 
