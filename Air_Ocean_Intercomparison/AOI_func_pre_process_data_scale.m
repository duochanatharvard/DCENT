function Out_station = AOI_func_pre_process_data_scale(SAT,P)

    SAT  = SAT(:);

    % Subset years where both AT and SST has values -----------------------
    temp = reshape(SAT,12,numel(SAT)/12);
    l_yr = any(~isnan(temp),1);
    l_yr(find(l_yr,1):find(l_yr,1,'last')) = 1;
    yrs  = P.yr_sub_st : P.yr_sub_ed;
    Out_station.yrs  = yrs(l_yr);

    % Linear interpolate if missing values --------------------------------
    l_yr = repmat(l_yr,12,1);
    Out_station.SAT   = SAT(l_yr);

    Out_station.T     = CDC_interp1(Out_station.SAT,[],1);

end