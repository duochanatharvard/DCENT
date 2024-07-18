% LME_lme_matrix_pattern
% |_ LME_lme_matrix_generate

function [M,P] = LME_lme_matrix_pattern(D,P)

    % *********************************************************************
    % Prepare for the design matrix of fixed effect
    % *********************************************************************
    disp('Prepare for the design matrix of fixed effect')
    clear('DD','PP')
    PP.N_pairs    = P.N_pairs;
    PP.N_groups   = P.N_groups;
    DD.J_grp_1    = D.J_grp_1;
    DD.J_grp_2    = D.J_grp_2;
    DD.W_X        = D.W_X;
    M.X           = LME_lme_matrix_generate(DD,PP);
    M.X(end+[1:size(DD.W_X,1)],:) = 0;
    PP.pos_val    = D.pattern;
    PP.neg_val    = -D.pattern; 
    M.XP          = LME_lme_matrix_generate(DD,PP);
    M.XP(end+[1:size(DD.W_X,1)],:) = DD.W_X;
    M.XP((end-2*size(DD.W_X,1)+1):(end-size(DD.W_X,1)),:) = 0;

    % *********************************************************************
    % Prepare for the design matrix of decadal effect 
    % *********************************************************************
    if numel(unique(D.group_decade)) ~= 1
        disp('Prepare for the design matrix of decadal effect')
        clear('DD','PP')
        P.N_decade = max(D.group_decade);
        PP.N_pairs  = P.N_pairs;
        PP.N_groups = P.N_groups * P.N_decade;
        DD.J_grp_1  = (D.J_grp_1 - 1) * P.N_decade + D.group_decade;
        DD.J_grp_2  = (D.J_grp_2 - 1) * P.N_decade + D.group_decade;
        DD.W_X      = repmat(zeros(1,size(D.W_X,2)),size(D.W_X,1),P.N_decade);

        M.Z_decade     = LME_lme_matrix_generate(DD,PP);
        M.Z_decade(end+[1:size(DD.W_X,1)],:) = 0;

        PP.pos_val     = D.pattern;
        PP.neg_val     = -D.pattern; 
        M.Z_decade_P   = LME_lme_matrix_generate(DD,PP);
        M.Z_decade_P(end+[1:size(DD.W_X,1)],:) = 0;
        
        M.logic_decade = any(M.Z_decade ~= 0,1);
        temp           = repmat([1:P.N_groups],P.N_decade,1);
        M.decade_info  = [temp(:)';  repmat([1:P.N_decade],1,P.N_groups)];
    end

    % *********************************************************************
    % Prepare for the Y and weights 
    % *********************************************************************
    M.Y = D.data_cmp(:,1);
    M.Y(end + [1:size(D.W_X,1)*2]) = 0;

    M.W = D.weigh_use;
    M.W(end + [1:size(D.W_X,1)*2]) = 100000000;

    M.X_in = [M.X M.XP];

    % *********************************************************************
    % Generate final matrices used for fitting 
    % *********************************************************************
    ct = 0;

    if numel(unique(D.group_decade)) ~= 1
        ct = ct + 1;
        M.Z_in{ct} = M.Z_decade(:,M.logic_decade);
        M.structure{ct} = 'Isotropic';
        M.dcd_id = ct;

        ct = ct + 1;
        M.Z_in{ct} = M.Z_decade_P(:,M.logic_decade);
        M.structure{ct} = 'Isotropic';
        M.dcd_id_pattern = ct;

        M.do_random = 1;
        M.N_decade = max(D.group_decade);
    else
        M.do_random = 0;
    end
end
