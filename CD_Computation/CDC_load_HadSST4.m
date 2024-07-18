% [HadSST4,lon,lat,yr] = CDC_load_HadSST4(en,P)
% P.do_random :: use ensemble members additionally perturbed for random errors

function [HadSST4,lon,lat,yr] = CDC_load_HadSST4(en,P)

    data_version = '4.0.1.0';

    if ~exist('en','var'), en = 0;  end
    if ~exist('P','var')
        if en <= 0
            P.do_random = 0;
        else
            P.do_random = 1;
        end
    end
    dir    = [CDC_other_temp_dir,'HadSST4/'];

    if en == 0
        file = [dir,'HadSST.',data_version,'_median.nc'];
    elseif en == -1
        file = [dir,'HadSST.',data_version,'_unadjusted.nc'];
    else
        file = [dir,'HadSST4_ensemble/HadSST.',data_version,'_ensemble_member_',num2str(en),'.nc'];
    end

    if en <= 0 || P.do_random == 0
        
        HadSST4 = ncread(file,'tos');
        lon    = ncread(file,'longitude');
        lat    = ncread(file,'latitude');

        HadSST4(HadSST4>1000) = nan;
        HadSST4 = HadSST4([37:72 1:36],:,:);
        lon    = lon([37:72 1:36]);  lon(lon<0) = lon(lon<0) + 360;

        if rem(size(HadSST4,3),12) == 0
            Nt  = size(HadSST4,3);
        else
            Nt  = ceil(size(HadSST4,3)/12)*12;
            HadSST4(:,:,(end+1):Nt) = nan;
        end
        HadSST4 = reshape(HadSST4(:,:,1:Nt),size(HadSST4,1),size(HadSST4,2),12,Nt/12);
        yr      = [1:Nt/12]+1849;
    
    else
        
        file_HadSST4 = [dir,'HadSST4_ensemble_perturbed/HadSST.',data_version,'_perturbed_ensemble_member_',num2str(en),'.mat'];
        
        if ~isfile(file_HadSST4)
        
            err1 = ncread([dir,'HadSST.',data_version,'_sampling_uncertainty.nc'],'tos_unc');
            err2 = ncread([dir,'HadSST.',data_version,'_uncorrelated_measurement_uncertainty.nc'],'tos_unc');

            if rem(size(err1,3),12) == 0
                Nt  = size(err1,3);
            else
                Nt  = ceil(size(err1,3)/12)*12;
                err1(:,:,(end+1):Nt) = nan;
                err2(:,:,(end+1):Nt) = nan;
            end

            errt = sqrt(err1.^2 + err2.^2);
            errt = reshape(errt(:,:,1:Nt),72,36,12,Nt/12);
            sample1 = normrnd(0,errt);

            sample2 = nan(size(sample1));
            for ct_yr = [1:Nt/12] + 1849
                dir_err  = [dir,'HadSST4_error_covariance/'];
                if rem(ct_yr,10) == 0, disp(num2str(ct_yr,'Start Year: %6.0f')); end
                for ct_mon = 1:12
                    try
                        file_err = [dir_err,'HadSST.',data_version,'_error_covariance_',num2str(ct_yr),CDF_num2str(ct_mon,2),'.nc'];
                        tos_cov  = ncread(file_err,'tos_cov');
                        l        = nanmean(tos_cov,1) ~= 0;
                        tos_cov_temp = tos_cov(l,l);
                        temp2    = mvnrnd(zeros(size(tos_cov_temp,1),1),tos_cov_temp);
                        temp     = nan(size(tos_cov,1),1);
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
            [HadSST4,lon,lat,~]  = CDC_load_HadSST4(en,PP);
            HadSST4              = HadSST4 + sample;
            save(file_HadSST4,'HadSST4','-v7.3')

        else
            load(file_HadSST4,'HadSST4');
            lon = 2.5:5:357.5;
            lat = -87.5:5:87.5;
        end
        yr = [1:size(HadSST4,4)]+1849;
    end

    [yr_start,yr_end] = CDC_common_time_interval;
    [HadSST4, yr]     = CDC_trim_years(HadSST4, yr, yr_start, yr_end);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% out = CDF_num2str(num,len)
% len: total length of output that would be filled with zeros...
function out = CDF_num2str(num,len)

    out = repmat('0',1,len);
    a = num2str(num);
    out(end-size(a,2)+1:end) = a;
end
