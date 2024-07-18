function SST_subset = AOI_func_pair_HadSST4(lon,lat,P,en)

    disp(['Pairing HadSST4']);
    SST = CDC_load_HadSST4(en,P);
    SST = reshape(SST,size(SST,1)*size(SST,2),size(SST,3)*size(SST,4));
    
    reso = 5;

    clear('SST_subset','SST_subset_n')
    index = grd2pnt_id(lon,lat,reso,reso);
    SST_subset = SST(index,:)';
    
    index = grd2pnt_id(lon+reso,lat,reso,reso);
    SST_subset_n(:,:,1) = SST(index,:)';
    
    index = grd2pnt_id(lon-reso,lat,reso,reso);
    SST_subset_n(:,:,2) = SST(index,:)';
    
    index = grd2pnt_id(lon,lat+reso,reso,reso);
    SST_subset_n(:,:,3) = SST(index,:)';

    index = grd2pnt_id(lon,lat-reso,reso,reso);
    SST_subset_n(:,:,4) = SST(index,:)';

    SST_subset(SST_subset<-900)     = nan;
    SST_subset_n(SST_subset_n<-900) = nan;
    SST_subset_m                    = nanmean(SST_subset_n,3);
    SST_subset(isnan(SST_subset))   = SST_subset_m(isnan(SST_subset));
    SST_subset                      = reshape(SST_subset,12,fix(size(SST_subset,1)/12),numel(lon));
    SST_subset                      = SST_subset(:,[P.yr_sub_st:P.yr_sub_ed]-1849,:);
    
    SST_subset                      = permute(SST_subset,[3 1 2]); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function index = grd2pnt_id(in_lon,in_lat,reso_x,reso_y)

    in_lon = rem(in_lon + 360*5, 360);
    x = fix(in_lon/reso_x)+1;
    num_x = 360/reso_x;
    x(x>num_x) = x(x>num_x) - num_x;

    in_lat(in_lat>90) = 90;
    in_lat(in_lat<-90) = -90;
    y = fix((in_lat+90)/reso_y) +1;
    num_y = 180/reso_y;
    y(y>num_y) = num_y;

    index = sub2ind([360/reso_x 360/reso_y],x,y);

end

