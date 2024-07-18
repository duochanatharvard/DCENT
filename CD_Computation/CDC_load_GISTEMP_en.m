% [GISTEMP, lon, lat, yr] = CDC_load_GISTEMP_en(en,do_regrid)
% Load GISTEMP ensemble that combines land and ocean temperatures
% if do_regrid == 0 :: use raw data on 2x2 grid
% otherwise, use regridded data

function [GISTEMP, lon, lat, yr] = CDC_load_GISTEMP_en(en,do_regrid)

    dir =  [CDC_other_temp_dir,'GISTEMP_ensemble/'];

    if do_regrid == 0
        file     = [dir,'ensembleChunk_',sprintf('%04d',en),'.nc'];
        tas      = ncread(file,'tempAnom');
        lon      = double(ncread(file,'lon'));
        lat      = double(ncread(file,'lat'));
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

    else

        file    = [dir,'GISTEMP_5x5_regridded_en_',sprintf('%04d',en),'.mat'];
        lon     = 2.5:5:360;
        lat     = -87.5:5:90;
        
        if ~isfile(file)
            [tas, lon_high, lat_high, yr] = CDC_load_GISTEMP_en(en,0);
            P.threshold = 1;
            tas_5       = CDC_average_grid(lon_high,lat_high,tas(:,:,:),lon,lat,P);
            tas         = reshape(tas_5,size(tas_5,1),size(tas_5,2),12,size(tas_5,3)/12);
            tas         = single(tas);
            save(file,'tas','yr','-v7.3');
        else
            load(file);
            tas = double(tas);
        end
        GISTEMP = tas; 
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [GISTEMP, yr] = CDC_trim_years(GISTEMP, yr, yr_start, yr_end);
end