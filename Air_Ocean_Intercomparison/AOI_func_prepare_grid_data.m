function Out_grid = AOI_func_prepare_grid_data(Out,ct_x,ct_y,P)

    l = Out.lon > (ct_x*10-10)  & Out.lon <= (ct_x*10) & ...
        Out.lat > (ct_y*10-100) & Out.lat <= (ct_y*10-90);

    if nnz(l) > 0
        disp([ct_x ct_y])
        Out_grid = pre_process_data(Out,l,P);
    else
        Out_grid = [];
    end
end


function Out_grid = pre_process_data(Out,l,P)

    Out_grid.N   = nnz(l);

    % Out_grid.lf  = nanmean(Out.land_fraction(l));

    SAT  = CDC_pnt2glbmean(Out.raw_SAT_anm(l,:,:),Out.lon(l),Out.lat(l));
    SST  = CDC_pnt2glbmean(Out.raw_SST_anm(l,:,:),Out.lon(l),Out.lat(l));

    yrs  = P.yr_learn - P.yr_sub_st+1;
    SAT  = SAT(:,yrs);  SAT  = SAT(:);
    SST  = SST(:,yrs);  SST  = SST(:);

    if nnz(~isnan(SAT + SST)) > 240

        % Subset years where both AT and SST has values ---------------
        temp = reshape(SAT+SST,12,numel(P.yr_learn));
        l_yr = any(~isnan(temp),1);
        l_yr(find(l_yr,1):find(l_yr,1,'last')) = 1;
        yrs  = P.yr_learn;
        Out_grid.yrs  = yrs(l_yr);

        % Linear interpolate if missing values ------------------------
        l_yr = repmat(l_yr,12,1);
        Out_grid.SAT  = SAT(l_yr);
        Out_grid.SST  = SST(l_yr);

        Out_grid.T   = CDC_interp1(Out_grid.SAT,[],1);
        Out_grid.T_o = CDC_interp1(Out_grid.SST,isnan(Out_grid.SAT),1);

        Out_grid.l_use_loss  = ~isnan(Out_grid.SAT) & ~isnan(Out_grid.SST);
    else
        Out_grid = [];
    end
end
