% [Berkeley, lon,lat,yr] = CDC_load_Berkeley(en)
% if en exist :: use regridded data

function [Berkeley, lon, lat, yr] = CDC_load_Berkeley(en)

    dir =  [CDC_other_temp_dir,'Berkeley_Earth_Land/'];

    if ~exist('en','var')
        file     = [CDC_other_temp_dir,'Berkeley_Earth_Land/Complete_TAVG_LatLong1.nc'];
        tas      = ncread(file,'temperature');        
        lon      = ncread(file,'longitude');        
        lat      = ncread(file,'latitude');
        
        Berkeley = tas([181:end 1:180],:,:);
        lon      = lon([181:end 1:180]);  lon(lon<0) = lon(lon<0) + 360;
        
        if rem(size(Berkeley,3),12) == 0
            Nt  = size(Berkeley,3);
        else
            Nt  = ceil(size(Berkeley,3)/12)*12;
            Berkeley(:,:,(end+1):Nt) = nan;
        end
        Berkeley = reshape(Berkeley(:,:,1:Nt),size(Berkeley,1),size(Berkeley,2),12,Nt/12);
        yr       = [1:Nt/12]+1749;
        
        % deviations from the corresponding 1951-1980 means.
    else
        file    = [dir,'Berkeley_5x5_regridded.mat'];
        lon     = 2.5:5:360;
        lat     = -87.5:5:90;
        
        if ~isfile(file)
            [tas, lon_high, lat_high, yr] = CDC_load_Berkeley;
            P.threshold = 1;
            tas_5      = CDC_average_grid(lon_high,lat_high,tas(:,:,:),lon,lat,P);
            tas        = reshape(tas_5,size(tas_5,1),size(tas_5,2),12,size(tas_5,3)/12);
            save(file,'tas','yr','-v7.3');
        else
            load(file);
        end
        Berkeley = tas;
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [Berkeley, yr] = CDC_trim_years(Berkeley, yr, yr_start, yr_end);

end