function [C0_OI_CLIM,QC_NON_SST] = ICOADS_NC_function_find_SST_clim ...
                            (C0_YR,C0_MO,C0_DY,C0_SST,C0_LON,C0_LAT,dir_OI)

    disp('Assigning OI-SST ...');

    % Assign OI-SST Climatology -------------------------------------------
    load ([dir_OI,'OI_clim_1982_2014.mat'])
    OI_clim(abs(OI_clim)>1000) = NaN;
    C0_DY(isnan(C0_DY)) = 15;
    in_dy = datenum([ones(size(C0_YR)) C0_MO C0_DY]) - 366;
    in_dy(in_dy>365) = 365;

    % addpath('/n/home10/dchan/script/Peter/ICOAD_RE/function/'); ---------
    clear('C0_OI_CLIM')
    C0_OI_CLIM = ICOADS_NC_function_general_grd2pnt(C0_LON,C0_LAT,in_dy,OI_clim,0.25,0.25,1);

    % Find Surrounding Points: level 1 ------------------------------------
    clear('temp','C0_temp')
    C0_temp(1,:) = ICOADS_NC_function_general_grd2pnt(C0_LON+0.25,C0_LAT,in_dy,OI_clim,0.25,0.25,1);
    C0_temp(2,:) = ICOADS_NC_function_general_grd2pnt(C0_LON-0.25,C0_LAT,in_dy,OI_clim,0.25,0.25,1);
    temp = nanmean(C0_temp,1);
    C0_OI_CLIM(isnan(C0_OI_CLIM)) = temp(isnan(C0_OI_CLIM));

    % Find Surrounding Points: level 2 ------------------------------------
    clear('temp','C0_temp')
    C0_temp(1,:) = ICOADS_NC_function_general_grd2pnt(C0_LON+0.5,C0_LAT,in_dy,OI_clim,0.25,0.25,1);
    C0_temp(2,:) = ICOADS_NC_function_general_grd2pnt(C0_LON-0.5,C0_LAT,in_dy,OI_clim,0.25,0.25,1);
    C0_temp(3,:) = ICOADS_NC_function_general_grd2pnt(C0_LON,min(C0_LAT+0.25,90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(4,:) = ICOADS_NC_function_general_grd2pnt(C0_LON,max(C0_LAT-0.25,-90),in_dy,OI_clim,0.25,0.25,1);
    temp = nanmean(C0_temp,1);
    C0_OI_CLIM(isnan(C0_OI_CLIM)) = temp(isnan(C0_OI_CLIM));

    % Find Surrounding Points: level 3 ------------------------------------
    clear('temp','C0_temp')
    C0_temp(1,:) = ICOADS_NC_function_general_grd2pnt(C0_LON+0.75,C0_LAT,in_dy,OI_clim,0.25,0.25,1);
    C0_temp(2,:) = ICOADS_NC_function_general_grd2pnt(C0_LON-0.75,C0_LAT,in_dy,OI_clim,0.25,0.25,1);
    C0_temp(3,:) = ICOADS_NC_function_general_grd2pnt(C0_LON+0.25,min(C0_LAT+0.25,90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(4,:) = ICOADS_NC_function_general_grd2pnt(C0_LON+0.25,max(C0_LAT-0.25,-90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(5,:) = ICOADS_NC_function_general_grd2pnt(C0_LON-0.25,min(C0_LAT+0.25,90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(6,:) = ICOADS_NC_function_general_grd2pnt(C0_LON-0.25,max(C0_LAT-0.25,-90),in_dy,OI_clim,0.25,0.25,1);
    temp = nanmean(C0_temp,1);
    C0_OI_CLIM(isnan(C0_OI_CLIM)) = temp(isnan(C0_OI_CLIM));

    % Find Surrounding Points: level 4 ------------------------------------
    clear('temp','C0_temp')
    C0_temp(1,:) = ICOADS_NC_function_general_grd2pnt(C0_LON+1,C0_LAT,in_dy,OI_clim,0.25,0.25,1);
    C0_temp(2,:) = ICOADS_NC_function_general_grd2pnt(C0_LON-1,C0_LAT,in_dy,OI_clim,0.25,0.25,1);
    C0_temp(3,:) = ICOADS_NC_function_general_grd2pnt(C0_LON,min(C0_LAT+0.5,90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(4,:) = ICOADS_NC_function_general_grd2pnt(C0_LON,max(C0_LAT-0.5,-90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(5,:) = ICOADS_NC_function_general_grd2pnt(C0_LON+0.5,min(C0_LAT+0.25,90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(6,:) = ICOADS_NC_function_general_grd2pnt(C0_LON+0.5,max(C0_LAT-0.25,-90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(7,:) = ICOADS_NC_function_general_grd2pnt(C0_LON-0.5,min(C0_LAT+0.25,90),in_dy,OI_clim,0.25,0.25,1);
    C0_temp(8,:) = ICOADS_NC_function_general_grd2pnt(C0_LON-0.5,max(C0_LAT-0.25,-90),in_dy,OI_clim,0.25,0.25,1);
    temp = nanmean(C0_temp,1);
    C0_OI_CLIM(isnan(C0_OI_CLIM)) = temp(isnan(C0_OI_CLIM));

    C0_OI_CLIM = double(C0_OI_CLIM);

    % Exclude non SST, time or space --------------------------------------
    QC_NON_SST = isnan(C0_YR) | isnan(C0_MO) | isnan(C0_DY) | isnan(C0_SST) |...
        isnan(C0_LON) | isnan(C0_LAT) | isnan(C0_OI_CLIM);
    QC_NON_SST = ~QC_NON_SST;

    disp('Assigning OI-SST Complete!');
    disp(' ');
end