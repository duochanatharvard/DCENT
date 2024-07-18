function out = LME_lme_post_hierarchy(M,lme,D,P)

    N_rnd = P.do_sampling;
    clear('out')

    % *********************************************************************
    % Assigning parameters
    % *********************************************************************
    if P.do_region == 1,
        N_region = M.N_region;
    end
    if P.do_season == 1,
        N_season = M.N_season;
    end
    if P.do_decade == 1,
        N_decade = M.N_decade;
    end

    % *********************************************************************
    % fixed effects
    % *********************************************************************
    disp('Staring Post Process ...')
    clear('b_fixed','b_fixed_std','b_random','b_random_std')
    clear('bias_temp','bias_std_temp')
    % [b_fixed,~,STATS_fixed] = fixedEffects(lme);
    % b_fixed_std = STATS_fixed.SE;
    % out.bias_fixed_std = b_fixed_std(1:end);
    b_fixed            = fixedEffects(lme);
    out.bias_fixed     = full(b_fixed(1:end));
    out.bias_fixed_std = sqrt(full(diag(lme.CoefficientCovariance)));
    out.unique_grp = D.unique_grp;
    out.unique_nat = D.unique_nat;

    if P.do_sampling ~= 0,
        out.Covariance_fixed = full(lme.CoefficientCovariance);
        rng(100);
        out.bias_fixed_random = ...
                   mvnrnd(full(b_fixed),full(out.Covariance_fixed),N_rnd);
    end

    N_dck = nnz(M.logic_fixed);
    out.bias_fixed_nat = out.bias_fixed(1:end-N_dck);
    out.bias_fixed_dck = zeros(numel(M.logic_fixed),1);
    out.bias_fixed_dck(M.logic_fixed) = out.bias_fixed(end-N_dck+1:end);

    out.bias_fixed_std_nat = out.bias_fixed_std(1:end-N_dck);
    out.bias_fixed_std_dck = zeros(numel(M.logic_fixed),1);
    out.bias_fixed_std_dck(M.logic_fixed) = out.bias_fixed_std(end-N_dck+1:end);

    out.bias_fixed_rnd_nat = out.bias_fixed_random(:,1:end-N_dck);
    out.bias_fixed_rnd_dck = zeros(N_rnd,numel(M.logic_fixed),1);
    out.bias_fixed_rnd_dck(:,M.logic_fixed) = out.bias_fixed_random(:,end-N_dck+1:end);

    % Prepare for the variables for correction that is in the same format
    % as in the nation-only version, and is compatible with all other
    % existing scripts...
    [~,Pos]= ismember(out.unique_grp(:,P.nation_id),out.unique_nat,'rows');
    out.bias_fixed = out.bias_fixed_nat(Pos) + out.bias_fixed_dck;
    out.bias_fixed_random = out.bias_fixed_rnd_nat(:,Pos) + out.bias_fixed_rnd_dck;
    out.bias_fixed_std = sqrt(out.bias_fixed_std_nat(Pos).^2 + out.bias_fixed_std_dck.^2);

    % *********************************************************************
    % Random effects
    % *********************************************************************
    if M.do_random ~= 0,

        [b_random,b_name,~] = randomEffects(lme);

        if P.do_sampling ~= 0,
            if 1,
                % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                % use Woodbury matrix identity,                           !
                % ref:                                                    !
                % https://en.wikipedia.org/wiki/Woodbury_matrix_identity  !
                % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                disp(' ')
                disp('Computing covariance matrix for random effects ...')
                tic;
                % clear('O_inv')
                % O_inv = sparse(size(M.W,1),size(M.W,1));
                % for ct = 1:size(M.W,1)
                %     O_inv(ct,ct) = M.W(ct) ./ lme.MSE;
                % end

                clear('Z_sum','N_rnd_eff')
                Z_sum = [];
                for ct = 1:numel(M.Z_in)
                    Z_sum = [Z_sum M.Z_in{ct}];
                    N_rnd_eff(ct) = size(M.Z_in{ct},2);
                end

                clear('G_list')
                G_list = [];
                for ct = 1:numel(N_rnd_eff)
                    G_list = [G_list; diag(lme.covarianceParameters{ct})];
                end

                clear('G','G_inv')
                G = sparse(size(Z_sum,2),size(Z_sum,2));
                G_inv = sparse(size(Z_sum,2),size(Z_sum,2));
                for ct = 1:size(Z_sum,2)
                    G(ct,ct) = G_list(ct);
                    G_inv(ct,ct) = 1./G_list(ct);
                end

                try
                    Z_sum_trans = Z_sum' .* (M.W' ./ lme.MSE);
                catch
                    Z_sum_trans = Z_sum';
                    for ct = 1:size(Z_sum_trans,1)
                        Z_sum_trans(ct,:) = Z_sum_trans(ct,:) .* (M.W' ./ lme.MSE);
                    end
                end
                ZT_O_inv_Z = Z_sum_trans * Z_sum;
                % ZT_O_inv_Z = Z_sum' * O_inv * Z_sum;
                only_inv = inv(G_inv + ZT_O_inv_Z);

                out.Covariance_conditional = G - G * ZT_O_inv_Z * G + ...
                    G * ZT_O_inv_Z * only_inv * ZT_O_inv_Z * G;
                disp('Computing covariance matrix for random effects Completes')
                disp(['Took ',num2str(toc),' seconds!'])
                disp(' ')

            else   % Directly compute Matrix inversion ...
                % ---------------------------------------------------------
                % Compute the conditional covariance structure
                % ---------------------------------------------------------
                disp(' ')
                disp('Computing covariance matrix for random effects ...')
                tic;
                O = diag(1 ./ M.W) .* lme.MSE;
                V = zeros(size(M.X_in,1));
                Z_sum = [];
                for i = 1:numel(M.Z_in)
                    V = V + M.Z_in{i} * lme.covarianceParameters{i} * M.Z_in{i}';
                    Z_sum = [Z_sum M.Z_in{i}];
                    N_rnd_eff(i) = size(M.Z_in{i},2);
                end
                V = V + O;
                inv_V = inv(V);

                clear('G')
                for i = 1:numel(N_rnd_eff)
                    dim = [1:N_rnd_eff(i)] + sum(N_rnd_eff(1:i-1));
                    G(dim,dim) = lme.covarianceParameters{i};
                end

                out.Covariance_conditional = G - G * Z_sum' * inv_V * Z_sum * G;
                disp('Computing covariance matrix for random effects Completes')
                disp(['Took ',num2str(toc),' seconds!'])
                disp(' ')
            end

            b_random_std = sqrt(diag(out.Covariance_conditional));
            temp = (out.Covariance_conditional + out.Covariance_conditional')/2;
            rng(1000);
            b_random_random = mvnrnd(full(b_random),full(temp),N_rnd);

        end

        % -----------------------------------------------------------------
        % Prepare to put the things into the field
        % -----------------------------------------------------------------
        [~,~,J] = unique(b_name(:,1));
        for i = 1:max(J)
            BB.bias_temp{i} = b_random(J == i);
            if P.do_sampling ~= 0,
                BB.bias_std_temp{i} = b_random_std(J == i);
                BB.bias_random_temp{i} = b_random_random(:,J == i);
            end
        end

        % -----------------------------------------------------------------
        % Put regional effect back
        % -----------------------------------------------------------------
        if P.do_region == 1,
            if P.do_hierarchy_random == 1,

                temp = LME_lme_post_random(BB,M.logic_region,M.reg_id,...
                                          N_region,P.N_nat,P.do_sampling);
                out.bias_region_nat = temp.bias_random;

                if P.do_sampling ~= 0,
                    out.bias_region_std_nat = temp.bias_random_std;
                    out.bias_region_rnd_nat = temp.bias_random_rnd;
                end
            end

            temp = LME_lme_post_random(BB,M.logic_region_dck,M.reg_id_dck,...
                                      N_region,P.N_groups,P.do_sampling);
            out.bias_region_dck = temp.bias_random;

            if P.do_sampling ~= 0,
                out.bias_region_std_dck = temp.bias_random_std;
                out.bias_region_rnd_dck = temp.bias_random_rnd;
            end
        end

        % -----------------------------------------------------------------
        % Put seasonal effect back
        % -----------------------------------------------------------------
        if P.do_season == 1,
            if P.do_hierarchy_random == 1,

                temp = LME_lme_post_random(BB,M.logic_season,M.sea_id,...
                                          N_season,P.N_nat,P.do_sampling);
                out.bias_season_nat = temp.bias_random;

                if P.do_sampling ~= 0,
                    out.bias_season_std_nat = temp.bias_random_std;
                    out.bias_season_rnd_nat = temp.bias_random_rnd;
                end
            end

            temp = LME_lme_post_random(BB,M.logic_season_dck,M.sea_id_dck,...
                                      N_season,P.N_groups,P.do_sampling);
            out.bias_season_dck = temp.bias_random;

            if P.do_sampling ~= 0,
                out.bias_season_std_dck = temp.bias_random_std;
                out.bias_season_rnd_dck = temp.bias_random_rnd;
            end
        end

        % -----------------------------------------------------------------
        % Put decadal effect back
        % -----------------------------------------------------------------
        if P.do_decade == 1,
            if P.do_hierarchy_random == 1,

                temp = LME_lme_post_random(BB,M.logic_decade,M.dcd_id,...
                                          N_decade,P.N_nat,P.do_sampling);
                out.bias_decade_nat = temp.bias_random;

                if P.do_sampling ~= 0,
                    out.bias_decade_std_nat = temp.bias_random_std;
                    out.bias_decade_rnd_nat = temp.bias_random_rnd;
                end
            end

            temp = LME_lme_post_random(BB,M.logic_decade_dck,M.dcd_id_dck,...
                                      N_decade,P.N_groups,P.do_sampling);
            out.bias_decade_dck = temp.bias_random;

            if P.do_sampling ~= 0,
                out.bias_decade_std_dck = temp.bias_random_std;
                out.bias_decade_rnd_dck = temp.bias_random_rnd;
            end
        end
    end

    out.MSE = lme.MSE;
    out.Y_hat = lme.fitted;
    out.Y_raw = M.Y;
end
