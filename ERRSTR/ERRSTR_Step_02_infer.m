function ERRSTR_Step_02_infer(yr_list,reso)
    for yr = yr_list
        ERRSTR_Step_02_infer_single_year(yr,reso)
    end
end

% -------------------------------------------------------------------------
function ERRSTR_Step_02_infer_single_year(yr,reso)

    [as, bs] = ERRSTR_Step_02_infer_single_type(yr,1,reso);
    [am, bm] = ERRSTR_Step_02_infer_single_type(yr,2,reso);
    [ad, bd] = ERRSTR_Step_02_infer_single_type(yr,3,reso);
    file_save = [ERRSTR_OI('Infer_ab'),'Infer_ab_reso_',num2str(reso),'_',num2str(yr),'.mat'];
    save(file_save,'as','bs','am','bm','ad','bd','-v7.3');

end

% -------------------------------------------------------------------------
function [a, b] = ERRSTR_Step_02_infer_single_type(yr, ct_type, reso)

    yr_list = yr + (-4:1:4);

    % Trim years to be between 1850 and today's year
    yr_list(yr_list<1850) = [];
    yr_list(yr_list>year(datetime('today'))) = [];

    ct = 0;
    clear('N_track','Ni2')
    N_track = zeros(360/reso,180/reso,9,12);
    Ni2     = zeros(360/reso,180/reso,9,12);
    for yr  = yr_list
        ct  = ct + 1;
        for mon = 1:12
            file_save = [ERRSTR_OI('SST_Count'),'SST_Count_reso_',num2str(reso),'_',num2str(yr),'_',CDF_num2str(mon,2),'.mat'];
            if isfile(file_save)
                switch ct_type
                    case 1
                        temp = load(file_save,'Ns_track_sub','Ni2s_sub');
                        N_track(:,:,ct,mon) = temp.Ns_track_sub;
                        Ni2(:,:,ct,mon) = temp.Ni2s_sub;
                    case 2
                        temp = load(file_save,'Nm_track_sub','Ni2m_sub');
                        N_track(:,:,ct,mon) = temp.Nm_track_sub;
                        Ni2(:,:,ct,mon) = temp.Ni2m_sub;
                    case 3
                        temp = load(file_save,'Nd_track_sub','Ni2d_sub');
                        N_track(:,:,ct,mon) = temp.Nd_track_sub;
                        Ni2(:,:,ct,mon) = temp.Ni2d_sub;
                end
            end
        end
    end

    [a, b] = get_ab(Ni2,N_track);
end

% -------------------------------------------------------------------------
function  [a, b] = get_ab(Ni2,N_track)

    q95 = quantile(Ni2(:,:,:),0.95,3);

    x_train = N_track(:,:,:,1:2:end);  x_train = x_train(:,:,:);
    y_train = Ni2(:,:,:,1:2:end);      y_train = y_train(:,:,:);

    x_train(y_train > repmat(q95,1,1,54)) = nan;
    y_train(y_train > repmat(q95,1,1,54)) = nan;

    x_train(x_train == 0) = nan;
    y_train(y_train == 0) = nan;

    x_train = log(x_train);
    y_train = log(y_train);

    trd = CDC_trend(y_train, x_train, 3);
    b = trd{1};
    a = exp(trd{2});

    x_test = N_track(:,:,:,2:2:end);  x_test = x_test(:,:,:);
    y_test = Ni2(:,:,:,2:2:end);      y_test = y_test(:,:,:);

    x_test(y_test > repmat(q95,1,1,54)) = nan;
    y_test(y_test > repmat(q95,1,1,54)) = nan;

    x_test(x_test == 0) = nan;
    y_test(y_test == 0) = nan;

    y_pred  = repmat(a,1,1,54) .* (x_test .^ repmat(b,1,1,54));
    R       = CDC_corr(y_pred, y_test,3);

    l_valid = nansum(~isnan(y_train),3) > 4 & R >= 0.5;
    a(~l_valid) = 1;
    b(~l_valid) = 2;
end