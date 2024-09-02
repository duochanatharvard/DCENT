function AOI_Step_04_generate_DCENT(num,Para_AOI)

    SATH_GHCN_post_setup;

    yr_st = 1850;
    reso  = Para_AOI.reso_x;
    app   = [num2str(reso),'X',num2str(reso)];

    % Load ship and buoy SSTs
    SST_buoy = AOI_read_data('SST_buoy', num, Para_AOI);
    N_buoy   = AOI_read_data('N_buoy',   num, Para_AOI);
    load([AOI_IO('data',P),'AOI_Corrected_SST_gridded_',app,'_',PHA_version,'_R_',num2str(Para_AOI.do_round),'.mat']);
    SST_corr = SST_corr_taper;
    N_ship   = AOI_read_data('N_ship',   num, Para_AOI);

    % Load gridded LATs
    fin      = [SATH_IO(case_name,'dir_member',mem_id),'Y_corrected_SAT_anm_gridded_',PHA_version,'.mat'];
    % fin      = [SATH_IO('mat_GHCN_processed',P),'Corrected_SAT_gridded.mat'];
    load(fin,'SAT_grid'); 
    SAT_grid = SAT_grid(:,:,:,(yr_st-1699):end,Para_AOI.do_round);            % TODO

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

    % Create the NetCDF file ----------------------------------------------
    % Define the start and end dates
    today_year = size(T,4) + yr_st - 1;
    startDate = datetime(1850,1,1);
    endDate = datetime(today_year,12,31);
    
    % Generate a vector of the first of each month between the start and end dates
    dateVector = datevec(dateshift(startDate:calmonths(1):endDate, 'start', 'month'));
    
    % Calculate the number of days in each month
    daysInMonth = eomday(dateVector(:,1), dateVector(:,2));
    
    % Calculate the mid-point of each month by adding half the days of each month to the start of the month
    dateVector(:,3) = dateVector(:,3) + round(daysInMonth/2) - 1;
    
    % Calculate the number of hours since January 1, 1850, 00:00 for each midpoint
    daysSinceStart = days(datetime(dateVector) - startDate);

    l_sst   = squeeze(any(any(~isnan(SST(:,:,:)),1),2));
    l_lsat  = squeeze(any(any(~isnan(SAT_grid(:,:,:)),1),2));
    l_use   = l_sst & l_lsat;

    if Para_AOI.do_round == 1
        id  = num;
    else
        id  = num + 100;
    end
    ncfilename = [AOI_IO('ChanT',P),'DCENT_ensemble_reso_',num2str(reso),'_1850_',num2str(today_year),'_member_',CDF_num2str(id,3),'.nc'];
    if isfile(ncfilename), delete(ncfilename); end

    nccreate(ncfilename, 'lon', 'Dimensions', {'lon', 360/reso}, 'Datatype', 'single');
    nccreate(ncfilename, 'lat', 'Dimensions', {'lat', 180/reso}, 'Datatype', 'single');
    nccreate(ncfilename, 'time', 'Dimensions', {'time', Inf}, 'Datatype', 'single');
    nccreate(ncfilename, 'sst', 'Dimensions', {'lon', 360/reso, 'lat', 180/reso, 'time', Inf}, 'Datatype', 'single');
    nccreate(ncfilename, 'lsat', 'Dimensions', {'lon', 360/reso, 'lat', 180/reso, 'time', Inf}, 'Datatype', 'single');
    nccreate(ncfilename, 'temperature', 'Dimensions', {'lon', 360/reso, 'lat', 180/reso, 'time', Inf}, 'Datatype', 'single');

    % Write data to the variables
    lon = (reso/2):reso:360;
    lat = ((reso/2):reso:180) - 90;
    ncwrite(ncfilename, 'lon', lon);
    ncwrite(ncfilename, 'lat', lat);
    ncwrite(ncfilename, 'time', daysSinceStart(l_use));

    % Example temperature data, replace with actual data
    ncwrite(ncfilename, 'sst', SST(:,:,l_use));
    ncwrite(ncfilename, 'lsat', SAT_grid(:,:,l_use));
    ncwrite(ncfilename, 'temperature', T(:,:,l_use));

    % Add global attributes
    ncwriteatt(ncfilename, '/', 'Conventions', 'CF-1.11');
    ncwriteatt(ncfilename, '/', 'title', 'Native Format Dynamically Consistent Ensemble of Temperature (DCENT) Anomaly Field');
    ncwriteatt(ncfilename, '/', 'history', datestr(now));
    ncwriteatt(ncfilename, '/', 'institution', 'University of Southampton - Harvard University - Woods Hole Oceanographic Institution - UK National Oceanography Centre');
    ncwriteatt(ncfilename, '/', 'comment', ['This file contains DCENT anomaly field at monthly ',num2str(reso),'x',num2str(reso),' degree resolution.']);
    ncwriteatt(ncfilename, '/', 'references', 'Chan, D., Gebbie, G., Huybers, P. & Kent, E. C. DCENT: Dynamically Consistent ENsemble of Temperature at the Earth Surface. https://doi.org/10.7910/DVN/NU4UGW (2024).');

    % Add variable attributes
    % Longitude attributes
    ncwriteatt(ncfilename, 'lon', 'units', 'degrees_east');
    ncwriteatt(ncfilename, 'lon', 'standard_name', 'longitude');
    ncwriteatt(ncfilename, 'lon', 'long_name', 'Longitude');

    % Latitude attributes
    ncwriteatt(ncfilename, 'lat', 'units', 'degrees_north');
    ncwriteatt(ncfilename, 'lat', 'standard_name', 'latitude');
    ncwriteatt(ncfilename, 'lat', 'long_name', 'Latitude');

    % Time attributes
    ncwriteatt(ncfilename, 'time', 'units', 'days since 1850-01-01 00:00:00');
    ncwriteatt(ncfilename, 'time', 'standard_name', 'time');
    ncwriteatt(ncfilename, 'time', 'long_name', 'Time');
    ncwriteatt(ncfilename, 'time', 'calendar', 'gregorian');

    % Temperature attributes
    ncwriteatt(ncfilename, 'sst', 'units', 'degree_Celsius');
    ncwriteatt(ncfilename, 'sst', 'standard_name', 'sea_surface_temperature_anomaly');
    ncwriteatt(ncfilename, 'sst', 'long_name', 'Sea Surface Temperature Anomaly relative to the 1982--2014 climatology.');
    ncwriteatt(ncfilename, 'sst', 'missing_value', single(NaN));
    ncwriteatt(ncfilename, 'sst', 'valid_min', single(min(SST(:))));
    ncwriteatt(ncfilename, 'sst', 'valid_max', single(max(SST(:))));

    % Temperature attributes
    ncwriteatt(ncfilename, 'lsat', 'units', 'degree_Celsius');
    ncwriteatt(ncfilename, 'lsat', 'standard_name', 'land_surface_air_temperature_anomaly');
    ncwriteatt(ncfilename, 'lsat', 'long_name', 'Land Surface Air Temperature Anomaly relative to the 1982--2014 climatology.');
    ncwriteatt(ncfilename, 'lsat', 'missing_value', single(NaN));
    ncwriteatt(ncfilename, 'lsat', 'valid_min', single(min(SAT_grid(:))));
    ncwriteatt(ncfilename, 'lsat', 'valid_max', single(max(SAT_grid(:))));

    % Temperature attributes
    ncwriteatt(ncfilename, 'temperature', 'units', 'degree_Celsius');
    ncwriteatt(ncfilename, 'temperature', 'standard_name', 'earth_surface_temperature_anomaly');
    ncwriteatt(ncfilename, 'temperature', 'long_name', 'Combined Land and Ocean Surface Temperature Anomaly relative to the 1982--2014 climatology.');
    ncwriteatt(ncfilename, 'temperature', 'missing_value', single(NaN));
    ncwriteatt(ncfilename, 'temperature', 'valid_min', single(min(T(:))));
    ncwriteatt(ncfilename, 'temperature', 'valid_max', single(max(T(:))));


    % Save temperatures as nc files
    % disp('Saving data...')
    % 
    % fsave = [AOI_IO('ChanT',P),'DCENT_ensemble_',num2str(num),'_R_',num2str(Para_AOI.do_round),'.nc'];
    % delete(fsave)
    % 
    % lon = 2.5:5:357.5;
    % lat = -87.5:5:87.5;
    % mon = 1:12;
    % yr  = (1:size(T,4)) + 1849;
    % 
    % % Generate time information
    % nccreate(fsave,'lon','Dimensions', {'lon',72},...
    %     'Datatype','double','FillValue','disable','Format','netcdf4');
    % ncwrite(fsave,'lon',lon);
    % 
    % nccreate(fsave,'lat','Dimensions', {'lat',36},...
    %     'Datatype','double','FillValue','disable','Format','netcdf4');
    % ncwrite(fsave,'lat',lat);
    % 
    % nccreate(fsave,'month','Dimensions', {'month',12},...
    %     'Datatype','double','FillValue','disable','Format','netcdf4');
    % ncwrite(fsave,'month',mon);
    % 
    % nccreate(fsave,'year','Dimensions', {'year',numel(yr)},...
    %     'Datatype','double','FillValue','disable','Format','netcdf4');
    % ncwrite(fsave,'year',yr);
    % 
    % nccreate(fsave,'T','Dimensions', {'lon',72,'lat',36,'month',12,'year',numel(yr)},...
    %     'Datatype','single','FillValue','disable','Format','netcdf4');
    % ncwrite(fsave,'T',T);
    % ncwriteatt(fsave,'T','units','degree C');
    % 
    % nccreate(fsave,'SST','Dimensions', {'lon',72,'lat',36,'month',12,'year',numel(yr)},...
    %     'Datatype','single','FillValue','disable','Format','netcdf4');
    % ncwrite(fsave,'SST',SST);
    % ncwriteatt(fsave,'SST','units','degree C');
    % 
    % nccreate(fsave,'LAT','Dimensions', {'lon',72,'lat',36,'month',12,'year',numel(yr)},...
    %     'Datatype','single','FillValue','disable','Format','netcdf4');
    % ncwrite(fsave,'LAT',SAT_grid);
    % ncwriteatt(fsave,'LAT','units','degree C');
end
