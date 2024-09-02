% DCENT_en     --    1:200  1:100-R1 101:200-R3
% num(1:100)   --    1-50 auto  51-100 GAPL 

function ERRSTR_Step_05_LSAT(DCENT_en,reso)

    yr_st    = 1850;
    
    num      = DCENT_en;
    if num > 100 
        num = num - 100; 
        Round_id = 3;
    else
        Round_id = 1;
    end
    
    if num <= 50
        mem_id = num - 1;
        PHA_version = 'auto';
    else
        mem_id = num - 51;
        PHA_version = 'GAPL';
    end
    
    % Load LSAT data ------------------------------------------------------
    dir     = SATH_IO('GHCN','dir_member',mem_id);
    if reso == 1
        load([dir,'Y_corrected_SAT_anm_gridded_1X1_',PHA_version,'.mat'],'SAT_N');
        load('Sampling_error_base_from_CRUTEM5.mat','sampling_base_1X1');
        err_base = sampling_base_1X1;
        clear('sampling_base_1X1');
    elseif reso == 5
        load([dir,'Y_corrected_SAT_anm_gridded_5X5_',PHA_version,'.mat'],'SAT_N');
        load('Sampling_error_base_from_CRUTEM5.mat','sampling_base_5X5');
        err_base = sampling_base_5X5;
        clear('sampling_base_5X5');
    end
    SAT_N = SAT_N(:,:,:,(yr_st-1699):end,:);
    today_year = size(SAT_N,4) + yr_st - 1;
    
    % Calculate sampling and measurement uncertainty ----------------------
    LSAT_samp_meas_sigma2 = repmat(err_base,1,1,1,size(SAT_N,4)) ./ SAT_N(:,:,:,:,Round_id);

    % Calculate time to be saved ------------------------------------------
    
    % Define the start and end dates
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

    % Save data as .nc files ----------------------------------------------
    ncfilename = [ERRSTR_OI('LSAT_Uncertainty_nc'),'DCENT_en_',num2str(DCENT_en),'_LSAT_Uncertainty_reso_',num2str(reso),'.nc'];
    if isfile(ncfilename), delete(ncfilename); end

    nccreate(ncfilename, 'lon', 'Dimensions', {'lon', 360/reso}, 'Datatype', 'single');
    nccreate(ncfilename, 'lat', 'Dimensions', {'lat', 180/reso}, 'Datatype', 'single');
    nccreate(ncfilename, 'time', 'Dimensions', {'time', Inf}, 'Datatype', 'single');
    nccreate(ncfilename, 'sigma2', 'Dimensions', {'lon', 360/reso, 'lat', 180/reso, 'time', Inf}, 'Datatype', 'single');

    lon = (reso/2):reso:360;
    lat = ((reso/2):reso:180) - 90;

    % Write data to the variables
    ncwrite(ncfilename, 'lon', lon);
    ncwrite(ncfilename, 'lat', lat);
    ncwrite(ncfilename, 'time', daysSinceStart);
    ncwrite(ncfilename, 'sigma2', LSAT_samp_meas_sigma2(:,:,:));

    % Add global attributes
    ncwriteatt(ncfilename, '/', 'Conventions', 'CF-1.11');
    ncwriteatt(ncfilename, '/', 'title', 'Native Format of monthly uncertainty estimate for DCENT LSAT');
    ncwriteatt(ncfilename, '/', 'history', datestr(now));
    ncwriteatt(ncfilename, '/', 'institution', 'University of Southampton - Harvard University - Woods Hole Oceanographic Institution - UK National Oceanography Centre');
    ncwriteatt(ncfilename, '/', 'comment', ['This file contains DCENT uncertainty field for DCENT member ',num2str(DCENT_en)]);
    % ncwriteatt(ncfilename, '/', 'references', 'Chan, D., Gebbie, G., Huybers, P. & Kent, E. C. DCENT: Dynamically Consistent ENsemble of Temperature at the Earth Surface. https://doi.org/10.7910/DVN/NU4UGW (2024).');

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

    % Sigma2 attributes
    ncwriteatt(ncfilename, 'sigma2', 'units', 'degree_Celsius^2');
    ncwriteatt(ncfilename, 'sigma2', 'standard_name', 'sampling_and_measurement_uncertainty');
    ncwriteatt(ncfilename, 'sigma2', 'long_name', 'Sampling and measurement uncertainty');
    ncwriteatt(ncfilename, 'sigma2', 'missing_value', single(NaN));
    ncwriteatt(ncfilename, 'sigma2', 'valid_min', single(min(LSAT_samp_meas_sigma2(:))));
    ncwriteatt(ncfilename, 'sigma2', 'valid_max', single(max(LSAT_samp_meas_sigma2(:))));

end
