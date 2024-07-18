function [out,out_rnd] = LME_lme_post_pattern_combined(M,lme,D,P)

    % *********************************************************************
    % Assigning parameters
    % *********************************************************************
    if numel(unique(D.group_decade)) ~= 1
        N_decade = M.N_decade;
    end
    N_rnd = P.do_sampling;
    clear('out')

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
    out.unique_grp     = D.unique_grp;

    % if numel(out.bias_fixed) == 2*size(out.unique_grp,1)
    is_pattern = 1;
    % else
    %     is_pattern = 0;
    % end

    if P.do_sampling ~= 0
        out.Covariance_fixed = full(lme.CoefficientCovariance);
        rng(100);
        out.bias_fixed_random = ...
                   mvnrnd(full(b_fixed),full(out.Covariance_fixed),N_rnd)';
    end
    
    if is_pattern == 1

        out.bias_common                = out.bias_fixed(1:P.N_common);
        out.bias_common_pattern        = out.bias_fixed([1:P.N_common] + P.N_common);
        
        out.bias_common_std            = out.bias_fixed_std(1:P.N_common);
        out.bias_common_pattern_std    = out.bias_fixed_std([1:P.N_common] + P.N_common);

        N_grp = size(out.unique_grp,1);
        out.bias_fixed_pattern = out.bias_fixed([(N_grp+1):(2*N_grp)]+P.N_common*2);
        out.bias_fixed = out.bias_fixed([1:N_grp]+P.N_common*2);

        out.bias_fixed_pattern_std = out.bias_fixed_std([(N_grp+1):(2*N_grp)]+P.N_common*2);
        out.bias_fixed_std = out.bias_fixed_std([1:N_grp]+P.N_common*2);

        if P.do_sampling ~= 0

            out.bias_common_random         = out.bias_fixed_random(1:P.N_common,:);
            out.bias_common_pattern_random = out.bias_fixed_random([1:P.N_common] + P.N_common,:);
    
            out.bias_fixed_pattern_random = out.bias_fixed_random([(N_grp+1):(2*N_grp)]+P.N_common*2,:);
            out.bias_fixed_random = out.bias_fixed_random([1:N_grp]+P.N_common*2,:);
        end
    end

    % *********************************************************************
    % Random effects
    % *********************************************************************
    if M.do_random ~= 0

        [b_random,b_name,~] = randomEffects(lme);

        if P.do_sampling ~= 0

            try
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

                b_random_std = sqrt(diag(out.Covariance_conditional));
                temp = (out.Covariance_conditional + out.Covariance_conditional')/2;
                rng(1000);
                b_random_random = mvnrnd(full(b_random),full(temp),N_rnd);

            catch   % Directly compute Matrix inversion ...

                disp('Woodburry does not work')
                disp('Try directly compute Matrix inversion')
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

                b_random_std = sqrt(diag(out.Covariance_conditional));
                temp = (out.Covariance_conditional + out.Covariance_conditional')/2;
                rng(1000);
                b_random_random = mvnrnd(full(b_random),full(temp),N_rnd);
            end
        end

        % -----------------------------------------------------------------
        % Prepare to put the things into the field
        % -----------------------------------------------------------------
        [~,~,J]=unique(b_name(:,1));
        for i = 1:max(J)
            BB.bias_temp{i} = b_random(J == i);
            if P.do_sampling ~= 0
                BB.bias_std_temp{i} = b_random_std(J == i);
                BB.bias_random_temp{i} = b_random_random(:,J == i);
            end
        end

        % -----------------------------------------------------------------
        % Put decadal effect back
        % -----------------------------------------------------------------
        if numel(unique(D.group_decade)) ~= 1

            % random effects for the all-one pattern
            temp = LME_lme_post_random(BB,M.logic_decade,M.dcd_id,...
                                      N_decade,P.N_groups,P.do_sampling);
            out.bias_decade = temp.bias_random;
            if P.do_sampling ~= 0
                out.bias_decade_std = temp.bias_random_std;
                out.bias_decade_rnd = temp.bias_random_rnd;
            end

            % random effects for the bucket pattern
            if is_pattern
                temp = LME_lme_post_random(BB,M.logic_decade,M.dcd_id_pattern,...
                                          N_decade,P.N_groups,P.do_sampling);
                out.bias_decade_pattern = temp.bias_random;
                if P.do_sampling ~= 0
                    out.bias_decade_pattern_std = temp.bias_random_std;
                    out.bias_decade_pattern_rnd = temp.bias_random_rnd;
                end
            end
        end
    end

    out.MSE   = lme.MSE;
    out.Y_hat = lme.fitted;
    out.Y_raw = M.Y;


    % *********************************************************************
    % To save storage . and make loading data more efficient
    % *********************************************************************
    out_temp = out;
    clear('out','out_rnd')

    % Central estimates ---------------------------------------------------
    out.bias_common                 = out_temp.bias_common;
    out.bias_common_std             = out_temp.bias_common_std;
    out.bias_fixed                  = out_temp.bias_fixed;
    out.bias_fixed_std              = out_temp.bias_fixed_std;

    if is_pattern
        out.bias_common_pattern     = out_temp.bias_common_pattern;
        out.bias_common_pattern_std = out_temp.bias_common_pattern_std;
        out.bias_fixed_pattern      = out_temp.bias_fixed_pattern;
        out.bias_fixed_pattern_std  = out_temp.bias_fixed_pattern_std;
    end
    out.unique_grp                  = out_temp.unique_grp;
    out.Covariance_fixed            = out_temp.Covariance_fixed;
    try
        out.Covariance_conditional  = out_temp.Covariance_conditional;
    catch
        disp('No decadal effect is estimated')
    end
    out.MSE                         = out_temp.MSE;
    out.Y_hat                       = out_temp.Y_hat;
    out.Y_raw                       = out_temp.Y_raw;

    if numel(unique(D.group_decade)) ~= 1
        out.bias_decade             = out_temp.bias_decade;
        out.bias_decade_std         = out_temp.bias_decade_std;
        if is_pattern
            out.bias_decade_pattern     = out_temp.bias_decade_pattern;
            out.bias_decade_pattern_std = out_temp.bias_decade_pattern_std;
        end
    end

    % Samples representing uncertainties ----------------------------------
    if P.do_sampling ~= 0
        out_rnd.bias_common_rnd         = out_temp.bias_common_random;
        out_rnd.bias_fixed_rnd          = out_temp.bias_fixed_random;
        if is_pattern
            out_rnd.bias_common_pattern_rnd = out_temp.bias_common_pattern_random;
            out_rnd.bias_fixed_pattern_rnd  = out_temp.bias_fixed_pattern_random;
        end
        out_rnd.unique_grp              = out_temp.unique_grp;
        if numel(unique(D.group_decade)) ~= 1
            out_rnd.bias_decade_rnd     = out_temp.bias_decade_rnd;
            if is_pattern
                out_rnd.bias_decade_pattern_rnd = out_temp.bias_decade_pattern_rnd;
            end
        end
    else
        out_rnd = [];
    end
end
