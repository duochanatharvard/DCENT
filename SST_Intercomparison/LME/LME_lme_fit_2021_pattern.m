function LME_lme_fit_2021_pattern(P)

    % *********************************************************************
    % Load aggregated pairs
    % *********************************************************************
    disp('==============================================================>')
    disp('Start Fitting the LME model ...')
    % dir_load = LME_OI('bin_pairs');
    % file_load = [dir_load,'Binned_',P.save_sum_binned,'_pattern.mat'];
    file_load = LME_output_files('SST_Pairs_binned_pattern',P);
    load(file_load,'BINNED','W_X');
    
    if isfield(P,'excld_smll_bns')
        l = BINNED.Bin_n >= P.excld_smll_bns;
        disp([num2str(nnz(l)),' bins have at least ',...
                num2str(P.excld_smll_bns),' within each bin']);
        BINNED = ICOADS_subset(BINNED,l);
        
        N_temp = size(BINNED.Bin_kind,2)/2;
        temp   = [BINNED.Bin_kind(:,1:N_temp); BINNED.Bin_kind(:,N_temp + [1:N_temp])];
        [uni,~,J] = unique(temp,'rows');
        BINNED.Group_uni = uni;
         
        NN = [BINNED.Bin_n; BINNED.Bin_n];
        clear('W_X2')
        for ct = 1:size(uni,1)
            W_X2(ct) = nansum(NN(J == ct));
        end
        W_X2 = W_X2./nansum(W_X2);
        W_X = W_X2;
        clear('N_temp','temp','NN','l','W_X2','J','uni')
        
        % P.save_lme = [P.save_lme,'_excld_smll_bns_',num2str(P.excld_smll_bns)];
    end
    
    % Below is for ship-level analysis, make sure that all ships are
    % inter-connected into a big group.
    if isfield(P,'app_all_pairs')
        if strcmp(P.app_all_pairs,'All_ship_pairs_kent_id')

            % Put ship name into numbers
            N_temp = size(BINNED.Bin_kind,2)/2;
            temp   = [BINNED.Bin_kind(:,1:N_temp); BINNED.Bin_kind(:,N_temp + [1:N_temp])];
            [uni,~,J] = unique(temp,'rows');

            % Count the number of measurements in each ship
            NN = [BINNED.Bin_n; BINNED.Bin_n];
            clear('N_X')
            for ct = 1:size(uni,1)
                N_X(ct) = nansum(NN(J == ct));
            end

            % Remove small ships
            l_use = N_X >= P.key;
            W_X   = W_X(l_use);
            W_X = W_X./nansum(W_X);
            BINNED.Group_uni = BINNED.Group_uni(l_use,:);

            N_temp = size(BINNED.Bin_kind,2)/2;
            temp   = [BINNED.Bin_kind(:,1:N_temp); BINNED.Bin_kind(:,N_temp + [1:N_temp])];
            l = ismember(temp,BINNED.Group_uni,'rows');
            l = [l(1:numel(l)/2) l((numel(l)/2+1):end)];
            l_use = all(l == 1,2);
            BINNED = ICOADS_subset(BINNED,l_use);

            clear('N_temp','temp','NN','l','W_X2','J','uni')
        end
    end

    % *********************************************************************
    % Assign data and effects
    % *********************************************************************
    clear('D')
    D.W_X   = W_X;
    % app_size = size(W_X,1);
    P.L_grp = size(BINNED.Bin_kind,2)/2;
    D.kind_cmp_1 = double(BINNED.Bin_kind(:,1:P.L_grp));
    D.kind_cmp_2 = double(BINNED.Bin_kind(:,P.L_grp+1:end));

    D.group_decade = double(BINNED.Bin_decade);
    D.weigh_use    = double(BINNED.Bin_w);
    D.data_cmp     = double(BINNED.Bin_y);
    D.pattern      = double(BINNED.Bin_pattern);
    % D.pattern_1    = double(BINNED.Bin_pattern_1);
    % D.pattern_2    = double(BINNED.Bin_pattern_2);

    % *********************************************************************
    % Convert grouping into numbers
    % kind_cmp = unique_grp(J_grp,:);
    % *********************************************************************
    P.N_pairs  = size(D.data_cmp,1);
    [D.unique_grp,~,J_grp] = unique([D.kind_cmp_1;D.kind_cmp_2],'rows');
    D.J_grp_1  = J_grp(1:P.N_pairs);
    D.J_grp_2  = J_grp(P.N_pairs+1:end);
    P.N_groups = size(D.unique_grp,1);

    % *********************************************************************
    % See how many subgroups to the comparison form
    % Typically, there should be one group
    % *********************************************************************
    [JJ_grp,~,~] = unique([D.J_grp_1 D.J_grp_2],'rows');
    clusters = LME_function_find_group(JJ_grp);
    P.N_clusters = size(clusters,1);

    if P.N_clusters ~= 1
        error('Multiple clusters, still under-development!')
        disp(['Pairs are in ',num2str(P.N_clusters),' clusters']);
        disp(['Each cluster has ',num2str(nansum(clusters,2)','%4.0f,'),' groups'])
        
        W_X_new = zeros(size(clusters,1),size(W_X,2));
        for ct = 1:size(clusters,1)
            l = clusters(ct,:) == 1;
            W_X_new(ct,l) = W_X(l)./nansum(W_X(l));
        end
        W_X = W_X_new;
    end
    disp(' ')

    % *********************************************************************
    % Prepare for the Design Matrices of LME
    % *********************************************************************
    disp('==============================================================>')
    disp('Assign Matrices ...')

    % D.group_decade (1:2:end,:) = 1;     % TO DELETE
    % D.group_decade (2:2:end,:) = 2;     % TO DELETE

    [M,P] = LME_lme_matrix_pattern(D,P);
    % M_mean = M;
    % M_mean.X_in = M_mean.X(1:end-app_size,:);
    % M_mean.Y = M_mean.Y(1:end-app_size,:);
    % M_mean.W = M_mean.W(1:end-app_size,:);
    % try
    %     M_mean = rmfield(M_mean,'Z_in');
    %     M_mean.Z_in{1} = M.Z_in{1}(1:end-app_size,:);
    %     M_mean.structure = M_mean.structure{1};
    % catch
    %     disp('No decadal effect is estimated');
    % end
    clear('JJ_grp','J_grp','BINNED','W_X','clusters')

    % *********************************************************************
    % Fitting the LME model
    % *********************************************************************
    disp('==============================================================>')
    disp('Fit the LME model ...')

    if M.do_random == 0
        lme = fitlmematrix(double(M.X_in),double(M.Y),[],[],...
            'FitMethod','ML','Weights',double(M.W));

        % lme_mean = fitlmematrix(double(M_mean.X_in),double(M_mean.Y),[],[],...
        %     'FitMethod','ML','Weights',double(M_mean.W));

    else
        lme = fitlmematrix(double(M.X_in),double(M.Y),M.Z_in,[],...
            'Covariancepattern',M.structure,'FitMethod','ML',...
            'Weights',double(M.W));

        % lme_mean = fitlmematrix(double(M_mean.X_in),double(M_mean.Y),M_mean.Z_in,[],...
        %     'Covariancepattern',M_mean.structure,'FitMethod','ML',...
        %     'Weights',double(M_mean.W));
    end
    disp('LME model fitted!')
    disp(' ')

    % *********************************************************************
    % Post-processing
    % *********************************************************************
    disp('==============================================================>')
    disp('Start post-processing Final fit')
    clear('out','out_rnd')
    [out,out_rnd] = LME_lme_post_pattern(M,lme,D,P);

    % For debug, you need patterns to be the same in each row of X and Z_in
    % such that add or subtracting a constant to fitted value does not
    % change the fitted results. [2021-06-07]
    % clf; hold on;
    % Y2 = M.X_in * [out.bias_fixed;out.bias_fixed_pattern];
    % Y3 = M.Z_in{1} * out.bias_decade(:);
    % Y4 = M.Z_in{2} * (out.bias_decade_pattern(:));
    % plot(out.Y_hat,Y2+Y3+Y4,'.')

    % disp('==============================================================>')
    % disp('Start post-processing Fit without a pattern')
    % [out_mean,out_mean_rnd] = LME_lme_post_pattern(M_mean,lme_mean,D,P);

    % *********************************************************************
    % Saving Data
    % *********************************************************************
    disp(' ')
    disp('==============================================================>')
    disp('Saving Data ...')
    file_save  = LME_output_files('LME_output_pattern_full',P);
    save(file_save,'out','out_rnd','lme','-v7.3')
    
    % file_save = [dir_save,'LME_',P.save_lme,'_pattern_mean.mat'];
    % save(file_save,'out_mean','out_mean_rnd','lme_mean','-v7.3')
    
    file_save  = LME_output_files('LME_output_pattern_core',P);
    save(file_save,'out','-v7.3')
    
    % dir_save = LME_OI('LME_output');
    % file_save = [dir_save,'LME_',P.save_lme,'_pattern_full.mat'];
    % save(file_save,'out','out_rnd','lme','-v7.3')
    % file_save = [dir_save,'LME_',P.save_lme,'_pattern_mean.mat'];
    % save(file_save,'out_mean','out_mean_rnd','lme_mean','-v7.3')
    % file_save = [dir_save,'LME_',P.save_lme,'_pattern_core.mat'];
    % save(file_save,'out','-v7.3')

    disp(' ')
    disp('LME analysis completes!')

end
