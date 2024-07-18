function dis = distance_matrix(reso,l_o)

    lon     = repmat((reso/2:reso:360)'   ,1       ,180/reso);
    lat     = repmat((reso/2:reso:180)-90 ,360/reso,1);
    lon_r   = lon(:);
    lat_r   = lat(:);
    lon_o   = lon(l_o);
    lat_o   = lat(l_o);
    lon     = [lon_r; lon_o];
    lat     = [lat_r; lat_o];
    lon1    = repmat(lon,1,numel(lon));
    lon2    = repmat(lon',numel(lon),1);
    lat1    = repmat(lat,1,numel(lat));
    lat2    = repmat(lat',numel(lat),1);
    dis     = distance(lat1,lon1,lat2,lon2);
end