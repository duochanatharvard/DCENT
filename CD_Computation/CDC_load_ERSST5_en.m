% [ERSST5,lon,lat,yr] = CDC_load_ERSST5_en(en,do_regrid)
% When do_regrid == 0 -> read raw data at 2x2 resolution
% Otherwise if output file exist -> read output file
%           Otherwise preprocess and regrid

% [ERSST5,lon,lat,yr] = CDC_load_ERSST5_en(en,do_regrid)

function [ERSST5,lon,lat,yr] = CDC_load_ERSST5_en(en,do_regrid)

    if do_regrid == 0

            data1  = load_data_pre2017(en);
            data2  = load_data_post2001(en);
            ERSST5 = cat(3,data1(:,:,1:1764),data2);
        
            lat    = -88:2:88;
            lon    = 1:2:360;
        
            if rem(size(ERSST5,3),12) == 0
                Nt = size(ERSST5,3);
            else
                Nt = ceil(size(ERSST5,3)/12)*12;
                ERSST5(:,:,(end+1):Nt) = nan;
            end
            ERSST5 = reshape(ERSST5(:,:,1:Nt),size(ERSST5,1),size(ERSST5,2),12,Nt/12);
            yr     = [1:Nt/12]+1853;

    else

        lon   = 2.5:5:360;
        lat   = -87.5:5:90;

        dir   = [CDC_other_temp_dir,'ERSST5_ensemble/'];
        file  = [dir,'ERSST5_5x5_regridded_en_',sprintf('%04d',en),'.mat'];

        if ~isfile(file)
            
            [sst,lon_high,lat_high,yr] = CDC_load_ERSST5_en(en,0);
            P.threshold = 1;
            sst = CDC_average_grid(lon_high',lat_high',sst(:,:,:),lon,lat,P);
            sst = reshape(sst,size(sst,1),size(sst,2),12,size(sst,3)/12);
            sst = single(sst);
            save(file,'sst','yr','-v7.3');
        else    
            load(file);
            sst = double(sst);
        end
        ERSST5 = sst - nanmean(sst(:,:,:,[1982:2014]-1853),4);
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [ERSST5, yr] = CDC_trim_years(ERSST5, yr, yr_start, yr_end);
end

% 
% 
% 
% 
% 
% clf;
% id = 2;
% subplot(2,1,1);
% CDF_pcolor(0:2:359,-88:2:88,data1(:,:,1764+id));
% CDF_boundaries;
% caxis([-1 1])
% 
% subplot(2,1,2);
% CDF_pcolor(0:2:359,-88:2:88,data2(:,:,id));
% CDF_boundaries;
% caxis([-1 1])


function data = load_data_pre2017(en)

    dir         = [CDC_other_temp_dir,'ERSST5_ensemble/'];
    file_path   = [dir,'/sst2d.ano.1854.2017.ensemble.',sprintf('%04d',en),'.dat'];

    fid         = fopen(file_path, 'rb', 'ieee-be');
    rows        = 180;
    cols        = 89;
    num_records = 1968;
    data        = fread(fid, (rows*cols+2) * num_records, 'real*4');
    fclose(fid);
    
    data        = reshape(data, rows*cols+2, num_records);
    data        = data(2:end-1,:);
    data        = reshape(data, rows, cols, num_records);
    data(data < -100) = nan;

end

function data = load_data_post2001(en)

    dir         = [CDC_other_temp_dir,'ERSST5_recent_ensemble/'];
    file_path   = [dir,'/sst2d.ano.2001.last.ensemble.',sprintf('%04d',en),'.dat'];

    fid         = fopen(file_path, 'rb', 'ieee-be');
    rows        = 180;
    cols        = 89;
    data        = fread(fid, inf, 'real*4');
    num_records = numel(data) / (rows*cols+2);
    fclose(fid);
    
    data        = reshape(data, rows*cols+2, num_records);
    data        = data(2:end-1,:);
    data        = reshape(data, rows, cols, num_records);
    data(data < -100) = nan;

end