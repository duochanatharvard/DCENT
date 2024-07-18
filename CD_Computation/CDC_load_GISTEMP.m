% [GISTEMP, lon, lat, yr] = CDC_load_GISTEMP(en)
% if en does not exist :: use land only data
% if en == 1 :: use regridded data
% if en == 2 :: use combined land-ocean data


function [GISTEMP, lon, lat, yr] = CDC_load_GISTEMP(en)

    dir =  [CDC_other_temp_dir,'GISTEMP/'];

    if ~exist('en','var')
        file     = [dir,'gistemp250_GHCNv4.nc'];
        tas      = ncread(file,'tempanomaly');
        lon      = ncread(file,'lon');
        lat      = ncread(file,'lat');
        GISTEMP  = tas([91:end 1:90],:,:);
        lon      = lon([91:end 1:90]);    lon(lon<0) = lon(lon<0) + 360;
        
        if rem(size(GISTEMP,3),12) == 0
            Nt  = size(GISTEMP,3);
        else
            Nt  = ceil(size(GISTEMP,3)/12)*12;
            GISTEMP(:,:,(end+1):Nt) = nan;
        end
        GISTEMP  = reshape(GISTEMP(:,:,1:Nt),size(GISTEMP,1),size(GISTEMP,2),12,Nt/12);
        yr       = [1:Nt/12]+1879;
        % deviations from the corresponding 1951-1980 means.

    elseif en == 1
        file    = [dir,'GISTEMP_5x5_regridded.mat'];
        lon     = 2.5:5:360;
        lat     = -87.5:5:90;
        
        if ~isfile(file)
            [tas, lon_high, lat_high, yr] = CDC_load_GISTEMP;
            P.threshold = 1;
            tas_5      = CDC_average_grid(lon_high,lat_high,tas(:,:,:),lon,lat,P);
            tas        = reshape(tas_5,size(tas_5,1),size(tas_5,2),12,size(tas_5,3)/12);
            save(file,'tas','yr','-v7.3');
        else
            load(file);
        end
        GISTEMP = tas;
        
    elseif en == 2
        file     = [dir,'gistemp1200_GHCNv4_ERSSTv5.nc'];
        tas      = ncread(file,'tempanomaly'); 
        lon_high = ncread(file,'lon');
        lat_high = ncread(file,'lat');
        
        tas      = tas([91:180 1:90],:,:);
        lon_high = lon_high([91:end 1:90]);    
        lon_high(lon_high<0) = lon_high(lon_high<0) + 360;

        lon      = 2.5:5:360;
        lat      = -87.5:5:90;
        P.threshold = 1;
        GISTEMP  = CDC_average_grid(lon_high,lat_high,tas(:,:,:),lon,lat,P);

        if rem(size(GISTEMP,3),12) == 0
            Nt  = size(GISTEMP,3);
        else
            Nt  = ceil(size(GISTEMP,3)/12)*12;
            GISTEMP(:,:,(end+1):Nt) = nan;
        end
        GISTEMP  = reshape(GISTEMP(:,:,1:Nt),size(GISTEMP,1),size(GISTEMP,2),12,Nt/12);
        yr       = [1:Nt/12]+1879;   
        
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [GISTEMP, yr] = CDC_trim_years(GISTEMP, yr, yr_start, yr_end);
end