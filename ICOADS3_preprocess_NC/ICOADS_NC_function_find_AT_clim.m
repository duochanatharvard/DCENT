function [C0_ERA_CLIM,QC_NON_AT] = ICOADS_NC_function_find_AT_clim ...
                             (C0_YR,C0_MO,C0_DY,C0_AT,C0_LON,C0_LAT,dir_OI)

    disp('Assigning ERA_interim AT...');

    % Assign OI-SST Climatology -------------------------------------------
    load ([dir_OI,'ERA_interim_AT2m_1985_2014_daily_climatology.mat'])  % unit: K
    t2m_clim_smooth = t2m_clim_smooth - 273.15;
    t2m_clim_smooth(abs(t2m_clim_smooth)>1000) = NaN;
    C0_DY(isnan(C0_DY)) = 15;
    in_dy = datenum([ones(size(C0_YR)) C0_MO C0_DY]) - 366;
    in_dy(in_dy>365) = 365;

    % addpath('/n/home10/dchan/script/Peter/ICOAD_RE/function/'); ---------
    clear('C0_ERA_CLIM')
    C0_ERA_CLIM = ICOADS_NC_function_general_grd2pnt(C0_LON,C0_LAT,in_dy,t2m_clim_smooth,0.25,0.25,1);

    C0_ERA_CLIM = double(C0_ERA_CLIM);

    % Exclude non SST, time or space --------------------------------------
    QC_NON_AT = isnan(C0_YR) | isnan(C0_MO) | isnan(C0_DY) | isnan(C0_AT) |...
        isnan(C0_LON) | isnan(C0_LAT) | isnan(C0_ERA_CLIM);
    QC_NON_AT = ~QC_NON_AT;

    disp('Assigning ERA_interim AT Complete!');
    disp(' ');
end