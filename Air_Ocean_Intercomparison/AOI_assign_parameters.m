function Para_AOI = AOI_assign_parameters

    clear('Para_AOI')
    
    Para_AOI.do_random = 0;
    Para_AOI.yr_sub_st = 1850;  % Subset data within this interval for analysis
    a = datevec(date);
    Para_AOI.yr_sub_ed = a(1);
    Para_AOI.yr_st     = 1700; 
    Para_AOI.key       = 0;
    Para_AOI.distance  = 300;
    Para_AOI.yr_learn  = 1960:2020;
    Para_AOI.do_season = 0;
    
    Para_AOI.reso_x    = 5;
    Para_AOI.reso_y    = 5;
end
