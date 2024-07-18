% [HadCRUT5,lon,lat,yr] = CDC_load_HadCRUT5(en,P)
% P.do_analysis :: use partially infilled analyses data
% P.do_random :: use ensemble members additionally perturbed for random errors

function [HadCRUT5,lon,lat,yr] = CDC_load_HadCRUT5(en,P)

    data_version = '5.0.2.0';

    if ~exist('en','var'), en = 0; end
    if ~exist('P','var')
        if en <= 0
            P.do_random = 0;
        else
            P.do_random = 1;
        end
    end
    if ~exist('P','var'),  P.do_analysis = 0;  end
    dir    = [CDC_other_temp_dir,'HadCRUT5/'];
    
    if en <= 0 || P.do_random == 0

        if en == 0
            if P.do_analysis == 0
                file = [dir,'HadCRUT.',data_version,...
                    '.anomalies.ensemble_mean.nc'];
            else
                file = [dir,'HadCRUT.',data_version,...
                    '.analysis.anomalies.ensemble_mean.nc'];
            end
        elseif en == -1
            file = [dir,'HadCRUT.',data_version,'.weights.nc'];
            disp('HadCRUT5 does not provide uncorrected estimates,')
            disp('Loading weights for LATs and SSTs instead');
        else
            if P.do_analysis == 0
                file = [dir,'HadCRUT5_ensemble/HadCRUT.',...
                    data_version,'.anomalies.',num2str(en),'.nc'];
            else
                file = [dir,'HadCRUT5_analysis_ensemble/HadCRUT.',...
                    data_version,'.analysis.anomalies.',num2str(en),'.nc'];
            end
        end

        disp(file);
    
        if en > 0
            HadCRUT5 = ncread(file,'tas');
        elseif en == 0
            HadCRUT5 = ncread(file,'tas_mean');
        elseif en == -1
            HadCRUT5 = ncread(file,'weights');
        end
        lon      = ncread(file,'longitude');
        lat      = ncread(file,'latitude');
        
        HadCRUT5(HadCRUT5>1000) = nan;
        HadCRUT5 = HadCRUT5([37:72 1:36],:,:);
        lon      = lon([37:72 1:36]);  lon(lon<0) = lon(lon<0) + 360;
    
        if rem(size(HadCRUT5,3),12) == 0
            Nt   = size(HadCRUT5,3);
        else
            Nt   = ceil(size(HadCRUT5,3)/12)*12;
            HadCRUT5(:,:,(end+1):Nt) = nan;
        end
        HadCRUT5 = reshape(HadCRUT5(:,:,1:Nt),size(HadCRUT5,1),size(HadCRUT5,2),12,Nt/12);
        yr       = [1:Nt/12]+1849;

    else
        
        file_HadCRUT5 = [dir,'HadCRUT5_ensemble_perturbed/HadCRUT.',...
            data_version,'_perturbed_ensemble_member_',num2str(en),'.mat'];
        
        if ~isfile(file_HadCRUT5)
        
            errt = ncread([dir,'HadCRUT.',data_version,'.uncorrelated.nc'],'tas_unc');

            if rem(size(errt,3),12) == 0
                Nt  = size(errt,3);
            else
                Nt  = ceil(size(errt,3)/12)*12;
                errt(:,:,(end+1):Nt) = nan;
            end

            errt = reshape(errt(:,:,1:Nt),72,36,12,Nt/12);
            sample1 = normrnd(0,errt);

            sample2 = zeros(size(sample1));
            for ct_yr = [1:Nt/12] + 1849
                dir_err  = [dir,'HadCRUT5_error_covariance/'];
                if rem(ct_yr,10) == 0, disp(num2str(ct_yr,'Start Year: %6.0f')); end
                for ct_mon = 1:12
                    try
                        file_err = [dir_err,'HadCRUT.',data_version,...
                            '.error_covariance.',num2str(ct_yr),CDF_num2str(ct_mon,2),'.nc'];
                        tos_cov  = ncread(file_err,'tas_cov');
                        tos_cov(isnan(tos_cov)) = 0;
                        l        = nanmean(tos_cov,1) ~= 0;
                        tos_cov_temp = tos_cov(l,l);
                        [V,D]        = eig(tos_cov_temp);
                        D(D<0)       = 0;
                        tos_cov_temp = V*D*inv(V);
                        temp2    = mvnrnd(zeros(size(tos_cov_temp,1),1),tos_cov_temp);
                        temp     = zeros(size(tos_cov,1),1);
                        temp(l)  = temp2;
                        sample2(:,:,ct_mon,ct_yr-1849)   = reshape(temp,72,36);
                    catch
                        disp([file_err,' does not work'])
                    end
                end
            end

            sample = sample1 + sample2;
            sample = sample([37:72 1:36],:,:,:);

            PP                   = P;
            PP.do_random         = 0;
            [HadCRUT5,lon,lat,~] = CDC_load_HadCRUT5(en,PP);
            HadCRUT5             = HadCRUT5 + sample;
            save(file_HadCRUT5,'HadCRUT5','-v7.3')

        else
            load(file_HadCRUT5,'HadCRUT5');
            lon = 2.5:5:357.5;
            lat = -87.5:5:87.5;
        end
        yr = [1:size(HadCRUT5,4)]+1849;
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [HadCRUT5, yr]    = CDC_trim_years(HadCRUT5, yr, yr_start, yr_end);
end