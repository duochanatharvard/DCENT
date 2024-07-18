function error_total_var = error_model(SST_infer_N)

    % A. Uncertainties in SAT-Inferred SSTs
    file_save = ['error_inferred_SST.mat'];
    load(file_save,'error_inferred_SST');

    % B. Measurement Uncertainty of station temperatures
    error_station_T = 0.41 ./ sqrt(SST_infer_N);

    % C. HadSST4 uncertainty estimates
    dir_HadSST4         = [CDC_other_temp_dir,'HadSST4/'];
    err_SST_correlated  = ncread([dir_HadSST4,...
        'HadSST.4.0.1.0_correlated_measurement_uncertainty.nc'],'tos_unc');
    err_SST_sampling    = ncread([dir_HadSST4,...
        'HadSST.4.0.1.0_sampling_uncertainty.nc'],'tos_unc');
    err_SST_measurement = ncread([dir_HadSST4,...
        'HadSST.4.0.1.0_uncorrelated_measurement_uncertainty.nc'],'tos_unc');

    N  = size(SST_infer_N,4)*12;
    if N > size(err_SST_correlated,3)
        mk = N - size(err_SST_correlated,3);
        err_SST_correlated(:,:,end+[1:mk])  = 10;
        err_SST_sampling(:,:,end+[1:mk])    = 10;
        err_SST_measurement(:,:,end+[1:mk]) = 10;
    else
        err_SST_correlated  = err_SST_correlated(:,:,1:N);
        err_SST_sampling    = err_SST_sampling(:,:,1:N);
        err_SST_measurement = err_SST_measurement(:,:,1:N);
    end

    err_SST_correlated  = reshape(err_SST_correlated([37:72 1:36],:,:),72,36,12,N/12);
    err_SST_sampling    = reshape(err_SST_sampling([37:72 1:36],:,:),72,36,12,N/12);
    err_SST_measurement = reshape(err_SST_measurement([37:72 1:36],:,:),72,36,12,N/12);

    % Total variance, whose inverse will be used as the weight in fitting
    error_total_var = error_inferred_SST.^2 + error_station_T.^2 + ...
      err_SST_correlated.^2 + err_SST_sampling.^2 + err_SST_measurement.^2;

end

