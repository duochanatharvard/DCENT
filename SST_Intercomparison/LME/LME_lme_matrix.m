% LME_lme_matrix
% |_ LME_lme_matrix_generate

function [M,P] = LME_lme_matrix(D,P)

    % ************************************************
    % Prepare for the design matrix of fixed effect **
    % ************************************************
    disp('Prepare for the design matrix of fixed effect')
    clear('DD','PP')
    PP.N_pairs  = P.N_pairs;
    PP.N_groups = P.N_groups;
    DD.J_grp_1  = D.J_grp_1;
    DD.J_grp_2  = D.J_grp_2;
    DD.W_X      = D.W_X;
    M.X = LME_lme_matrix_generate(DD,PP);

    % ***************************************************
    % Prepare for the design matrix of regional effect **
    % ***************************************************
    if P.do_region == 1,
        disp('Prepare for the design matrix of regional effect')
        clear('DD','PP')
        P.N_region = max(D.group_region);
        PP.N_pairs  = P.N_pairs;
        PP.N_groups = P.N_groups * P.N_region;
        DD.J_grp_1  = (D.J_grp_1 - 1) * P.N_region + D.group_region;
        DD.J_grp_2  = (D.J_grp_2 - 1) * P.N_region + D.group_region;
        DD.W_X      = repmat(zeros(1,size(D.W_X,2)),size(D.W_X,1),P.N_region);

        M.Z_region  = LME_lme_matrix_generate(DD,PP);
        M.logic_region = any(M.Z_region ~= 0,1);
        temp           = repmat([1:P.N_groups],P.N_region,1);
        M.region_info  = [temp(:)';  repmat([1:P.N_region],1,P.N_groups)];
    end

    % ***************************************************
    % Prepare for the design matrix of seasonal effect **
    % ***************************************************
    if P.do_season == 1,
        disp('Prepare for the design matrix of seasonal effect')
        clear('DD','PP')
        P.N_season = max(D.group_season);
        PP.N_pairs  = P.N_pairs;
        PP.N_groups = P.N_groups * P.N_season;
        DD.J_grp_1  = (D.J_grp_1 - 1) * P.N_season + D.group_season;
        DD.J_grp_2  = (D.J_grp_2 - 1) * P.N_season + D.group_season;
        DD.W_X      = repmat(zeros(1,size(D.W_X,2)),size(D.W_X,1),P.N_season);

        M.Z_season  = LME_lme_matrix_generate(DD,PP);
        M.logic_season = any(M.Z_season ~= 0,1);
        temp           = repmat([1:P.N_groups],P.N_season,1);
        M.season_info  = [temp(:)';  repmat([1:P.N_season],1,P.N_groups)];
    end

    % **************************************************
    % Prepare for the design matrix of decadal effect **
    % **************************************************
    if P.do_decade == 1,
        disp('Prepare for the design matrix of seasonal effect')
        clear('DD','PP')
        P.N_decade = max(D.group_decade);
        PP.N_pairs  = P.N_pairs;
        PP.N_groups = P.N_groups * P.N_decade;
        DD.J_grp_1  = (D.J_grp_1 - 1) * P.N_decade + D.group_decade;
        DD.J_grp_2  = (D.J_grp_2 - 1) * P.N_decade + D.group_decade;
        DD.W_X      = repmat(zeros(1,size(D.W_X,2)),size(D.W_X,1),P.N_decade);

        M.Z_decade = LME_lme_matrix_generate(DD,PP);
        M.logic_decade = any(M.Z_decade ~= 0,1);
        temp           = repmat([1:P.N_groups],P.N_decade,1);
        M.decade_info  = [temp(:)';  repmat([1:P.N_decade],1,P.N_groups)];
    end

    % ********************************
    % Prepare for the Y and weights **
    % ********************************
    M.Y = D.data_cmp(:,1);
    M.Y(end + [1:size(D.W_X,1)]) = 0;

    M.W = D.weigh_use;
    M.W(end + [1:size(D.W_X,1)]) = 100000000;

    M.X_in = M.X;

    % *******************************************
    % Generate final matrices used for fitting **
    % *******************************************
    ct = 0;

    if P.do_region == 1,
        ct = ct + 1;
        M.Z_in{ct} = M.Z_region(:,M.logic_region);
        M.structure{ct} = 'Isotropic';
        M.reg_id = ct;
    end

    if P.do_season == 1,
        ct = ct + 1;
        M.Z_in{ct} = M.Z_season(:,M.logic_season);
        M.structure{ct} = 'Isotropic';
        M.sea_id = ct;
    end

    if P.do_decade == 1,
        ct = ct + 1;
        M.Z_in{ct} = M.Z_decade(:,M.logic_decade);
        M.structure{ct} = 'Isotropic';
        M.dcd_id = ct;
    end

    if P.do_region == 0 && P.do_season == 0 && P.do_decade == 0,
        M.do_random = 0;
    else
        M.do_random = 1;
    end
end
