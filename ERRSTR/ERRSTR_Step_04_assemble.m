function ERRSTR_Step_04_assemble(yr_list,reso)
    for yr = yr_list
        for mon = 1:12
            disp(num2str([yr mon]))
            ERRSTR_Step_04_assemble_single(yr,mon,reso);
        end
    end
end

% -------------------------------------------------------------------------
function ERRSTR_Step_04_assemble_single(yr,mon,reso)

    % Load in pre-calculated data -----------------------------------------
    file_count = [ERRSTR_OI('SST_Count'),'SST_Count_reso_',num2str(reso),'_',num2str(yr),'_',CDF_num2str(mon,2),'.mat'];
    load(file_count,'Ns','Nm','Nd','Ns_track','Nm_track','Nd_track','Ni2s','Ni2m','Ni2d');
    Nb      = Nm + Nd;

    file_infer = [ERRSTR_OI('Infer_ab'),'Infer_ab_reso_',num2str(reso),'_',num2str(yr),'.mat'];
    load(file_infer,'as','bs','am','bm','ad','bd');

    file_cov = [ERRSTR_OI('Covariance'),'Covariance_reso_',num2str(reso),'_',num2str(yr),'_',CDF_num2str(mon,2),'.mat'];
    load(file_cov,'Cs2','Cm2','Cd2');

    % Calculate the diagnal element of each type --------------------------
    if reso == 5
        temp = load('Sampling_error_base_from_HadSST4.mat','sampling_base_5X5');
        sigma2_samp = temp.sampling_base_5X5;
    else
        temp = load('Sampling_error_base_from_HadSST4.mat','sampling_base_1X1');
        sigma2_samp = temp.sampling_base_1X1;
    end

    % Calculate diagnal elements ------------------------------------------
    sigma2ms = 0.74.^2;    sigma2bs = 0.71.^2;   
    sigma2s = get_sigma2(sigma2ms, sigma2bs, sigma2_samp, as, bs, Ni2s, Ns, Ns_track);

    sigma2mm = 0.30.^2;    sigma2bm = 0.20.^2;   
    sigma2m = get_sigma2(sigma2mm, sigma2bm, sigma2_samp, am, bm, Ni2m, Nm, Nm_track);

    sigma2md = 0.26.^2;    sigma2bd = 0.29.^2;   
    sigma2d = get_sigma2(sigma2md, sigma2bd, sigma2_samp, ad, bd, Ni2d, Nd, Nd_track);

    % Calculate the off diagnal element of each type ----------------------
    Cs_off  = Cs2 .* sigma2bs;
    Cm_off  = Cm2 .* sigma2bm;
    Cd_off  = Cd2 .* sigma2bd;

    % Combine moored and drifting buoys -----------------------------------
    wm      = Nm ./ (Nm + Nd); 
    wd      = Nd ./ (Nm + Nd); 
    [sigma2b, Cb_off] = combine_source(wm, wd, sigma2m, sigma2d, Cm_off, Cd_off);

    % Combine buoy and ship measurements ----------------------------------
    Nb2             = Nb;
    Nb2(Nb2 > 2000) = 2000;
    ws              =       Ns  ./ (Ns + 6.8 * Nb2); 
    wb              = 6.8 * Nb2 ./ (Ns + 6.8 * Nb2); 
    [sigma2, C_off] = combine_source(ws, wb, sigma2s, sigma2b, Cs_off, Cb_off);

    % Save data as .mat files ---------------------------------------------
    file_save = [ERRSTR_OI('Uncertainty'),'Uncertainty_reso_',num2str(reso),'_',num2str(yr),'_',CDF_num2str(mon,2),'.mat'];
    save(file_save,'sigma2','C_off','-v7.3');

    % Save data as .nc files ----------------------------------------------
    ncfilename = [ERRSTR_OI('Uncertainty_nc'),'Uncertainty_reso_',num2str(reso),'_',num2str(yr),'_',CDF_num2str(mon,2),'.nc'];
    if isfile(ncfilename), delete(ncfilename); end

    [row_ind, col_ind, val] = find(C_off);
    nz_element = numel(row_ind);

    nccreate(ncfilename, 'lon', 'Dimensions', {'lon', 360/reso}, 'Datatype', 'single');
    nccreate(ncfilename, 'lat', 'Dimensions', {'lat', 180/reso}, 'Datatype', 'single');
    nccreate(ncfilename, 'cov', 'Dimensions', {'nz_element', nz_element, 'items', 7}, 'Datatype', 'double');
    nccreate(ncfilename, 'sigma2', 'Dimensions', {'lon', 360/reso, 'lat', 180/reso}, 'Datatype', 'double');

    lon = (reso/2):reso:360;
    lat = ((reso/2):reso:180) - 90;
    [row_ind_lon, row_ind_lat] = ind2sub([360/reso, 180/reso], row_ind);
    [col_ind_lon, col_ind_lat] = ind2sub([360/reso, 180/reso], col_ind);
    cov_sparse = [row_ind col_ind row_ind_lon row_ind_lat col_ind_lon col_ind_lat val];

    % Write data to the variables
    ncwrite(ncfilename, 'lon', lon);
    ncwrite(ncfilename, 'lat', lat);
    ncwrite(ncfilename, 'cov', cov_sparse);
    ncwrite(ncfilename, 'sigma2', sigma2);

    % Add global attributes
    ncwriteatt(ncfilename, '/', 'Conventions', 'CF-1.11');
    ncwriteatt(ncfilename, '/', 'title', 'Native Format of monthly uncertainty estimate for DCENT');
    ncwriteatt(ncfilename, '/', 'history', datestr(now));
    ncwriteatt(ncfilename, '/', 'institution', 'University of Southampton - Harvard University - Woods Hole Oceanographic Institution - UK National Oceanography Centre');
    ncwriteatt(ncfilename, '/', 'comment', ['This file contains DCENT uncertainty field for year ',num2str(yr), ' month ', num2str(mon)]);
    % ncwriteatt(ncfilename, '/', 'references', 'Chan, D., Gebbie, G., Huybers, P. & Kent, E. C. DCENT: Dynamically Consistent ENsemble of Temperature at the Earth Surface. https://doi.org/10.7910/DVN/NU4UGW (2024).');

    % Add variable attributes
    % Longitude attributes
    ncwriteatt(ncfilename, 'lon', 'units', 'degrees_east');
    ncwriteatt(ncfilename, 'lon', 'standard_name', 'longitude');
    ncwriteatt(ncfilename, 'lon', 'long_name', 'Longitude');

    % Latitude attributes
    ncwriteatt(ncfilename, 'lat', 'units', 'degrees_north');
    ncwriteatt(ncfilename, 'lat', 'standard_name', 'latitude');
    ncwriteatt(ncfilename, 'lat', 'long_name', 'Latitude');

    % Sigma2 attributes
    ncwriteatt(ncfilename, 'sigma2', 'units', 'degree_Celsius^2');
    ncwriteatt(ncfilename, 'sigma2', 'standard_name', 'sampling_and_obs_uncertainty');
    ncwriteatt(ncfilename, 'sigma2', 'long_name', 'Sampling and observation uncertainty (including both random and correlated)');
    ncwriteatt(ncfilename, 'sigma2', 'missing_value', single(NaN));
    ncwriteatt(ncfilename, 'sigma2', 'valid_min', single(min(sigma2(:))));
    ncwriteatt(ncfilename, 'sigma2', 'valid_max', single(max(sigma2(:))));

    % Covariance Matrix attributes
    ncwriteatt(ncfilename, 'cov', 'units', 'degree_Celsius^2');
    ncwriteatt(ncfilename, 'cov', 'standard_name', 'sampling_and_obs_uncertainty');
    ncwriteatt(ncfilename, 'cov', 'long_name', 'Sampling and observation uncertainty (including both random and correlated)');
    ncwriteatt(ncfilename, 'cov', 'explanation', 'The seven columns are row index | column index | longitude index of the row index | latitude index of the row index | longitude index of the column index | latitude index of the column index | covariance');
    ncwriteatt(ncfilename, 'cov', 'explanation2', 'The diagnal elements are only the correlated uncertainty calculated from trackable ships, which differs from sigma2');

end

% -------------------------------------------------------------------------
function sigma2 = get_sigma2...
                     (sigma2m, sigma2b, sigma2_samp, a, b, Ni2, N, N_track)

    sigma2 = sigma2b .* Ni2 ./ (N.^2) + ...
             sigma2b * a .* (N - N_track) .^ b ./ (N.^2) + ...
             sigma2m ./ N + sigma2_samp ./ N;
end

% -------------------------------------------------------------------------
function [sigma2, C_off] = combine_source(w1, w2, sigma21, sigma22, C1_off, C2_off)

    w1(isnan(w1)) = 0;
    w2(isnan(w2)) = 0;
    sigma21(isnan(sigma21)) = 0;
    sigma22(isnan(sigma22)) = 0;

    sigma2 = w1.^2 .* sigma21 + w2.^2 .* sigma22;
    sigma2(sigma2 == 0) = nan;

    % Combine covariance matrix
    [row_ind, col_ind, val] = find(C1_off);
    C1_off_temp             = sparse(row_ind,col_ind, ...
                                     val .* w1(row_ind) .* w1(col_ind), ...
                                     size(C1_off,1), size(C1_off,2));

    [row_ind, col_ind, val] = find(C2_off);
    C2_off_temp             = sparse(row_ind,col_ind, ...
                                     val .* w2(row_ind) .* w2(col_ind), ...
                                     size(C2_off,1), size(C2_off,2));

    C_off = C1_off_temp + C2_off_temp;
end