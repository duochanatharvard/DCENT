function [SST_corr, MLR_b, Stats, SST_corr_taper,MLR_b_taper] = AOI_func_correct_SST...
                         (SST_infer_grid,SST_infer_N,SST_obs,num,Para_AOI)

    % Load the pattern of bucket models -----------------------------------
    solar_shading = 0.5;
    file_pattern  = [...
        'spatial_pattern_bucket_bias_solar_exposure_',num2str(1-solar_shading),'.mat'];
    load(file_pattern,'Bucket_bias_pattern');

    % Calculate SST differences -------------------------------------------
    dif           = SST_obs - SST_infer_grid;      
    
    % Prepare for the pattern of bucket biases in the fitting -------------
    pattern       = repmat(Bucket_bias_pattern,1,1,1,size(SST_infer_grid,4));
    pattern(isnan(dif))  = nan;

    % Calculate the error model -------------------------------------------
    error_total_var = error_model(SST_infer_N);
    
    % Fit for the amplitude -----------------------------------------------
    clear('biases','biases_sample','b')
    clear('Stats')
    for ct = 1:size(dif,4)

        clear('x','y','w')
        l_use = ct + [-1:1];    
        l_use(l_use<1) = [];   
        l_use(l_use>size(dif,4)) = []; 
        
        x = pattern(:,:,:,l_use);
        y = dif(:,:,:,l_use);
        w = 1./(error_total_var(:,:,:,l_use) + 0);

        [biases(ct,:), biases_sample(ct,:,:),X,Y,W,Y_hat] = weighted_least_square(x,y,w);
        [biases0(ct,:), biases0_sample(ct,:,:),~,~,~,~] = weighted_least_square(x,y,w,0);
        Stats.X{ct} = single(X(:,1));
        Stats.Y{ct} = single(Y);
        Stats.W{ct} = single(diag(W));
        Stats.Y_hat{ct} = single(Y_hat);
    end

    % Taper the two fitting together --------------------------------------
    rng(num);
    taper_st            = round(unifrnd(1907, 1913));
    taper_end           = round(unifrnd(1927, 1933));
    taper_scl           = (1849+[1:size(biases,1)] - taper_st) / (taper_end - taper_st);
    taper_scl(taper_scl<0) = 0;
    taper_scl(taper_scl>1) = 1;
    fit_1        = biases;
    fit_0        = biases0;
    fit_1_sample = biases_sample;
    fit_0_sample = biases0_sample;
    fit_0(:,2)   = 0;
    fit_0_sample(:,2,:) = 0;
    fit_comb        = fit_1 .* taper_scl' + fit_0 .* (1 - taper_scl');
    fit_comb_sample = fit_1_sample .* taper_scl' + fit_0_sample .* (1 - taper_scl');
    biases          = fit_comb;
    biases_sample   = fit_comb_sample;
    clear('fit_1','fit_0','fit_1_sample','fit_0_sample','taper_st','taper_ed','taper_scl','fit_comb','fit_comb_sample')

    % Taper bias estimates to zero for early estimates --------------------
    rng(num);
    taper_st            = round(unifrnd(1873, 1877)); 
    taper_end           = round(unifrnd(1883, 1887));
    taper_scl           = (1849+[1:size(biases,1)] - taper_st) / (taper_end - taper_st); 
    taper_scl(taper_scl<0) = 0;
    taper_scl(taper_scl>1) = 1;
    bias_clim           = nanmean(biases([taper_st:taper_end]-1849,:),1);
    bias_sample_clim    = nanmean(biases_sample([taper_st:taper_end]-1849,:,:),1);
    biases_taper        = bias_clim + (biases - bias_clim) .* taper_scl';
    biases_sample_taper = bias_sample_clim + (biases_sample - bias_sample_clim) .* taper_scl';

    % Generate corrections ------------------------------------------------
    pattern_masked = repmat(Bucket_bias_pattern,1,1,1,size(SST_infer_grid,4));
    pattern_masked(isnan(SST_obs)) = nan;
    if num == 0
        bias_reshp = reshape(biases,1,1,1,size(SST_infer_grid,4),size(biases,2));
        MLR_b      = biases;
        bias_taper_reshp = reshape(biases_taper,1,1,1,size(SST_infer_grid,4),size(biases,2));
        MLR_b_taper      = biases_taper;
    else
        bias_reshp = reshape(biases_sample(:,:,num),1,1,1,size(SST_infer_grid,4),size(biases,2));
        MLR_b      = biases_sample(:,:,num);
        bias_taper_reshp = reshape(biases_sample_taper(:,:,num),1,1,1,size(SST_infer_grid,4),size(biases,2));
        MLR_b_taper      = biases_sample_taper(:,:,num);
    end
    Stats.fitted     = biases;
    Stats.fitted_rnd = biases_sample; 
    Corr     = - (pattern_masked .* bias_reshp(:,:,:,:,1) + bias_reshp(:,:,:,:,2));
    SST_corr = SST_obs + Corr;

    Stats.fitted_taper     = biases_taper;
    Stats.fitted_taper_rnd = biases_sample_taper;
    Corr_taper  = - (pattern_masked .* bias_taper_reshp(:,:,:,:,1) + bias_taper_reshp(:,:,:,:,2));
    SST_corr_taper = SST_obs + Corr_taper;    

end
