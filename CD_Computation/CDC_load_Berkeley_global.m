% [Berkeley, lon,lat,yr] = CDC_load_Berkeley_global(do_ocn,do_regrid)
% if do_ocn    :: use ocean temperature over ice
% if do_regrid :: use regridded data

function [Berkeley, lon, lat, yr] = CDC_load_Berkeley_global(do_ocn,do_regrid)

    dir =  [CDC_other_temp_dir,'Berkeley_Earth_Global/'];

    if ~exist('do_ocn','var'),      do_ocn    = 1; end
    if ~exist('do_regrid','var'),   do_regrid = 1; end

    if do_regrid == 0

        if do_ocn == 1
            file     = [dir,'Land_and_Ocean_Alternate_LatLong1.nc'];
        else
            file     = [dir,'Land_and_Ocean_LatLong1.nc'];
        end
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
        yr       = [1:Nt/12]+1849;
        
        % deviations from the corresponding 1951-1980 means.

    else
        if do_ocn == 1
            file    = [dir,'Berkeley_global_ocean_5x5_regridded.mat'];
        else
            file    = [dir,'Berkeley_global_air_5x5_regridded.mat'];
        end
        lon     = 2.5:5:360;
        lat     = -87.5:5:90;
        
        if ~isfile(file)
            [tas, lon_high, lat_high, yr] = CDC_load_Berkeley_global(do_ocn,0);
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