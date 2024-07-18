% [CRUTEM5,lon,lat,yr] = CDC_load_CRUTEM5(en,P)
% P.do_random :: use ensemble members additionally perturbed for random errors

function [CRUTEM5,lon,lat,yr] = CDC_load_CRUTEM5(en,P)

    data_version = '5.0.2.0';

    if ~exist('en','var'), en = 0; end
    dir         = [CDC_other_temp_dir,'CRUTEM5/'];
    if ~exist('P','var')
        if en <= 0
            P.do_random = 0;
        else
            P.do_random = 1;
        end
    end

    if en <= 0 || P.do_random == 0
        if en == 0
            file = [dir,'CRUTEM.',data_version,'.anomalies.nc'];
            CRUTEM5 = ncread(file,'tas');
            lon     = ncread(file,'longitude');
            lat     = ncread(file,'latitude');
            
            CRUTEM5(CRUTEM5>1000) = nan;
            CRUTEM5 = CRUTEM5([37:72 1:36],:,:);
            lon     = lon([37:72 1:36]);  lon(lon<0) = lon(lon<0) + 360;
            
            if rem(size(CRUTEM5,3),12) == 0
                Nt  = size(CRUTEM5,3);
            else
                Nt  = ceil(size(CRUTEM5,3)/12)*12;
                CRUTEM5(:,:,(end+1):Nt) = nan;
            end
            CRUTEM5 = reshape(CRUTEM5(:,:,1:Nt),size(CRUTEM5,1),size(CRUTEM5,2),12,Nt/12);
            yr      = [1:Nt/12]+1849;
            
        elseif en == -1
            error('CRUTEM5 does not provide uncorrected estimates...')
            
        else
            file = [dir,'CRUTEM5_ensemble/CRUTEM.',data_version,'_ensemble_member_',num2str(en),'.mat'];
            if ~isfile(file)
                
                PP.do_random = 0;
                PP.do_analysis = 0;
                w        = CDC_load_HadCRUT5(-1,PP);
                HadCRUT5 = CDC_load_HadCRUT5(en,PP);
                HadSST4  = CDC_load_HadSST4(en,PP);
                CRUTEM5  = (HadCRUT5 - HadSST4.*(1-w)) ./ w;
                CRUTEM5(w == 1) = HadCRUT5(w == 1);
    
                save(file,'CRUTEM5','-v7.3');
            else
                load(file);
            end
            lon = 2.5:5:360;
            lat = -87.5:5:90;
            yr  = 1849 + [1:size(CRUTEM5,4)];
        end

    else

        file_CRUTEM5 = [dir,'CRUTEM5_ensemble_perturbed/CRUTEM.',data_version,'_perturbed_ensemble_member_',num2str(en),'.mat'];
        
        if ~isfile(file_CRUTEM5)
        
            errt = ncread([dir,'CRUTEM.',data_version,'.measurement_sampling.nc'],'tas_unc');

            if rem(size(errt,3),12) == 0
                Nt  = size(errt,3);
            else
                Nt  = ceil(size(errt,3)/12)*12;
                errt(:,:,(end+1):Nt) = nan;
            end

            errt   = reshape(errt(:,:,1:Nt),72,36,12,Nt/12);
            sample = normrnd(0,errt);
            sample = sample([37:72 1:36],:,:,:);

            PP                   = P;
            PP.do_random         = 0;
            [CRUTEM5,lon,lat,~] = CDC_load_CRUTEM5(en,PP);
            CRUTEM5             = CRUTEM5 + sample;
            save(file_CRUTEM5,'CRUTEM5','-v7.3')

        else
            load(file_CRUTEM5,'CRUTEM5');
            lon = 2.5:5:357.5;
            lat = -87.5:5:87.5;
        end
        yr = [1:size(CRUTEM5,4)]+1849;
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [CRUTEM5, yr] = CDC_trim_years(CRUTEM5, yr, yr_start, yr_end);
end
