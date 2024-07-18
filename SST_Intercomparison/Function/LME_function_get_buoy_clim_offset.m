function offset_pnt = LME_function_get_buoy_clim_offset(P,P0)

    switch P.correct_buoy_clim
        case 1
            file = [LME_OI('Mis'),'clim_offset_in_buoy_diagnose.mat'];
        case 2
            file = [LME_OI('Mis'),'clim_offset_in_buoy_diurnal_cycle.mat'];
    end
    load(file,'clim_offset');

    clear('offset_pnt_n','offset_pnt')
    try
        offset_pnt        = LME_function_grd2pnt(P0.C0_LON,P0.C0_LAT,P0.MO,clim_offset,.5,.5,1);
        
        lon = P0.C0_LON+.5;  lon(lon>360) = lon(lon>360) - 360;
        offset_pnt_n(:,1) = LME_function_grd2pnt(lon,P0.C0_LAT,P0.MO,clim_offset,.5,.5,1);
        
        lon = P0.C0_LON-.5;  lon(lon<0)   = lon(lon<0) + 360;
        offset_pnt_n(:,2) = LME_function_grd2pnt(lon,P0.C0_LAT,P0.MO,clim_offset,.5,.5,1);
        
        lon = P0.C0_LON+1;  lon(lon>360) = lon(lon>360) - 360;
        offset_pnt_n(:,3) = LME_function_grd2pnt(lon,P0.C0_LAT,P0.MO,clim_offset,.5,.5,1);
        
        lon = P0.C0_LON-1;  lon(lon<0)   = lon(lon<0) + 360;
        offset_pnt_n(:,4) = LME_function_grd2pnt(lon,P0.C0_LAT,P0.MO,clim_offset,.5,.5,1);
        
        offset_pnt_n(:,5) = LME_function_grd2pnt(lon,P0.C0_LAT+0.5,P0.MO,clim_offset,.5,.5,1);
        
        offset_pnt_n(:,6) = LME_function_grd2pnt(lon,P0.C0_LAT-0.5,P0.MO,clim_offset,.5,.5,1);
        
    catch
        
        offset_pnt        = LME_function_grd2pnt(P0.C0_LON,P0.C0_LAT,P0.C0_MO,clim_offset,.5,.5,1);
        
        lon = P0.C0_LON+.5;  lon(lon>360) = lon(lon>360) - 360;
        offset_pnt_n(:,1) = LME_function_grd2pnt(lon,P0.C0_LAT,P0.C0_MO,clim_offset,.5,.5,1);
        
        lon = P0.C0_LON-.5;  lon(lon<0)   = lon(lon<0) + 360;
        offset_pnt_n(:,2) = LME_function_grd2pnt(lon,P0.C0_LAT,P0.C0_MO,clim_offset,.5,.5,1);
        
        lon = P0.C0_LON+1;  lon(lon>360) = lon(lon>360) - 360;
        offset_pnt_n(:,3) = LME_function_grd2pnt(lon,P0.C0_LAT,P0.C0_MO,clim_offset,.5,.5,1);
        
        lon = P0.C0_LON-1;  lon(lon<0)   = lon(lon<0) + 360;
        offset_pnt_n(:,4) = LME_function_grd2pnt(lon,P0.C0_LAT,P0.C0_MO,clim_offset,.5,.5,1);
        
        offset_pnt_n(:,5) = LME_function_grd2pnt(lon,P0.C0_LAT+0.5,P0.C0_MO,clim_offset,.5,.5,1);
        
        offset_pnt_n(:,6) = LME_function_grd2pnt(lon,P0.C0_LAT-0.5,P0.C0_MO,clim_offset,.5,.5,1);
    end
    
    l = isnan(offset_pnt); offset_pnt(l) = nanmean(offset_pnt_n(l,1:2),2);
    l = isnan(offset_pnt); offset_pnt(l) = nanmean(offset_pnt_n(l,3:4),2);
    l = isnan(offset_pnt); offset_pnt(l) = nanmean(offset_pnt_n(l,5:6),2);
    l = isnan(offset_pnt); offset_pnt(l) = 0;

end