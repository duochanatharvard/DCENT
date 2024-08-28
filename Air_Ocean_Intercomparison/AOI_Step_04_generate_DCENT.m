function AOI_Step_04_generate_DCENT(num,Para_AOI)

    SATH_GHCN_post_setup;

    % Load ship and buoy SSTs
    SST_buoy = AOI_read_data('SST_buoy', num, Para_AOI);
    N_buoy   = AOI_read_data('N_buoy',   num, Para_AOI);
    load([AOI_IO('data',P),'AOI_Corrected_SST_gridded_',PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat']);
    SST_corr = SST_corr_taper;
    N_ship   = AOI_read_data('N_ship',   num, Para_AOI);

    % Load gridded LATs
    fin      = [SATH_IO(case_name,'dir_member',mem_id),'Y_corrected_SAT_anm_gridded_',PHA_version,'.mat'];
    % fin      = [SATH_IO('mat_GHCN_processed',P),'Corrected_SAT_gridded.mat'];
    load(fin,'SAT_grid'); 
    SAT_grid = SAT_grid(:,:,:,(1850-1699):end,Para_AOI.do_round);            % TODO

    % Combine ship SST with Buoy SSTs
    N_buoy2                 = N_buoy;
    N_buoy2(N_buoy2 > 2000) = 2000;
    [SST_ship_ref_buoy, SST_buoy_ref_ship] = ...
                AOI_func_corr_ship_to_buoy(SST_corr,SST_buoy,N_ship,N_buoy2);
    SST = AOI_func_combine_two_fields(SST_corr,SST_buoy_ref_ship,N_ship,N_buoy2*6.8);

    % Combine ChanLAT with Chan SST
    load('mask_of_land_ocean_ratio.mat','w_use')
    w2 = repmat(w_use,1,1,size(SAT_grid,3),size(SAT_grid,4));

    T  = AOI_func_combine_two_fields(SAT_grid,SST,w2,1-w2);

    % Save temperatures as nc files
    disp('Saving data...')

    fsave = [AOI_IO('ChanT',P),'DCENT_ensemble_',num2str(num),'_R_',num2str(Para_AOI.do_round),'.nc'];
    delete(fsave)

    lon = 2.5:5:357.5;
    lat = -87.5:5:87.5;
    mon = 1:12;
    yr  = (1:size(T,4)) + 1849;

    % Generate time information
    nccreate(fsave,'lon','Dimensions', {'lon',72},...
        'Datatype','double','FillValue','disable','Format','netcdf4');
    ncwrite(fsave,'lon',lon);

    nccreate(fsave,'lat','Dimensions', {'lat',36},...
        'Datatype','double','FillValue','disable','Format','netcdf4');
    ncwrite(fsave,'lat',lat);

    nccreate(fsave,'month','Dimensions', {'month',12},...
        'Datatype','double','FillValue','disable','Format','netcdf4');
    ncwrite(fsave,'month',mon);

    nccreate(fsave,'year','Dimensions', {'year',numel(yr)},...
        'Datatype','double','FillValue','disable','Format','netcdf4');
    ncwrite(fsave,'year',yr);

    nccreate(fsave,'T','Dimensions', {'lon',72,'lat',36,'month',12,'year',numel(yr)},...
        'Datatype','single','FillValue','disable','Format','netcdf4');
    ncwrite(fsave,'T',T);
    ncwriteatt(fsave,'T','units','degree C');

    nccreate(fsave,'SST','Dimensions', {'lon',72,'lat',36,'month',12,'year',numel(yr)},...
        'Datatype','single','FillValue','disable','Format','netcdf4');
    ncwrite(fsave,'SST',SST);
    ncwriteatt(fsave,'SST','units','degree C');

    nccreate(fsave,'LAT','Dimensions', {'lon',72,'lat',36,'month',12,'year',numel(yr)},...
        'Datatype','single','FillValue','disable','Format','netcdf4');
    ncwrite(fsave,'LAT',SAT_grid);
    ncwriteatt(fsave,'LAT','units','degree C');
end
